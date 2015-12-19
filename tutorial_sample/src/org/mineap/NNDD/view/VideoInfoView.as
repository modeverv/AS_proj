/**
 * VideoInfoView.as
 * 
 * Copyright (c) 2008-2009 MAP - MineApplicationProject. All Rights Reserved.
 *  
 * @author shiraminekeisuke
 * 
 */	

import flash.data.EncryptedLocalStore;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.NativeWindowBoundsEvent;
import flash.events.TextEvent;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import flash.utils.Timer;

import org.mineap.NNDD.LogManager;
import org.mineap.NNDD.Message;
import org.mineap.NNDD.PlayerController;
import org.mineap.NNDD.model.SearchItem;
import org.mineap.NNDD.model.SearchSortType;
import org.mineap.NNDD.model.SearchType;
import org.mineap.NNDD.util.PathMaker;
import org.mineap.NNDD.commentManager.LocalCommentManager;

import mx.collections.ArrayCollection;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.controls.Alert;
import mx.controls.CheckBox;
import mx.controls.DataGrid;
import mx.controls.HSlider;
import mx.controls.RadioButton;
import mx.core.Application;
import mx.core.DragSource;
import mx.events.AIREvent;
import mx.events.CloseEvent;
import mx.events.DataGridEvent;
import mx.events.DragEvent;
import mx.events.FlexEvent;
import mx.events.ListEvent;
import mx.events.SliderEvent;

private var videoPlayer:VideoPlayer;
private var playerController:PlayerController;
private var logManager:LogManager;

public var isRepeat:Boolean = false;
public var isShowComment:Boolean = true;
public var isPlayListRepeat:Boolean = false;
public var isSyncComment:Boolean = true;
public var isPlayerFollow:Boolean = true;
public var isRenewCommentEachPlay:Boolean = false;
public var isRenewOtherCommentWithCommentEachPlay:Boolean = false;
public var isResizePlayerEachPlay:Boolean = true;
public var isHideUnderController:Boolean = false;
public var commentScale:Number = 1.0;
public var fps:Number = 15;
public var isShowOnlyPermissionComment:Boolean = false;
public var showCommentCount:int = 250;
public var showCommentSec:int = 3;
public var isAntiAlias:Boolean = true;
public var commentAlpha:int = 100;
public var isEnableJump:Boolean = true;
public var isAskToUserOnJump:Boolean = true;
public var isInfoViewAlwaysFront:Boolean = false;
public var isCommentFontBold:Boolean = true;
public var isShowAlwaysNicowariArea:Boolean = false;
public var selectedResizeType:int = RESIZE_TYPE_NICO;
public var isAlwaysEconomyForStreaming:Boolean = false;
public var isHideTagArea:Boolean = false;
public var isReNameOldComment:Boolean = false;
public var isHideSekaShinComment:Boolean = false;

public static const RESIZE_TYPE_NICO:int = 1;
public static const RESIZE_TYPE_VIDEO:int = 2;

public var videoUrlMap:Object = new Object();

public var myListMap:Object = new Object();

private var lastRect:Rectangle = new Rectangle();

private var seekTimer:Timer;
private var seekValue:Number = 0;

public var isActive:Boolean = false;

public var playListName:String = "";

[Bindable]
public var commentListProvider:ArrayCollection = new ArrayCollection();
[Bindable]
public var ownerCommentProvider:ArrayCollection = new ArrayCollection();
[Bindable]
private var playListProvider:ArrayCollection = new ArrayCollection();
[Bindable]
public var localTagProvider:Array = new Array();
[Bindable]
public var nicoTagProvider:Array = new Array();
[Bindable]
public var ichibaLocalProvider:ArrayCollection = new ArrayCollection();
[Bindable]
public var ichibaNicoProvider:ArrayCollection = new ArrayCollection();
[Bindable]
public var ngListProvider:ArrayCollection = new ArrayCollection();
[Bindable]
public var owner_text_nico:String = "";
[Bindable]
public var owner_text_local:String = "";
[Bindable]
private var myListDataProvider:Array = new Array();
[Bindalbe]
public var savedCommentListProvider:Array = new Array();

public function init(playerController:PlayerController, videoPlayer:VideoPlayer, logManager:LogManager):void{
	this.videoPlayer = videoPlayer;
	this.playerController = playerController;
	this.logManager = logManager;
	
	this.addEventListener(FlexEvent.CREATION_COMPLETE, function(event:FlexEvent):void{
		stage.addEventListener(AIREvent.WINDOW_ACTIVATE, function(event:AIREvent):void{
			isActive = true;
		});
		stage.addEventListener(AIREvent.WINDOW_DEACTIVATE, function(event:AIREvent):void{
			isActive = false;
		});
		
	});
	
	readStore();
}

public function resetInfo():void{
	localTagProvider = new Array();
	nicoTagProvider = new Array();
	ichibaLocalProvider = new ArrayCollection();
	ichibaNicoProvider = new ArrayCollection();
	
	owner_text_local = "";
	owner_text_nico = "";
}

private function windowClosing():void{
	
	this.playerController.isPlayerClosing = true;
	
	(this as Window).restore();
	
	saveStore();
	
	this.playerController.stop();
	
	this.playerController.destructor();
	
}

private function windowClosed():void{
	
	if(this.videoPlayer != null && !this.videoPlayer.closed){
		this.videoPlayer.close();
	}
	
	this.playerController.destructor();
	
}

private function play():void{
	this.playerController.play();
}

private function stop():void{
	this.playerController.stop();
}

private function checkBoxReNameOldCommentChanged(event:Event):void{
	this.isReNameOldComment = event.target.selected;
	Application.application.setRenameOldComment(this.isReNameOldComment);
}

public function setRenameOldComment(boolean:Boolean):void{
	this.isReNameOldComment = boolean;
	if(checkBox_isReNameOldComment != null){
		checkBox_isReNameOldComment.selected = boolean;
	}
}

private function checkboxRepeatChanged():void{
	this.isRepeat = this.checkbox_repeat.selected;
}

private function checkboxShowCommentChanged():void{
	this.isShowComment = this.checkbox_showComment.selected;
}

private function checkBoxPlayerAlwaysFrontChanged(event:Event):void{
	this.videoPlayer.isAlwaysFront = (event.currentTarget as CheckBox).selected;
	this.videoPlayer.alwaysInFront = (event.currentTarget as CheckBox).selected;
}

private function checkBoxInfoViewAlwaysFrontChanged(event:Event):void{
	this.isInfoViewAlwaysFront = (event.currentTarget as CheckBox).selected;
	this.alwaysInFront = (event.currentTarget as CheckBox).selected;
}

private function checkBoxCommentFontBoldChanged(event:Event):void{
	this.isCommentFontBold = this.checkBox_commentBold.selected;
	playerController.setCommentFontBold(this.isCommentFontBold);
}

private function checkboxSyncCommentChanged():void{
	this.isSyncComment = this.checkbox_SyncComment.selected;
	this.commentListProvider.sort = new Sort();
	this.commentListProvider.sort.fields = [new SortField("vpos_column",true)];
	this.commentListProvider.refresh();
}

private function checkboxRepeatAllChanged():void{
	this.isPlayListRepeat = this.checkBox_repeatAll.selected;
}

private function checkboxPlayerFollowChanged(event:Event):void{
	this.isPlayerFollow = this.checkbox_playerFollow.selected;
	if((event.currentTarget as CheckBox).selected){
		this.videoPlayer.followInfoView(this.videoPlayer.lastRect);
	}
}

private function checkboxHideUnderControllerChanged(event:Event):void{
	this.isHideUnderController = this.checkbox_hideUnderController.selected;
	if(this.videoPlayer.stage.displayState != StageDisplayState.FULL_SCREEN_INTERACTIVE){
		if((event.currentTarget as CheckBox).selected){
			//下コントローラを隠す
			this.videoPlayer.showUnderController(false, true);
		}else{
			//下コントローラを表示
			this.videoPlayer.showUnderController(true, true);
		}
	}
	this.videoPlayer.videoController.resetAlpha(true);
}

private function checkboxHideTagAreaChanged(event:Event):void{
	this.isHideTagArea = this.checkbox_hideTagArea.selected;
	if(this.videoPlayer.stage.displayState != StageDisplayState.FULL_SCREEN_INTERACTIVE){
		if((event.currentTarget as CheckBox).selected){
			//タグ表示領域を隠す
			this.videoPlayer.showTagArea(false, true);
		}else{
			//タグ表示利用域を表示する
			this.videoPlayer.showTagArea(true, true);
		}
	}
	this.videoPlayer.videoController.resetAlpha(true);
}

private function checkboxResizePlayerEachPlay(event:Event):void{
	this.isResizePlayerEachPlay = this.checkbox_resizePlayerEachPlay.selected;
	radioGroup_resizeType.selectedValue = selectedResizeType;
	if(this.isResizePlayerEachPlay){
		this.playerController.resizePlayerJustVideoSize();
		this.radioButton_resizeNicoDou.enabled = true;
		this.radioButton_resizeVideo.enabled = true;
	}else{
		this.radioButton_resizeNicoDou.enabled = false;
		this.radioButton_resizeVideo.enabled = false;
	}
	
}

private function checkBoxAlwaysEconomyChanged(event:Event):void{
	isAlwaysEconomyForStreaming = this.checkBox_isAlwaysEconomyForStreaming.selected;
}


private function checkBoxShowAlwaysNicowariAreaChanged(event:Event):void{
	isShowAlwaysNicowariArea = this.checkBox_showAlwaysNicowariArea.selected;
	videoPlayer.setShowAlwaysNicowariArea(isShowAlwaysNicowariArea);
}

public function setShowAlwaysNicowariArea(isShow:Boolean):void{
	if(this.checkBox_showAlwaysNicowariArea != null){
		this.checkBox_showAlwaysNicowariArea.selected = isShow;
	}
	isShowAlwaysNicowariArea = isShow;
}

private function checkBoxRenewCommentChanged():void{
	isRenewCommentEachPlay = checkBox_renewComment.selected;
	checkBox_renewTagAndNicowari.enabled = isRenewCommentEachPlay;
	checkBox_isReNameOldComment.enabled = isRenewCommentEachPlay;
}

private function checkBoxCommentBoldChanged(event:Event):void{
	this.isCommentFontBold = checkBox_commentBold.selected;
	playerController.setCommentFontBold(this.isCommentFontBold);
}


private function thumbPress(event:SliderEvent):void{
	this.playerController.sliderChanging = true;
}

private function thumbRelease(event:SliderEvent):void{
	this.playerController.sliderChanging = false;
	this.playerController.seek(event.value);
}

private function sliderVolumeChanged(evt:SliderEvent):void{
	this.playerController.setVolume(evt.value);	
}

private function sliderFpsChanged(event:SliderEvent):void{
	this.fps = getFps(event.value);
	this.playerController.changeFps(this.fps);
}

private function sliderShowCommentCountChanged(event:SliderEvent):void{
	this.showCommentCount = event.value;
}

private function addNGListIdButtonClicked():void{
	var index:int = this.dataGrid_comment.selectedIndex;
	if(index > -1){
		this.playerController.ngListManager.addNgID(commentListProvider.getItemAt(index).user_id_column);
	}
}

private function addNGListWordButtonClicked():void{
	var index:int = this.dataGrid_comment.selectedIndex;
	if(index > -1){
		this.playerController.ngListManager.addNgWord(commentListProvider.getItemAt(index).comment_column);
	}
}

private function addPermissionIdButtonClicked():void{
	var index:int = this.dataGrid_comment.selectedIndex;
	if(index > -1){
		this.playerController.ngListManager.addPermissionId(commentListProvider.getItemAt(index).user_id_column);
	}
}

private function headerReleaseHandler(event:DataGridEvent):void{
	if(event.columnIndex == 1){
		this.isSyncComment = false;
		this.checkbox_SyncComment.selected = false;
	}
}

/**
 * TextInputに入力されているIDをNGリストに追加します
 * 
 */
private function addItemToNgList():void{
	playerController.ngListManager.addItemToNgList(textInput_ng.text, combobox_ngKind.selectedLabel);
}

private function ngListItemClicked(event:ListEvent):void{
	playerController.ngListManager.ngListItemClicked(event);
}

/**
 * 選択されているNG項目をNGリストカラ取り除きます。
 * 
 */
private function removeItemFromNgList():void{
	playerController.ngListManager.removeItemFromNgList();
}

private function ngTextInputKeyUp(event:KeyboardEvent):void{
	if(event.keyCode == Keyboard.ENTER){
		playerController.ngListManager.addItemToNgList(textInput_ng.text, combobox_ngKind.selectedLabel);
	}
}

private function fpsDataTipFormatFunction(value:Number):String{
	return new String(getFps(value));
}

private function getFps(value:Number):Number{
	switch(value){
		case 1:
			return 7.5;
		case 2:
			return 15;
		case 3:
			return 30;
		case 4:
			return 60;
		case 5:
			return 120;
		default:
			return 15;
	}
}

private function getValueByFps(fps:Number):int{
	switch(fps){
		case 7.5:
			return 1;
		case 15:
			return 2;
		case 30:
			return 3;
		case 60:
			return 4;
		case 120:
			return 5;
		default:
			return 2;
	}
}

private function keyListener(event:KeyboardEvent):void{
	if(event.keyCode == Keyboard.ESCAPE){
		this.button_full.label = Message.L_FULL;
	}else if(event.keyCode == Keyboard.F11 || (event.keyCode == Keyboard.F && (event.controlKey || event.commandKey))){
//		trace("Ctrl + " + event.keyCode);
		this.changeFull();
	}else if(event.keyCode == Keyboard.C){
//		trace(event.keyCode);
		this.stage.nativeWindow.activate();
	}else if(event.keyCode == Keyboard.SPACE){
		this.playerController.play();
	}else if(event.keyCode == Keyboard.LEFT){
		//左
		if(seekTimer != null){
			seekTimer.stop();
		}
		seekTimer = new Timer(100, 1);
		seekTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function(event:Event):void{
			var newValue:Number = videoPlayer.videoController.slider_timeline.value + seekValue;
			if(newValue <= (videoPlayer.videoController.slider_timeline as HSlider).minimum){
				newValue = 0;
			}else if(newValue >= (videoPlayer.videoController.slider_timeline as HSlider).maximum){
				newValue = (videoPlayer.videoController.slider_timeline as HSlider).maximum;
			}
			trace(newValue +" = "+videoPlayer.videoController.slider_timeline.value +"+"+ seekValue);
			playerController.seek(newValue);
			seekValue = 0;
		});
		seekTimer.start();
		this.seekValue -= 10;
	}else if(event.keyCode == Keyboard.RIGHT){
		//右
		if(seekTimer != null){
			seekTimer.stop();
		}
		seekTimer = new Timer(100, 1);
		seekTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function(event:Event):void{
			var newValue:Number = videoPlayer.videoController.slider_timeline.value + seekValue;
			if(newValue <= (videoPlayer.videoController.slider_timeline as HSlider).minimum){
				newValue = 0;
			}else if(newValue >= (videoPlayer.videoController.slider_timeline as HSlider).maximum){
				newValue = (videoPlayer.videoController.slider_timeline as HSlider).maximum;
			}
			trace(newValue +" = "+videoPlayer.videoController.slider_timeline.value +"+"+ seekValue);
			playerController.seek(newValue);
			seekValue = 0;
		});
		seekTimer.start();
		this.seekValue += 10;
	}else if(event.keyCode == Keyboard.UP){
		this.playerController.setVolume(this.videoPlayer.videoController.slider_volume.value + 0.05);
	}else if(event.keyCode == Keyboard.DOWN){
		this.playerController.setVolume(this.videoPlayer.videoController.slider_volume.value - 0.05);
	}
}

public function changeFull():void{
	if(this.videoPlayer.stage.displayState == StageDisplayState.NORMAL){
		//フルスクリーンじゃない時
		
		this.videoPlayer.showUnderController(false, false);
		this.videoPlayer.showTagArea(false, false);
		this.videoPlayer.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
//		this.videoPlayer.stage.displayState = StageDisplayState.FULL_SCREEN;
		this.button_full.label = Message.L_NORMAL;
	}else{
		//フルスクリーンの時
		
		//フルスクリーン解除
		this.videoPlayer.stage.displayState = StageDisplayState.NORMAL;
		this.button_full.label = Message.L_FULL;
		
		if(isHideUnderController){
			videoPlayer.showUnderController(false, false);
		}else{
			videoPlayer.showUnderController(true, false);
		}
		if(isHideTagArea){
			videoPlayer.showTagArea(false, false);
		}else{
			videoPlayer.showTagArea(true, false);
		}
	}
}

private function radioButtonResizeTypeChanged(event:Event):void{
	this.selectedResizeType = int(RadioButton(event.currentTarget).value);
	this.playerController.resizePlayerJustVideoSize();
}

private function checkBox_repeatAllCompleteHandler(event:FlexEvent):void{
	checkBox_repeatAll.selected = isPlayListRepeat;
}

private function checkBoxIsSOPCChanged(event:MouseEvent):void{
	isShowOnlyPermissionComment = checkBox_isShowOnlyPermissionComment.selected;
	this.playerController.renewComment()
}

private function checkBoxRenewTagNicowariChanged():void{
	isRenewOtherCommentWithCommentEachPlay = checkBox_renewTagAndNicowari.selected;
}

private function checkBoxIsEnableJump(event:MouseEvent):void{
	isEnableJump = event.currentTarget.selected;
	(checkBox_askToUserOnJump as CheckBox).enabled = isEnableJump;
}

private function checkBoxIsAskToUserOnJump(event:MouseEvent):void{
	isAskToUserOnJump = event.currentTarget.selected;
}

private function checkBoxHideSekaShinComment(event:MouseEvent):void{
	isHideSekaShinComment = event.currentTarget.selected;
	
	if(this.playerController != null){
		this.playerController.renewComment();
	}
}

private function commentListDoubleClicked(event:ListEvent):void{
	var time:String = event.target.selectedItem.vpos_column;
	
	var min:int = int(time.substring(0,time.indexOf(":")));
	var sec:int = int(time.substring(time.indexOf(":")+1));
	
	if(playerController.windowType == PlayerController.WINDOW_TYPE_FLV){
		this.playerController.seek(min*60 + sec);
	}else{
		this.playerController.seek((min*60 + sec)*playerController.swfFrameRate);
	}
}

private function ichibaDataGridDoubleClicked(event:ListEvent):void{
	trace((event.currentTarget as DataGrid).dataProvider[event.rowIndex].col_link);
	var url:String = (event.currentTarget as DataGrid).dataProvider[event.rowIndex].col_link;
	if(url != null){
		navigateToURL(new URLRequest(url));
	}
}

private function commentScaleSliderChanged(event:SliderEvent):void{
	this.commentScale = event.value;
	this.playerController.windowResized(true);
}

private function sliderShowCommentTimeChanged(event:SliderEvent):void{
	this.showCommentSec = event.value;
}

private function sliderCommentAlphaChanged(event:SliderEvent):void{
	this.commentAlpha = event.value;
	playerController.getCommentManager().setCommentAlpha(this.commentAlpha/100);
}

private function myDataTipFormatFunction(value:Number):String{
	var nowSec:String="00",nowMin:String="0";
	nowSec = String(int(value%60));
	nowMin = String(int(value/60));
	
	if(nowSec.length == 1){
		nowSec = "0" + nowSec; 
	}
	if(nowMin.length == 1){
		nowMin = "0" + nowMin;
	}
	return nowMin + ":" + nowSec;
}

private function windowCompleteHandler():void{
	
	videoPlayer.alwaysInFront = videoPlayer.isAlwaysFront;
	this.alwaysInFront = videoPlayer.isAlwaysFront;
	
	checkbox_repeat.selected = isRepeat;
	checkbox_showComment.selected = isShowComment;
	checkbox_SyncComment.selected = isSyncComment;
	checkBox_isShowOnlyPermissionComment.selected = isShowOnlyPermissionComment;
	
	videoPlayer.setShowAlwaysNicowariArea(isShowAlwaysNicowariArea);
	playerController.setCommentFontBold(this.isCommentFontBold);
	
	canvas_config.addEventListener(FlexEvent.CREATION_COMPLETE, configCanvasCreationCompleteHandler);
	
	videoPlayer.showUnderController(!isHideUnderController, true);
	videoPlayer.showTagArea(!isHideTagArea, true);
	
}

private function configCanvasCreationCompleteHandler(event:FlexEvent):void{
	checkbox_PlayerAlwaysFront.selected = videoPlayer.isAlwaysFront;
	checkbox_InfoViewAlwaysFront.selected = isInfoViewAlwaysFront;
	checkbox_playerFollow.selected = isPlayerFollow;
	radioGroup_resizeType.selectedValue = selectedResizeType;
	
	checkbox_resizePlayerEachPlay.selected = isResizePlayerEachPlay;
	if(isResizePlayerEachPlay){
		//			playerController.resizePlayerJustVideoSize();
		radioButton_resizeNicoDou.enabled = true;
		radioButton_resizeVideo.enabled = true;
	}else{
		radioButton_resizeNicoDou.enabled = false;
		radioButton_resizeVideo.enabled = false;
	}
	
	checkBox_showAlwaysNicowariArea.selected = isShowAlwaysNicowariArea;
	
	checkBox_commentBold.selected = isCommentFontBold;
	
	checkbox_hideUnderController.selected = isHideUnderController;
	slider_commentScale.value = commentScale;
	slider_fps.value = getValueByFps(fps);
	
	checkBox_renewComment.selected = isRenewCommentEachPlay;
	slider_showCommentCount.value = showCommentCount;
	slider_showCommentTime.value = showCommentSec;
	slider_commentAlpha.value = commentAlpha;
	checkBox_renewTagAndNicowari.selected = isRenewOtherCommentWithCommentEachPlay;
	checkBox_renewTagAndNicowari.enabled = isRenewCommentEachPlay;
	
	checkBox_enableJump.selected = isEnableJump;
	checkBox_askToUserOnJump.selected = isAskToUserOnJump;
	checkBox_askToUserOnJump.enabled = isEnableJump;
	
	checkBox_isAlwaysEconomyForStreaming.selected = isAlwaysEconomyForStreaming;
	
	checkbox_hideTagArea.selected = isHideTagArea;
	
	isReNameOldComment = Application.application.getReNameOldComment();
	checkBox_isReNameOldComment.selected = isReNameOldComment;
	checkBox_isReNameOldComment.enabled = isRenewCommentEachPlay;
	checkBox_hideSekaShinComment.selected = isHideSekaShinComment;
	
	if(playerController.getCommentManager() != null){
		playerController.getCommentManager().setAntiAlias(isAntiAlias);
	}
}

public function isRepeatAll():Boolean{
	return this.isPlayListRepeat;
}

private function windowResized(event:NativeWindowBoundsEvent):void{
	lastRect = event.afterBounds;
}

private function windowMove(event:NativeWindowBoundsEvent):void{
	lastRect = event.afterBounds;
}

public function playListDoubleClicked():void{
	if(playListProvider.length > 0){
		var url:String = videoUrlMap[playListProvider[dataGrid_playList.selectedIndex]];
		playerController.initForVideoPlayer(url, dataGrid_playList.selectedIndex);
	}
}

/**
 * 指定された番号のコメントをコメントリストで選択された状態にします。
 * 
 */
public function selectComment(no:Number):void{
	
	for(var i:int = 0; i<commentListProvider.length; i++){
		if(commentListProvider[i].no_column == no){
			(dataGrid_comment as DataGrid).selectedIndex = i;
			
			return;
		}
	}
	
}

private function readStore():void{
	
	try{
		/*ローカルストアから値の呼び出し*/
		var storedValue:ByteArray = EncryptedLocalStore.getItem("isRepeat");
		if(storedValue != null){
			isRepeat = storedValue.readBoolean();
		}
		storedValue = EncryptedLocalStore.getItem("isShowComment");
		if(storedValue != null){
			isShowComment = storedValue.readBoolean();
		}
		storedValue = EncryptedLocalStore.getItem("isPlayListRepeat");
		if(storedValue != null){
			isPlayListRepeat = storedValue.readBoolean();
		}
		storedValue = EncryptedLocalStore.getItem("isSyncComment");
		if(storedValue != null){
			isSyncComment = storedValue.readBoolean();
		}
		
		storedValue = EncryptedLocalStore.getItem("isPlayerFollow");
		if(storedValue != null){
			isPlayerFollow = storedValue.readBoolean();
		}
		
		storedValue = EncryptedLocalStore.getItem("isRenewCommentEachPlay");
		if(storedValue != null){
			isRenewCommentEachPlay = storedValue.readBoolean();
		}
		
		storedValue = EncryptedLocalStore.getItem("isResizePlayerEachPlay");
		if(storedValue != null){
			isResizePlayerEachPlay = storedValue.readBoolean();
		}
		
		storedValue = EncryptedLocalStore.getItem("isHideUnderController");
		if(storedValue != null){
			isHideUnderController = storedValue.readBoolean();
		}
		
		storedValue = EncryptedLocalStore.getItem("commentScale");
		if(storedValue != null){
			commentScale = storedValue.readDouble();
		}
		
		storedValue = EncryptedLocalStore.getItem("commentFps");
		if(storedValue != null){
			this.fps = storedValue.readDouble();
			this.playerController.changeFps(fps);
		}
		
		storedValue = EncryptedLocalStore.getItem("isShowOnlyPermissionComment");
		if(storedValue != null){
			isShowOnlyPermissionComment = storedValue.readBoolean();
		}
		
		storedValue = EncryptedLocalStore.getItem("showCommentCount");
		if(storedValue != null){
			showCommentCount = storedValue.readInt();
		}
		
		storedValue = EncryptedLocalStore.getItem("showCommentSec");
		if(storedValue != null){
			showCommentSec = storedValue.readInt();
		}
		
		storedValue = EncryptedLocalStore.getItem("isRenewOtherCommentWithCommentEachPlay");
		if(storedValue != null){
			isRenewOtherCommentWithCommentEachPlay = storedValue.readBoolean();
		}
		
		storedValue = EncryptedLocalStore.getItem("isAntiAlias");
		if(storedValue != null){
			isAntiAlias = storedValue.readBoolean();
		}
		
		storedValue = EncryptedLocalStore.getItem("commentAlpha");
		if(storedValue != null){
			commentAlpha = storedValue.readInt();
		}
		
		storedValue = EncryptedLocalStore.getItem("isEnableJump");
		if(storedValue != null){
			isEnableJump = storedValue.readBoolean();
		}
		
		storedValue = EncryptedLocalStore.getItem("isAskToUserOnJump");
		if(storedValue != null){
			isAskToUserOnJump = storedValue.readBoolean();
		}
		
		storedValue = EncryptedLocalStore.getItem("isInfoViewAlwaysFront");
		if(storedValue != null){
			isInfoViewAlwaysFront = storedValue.readBoolean();
		}
		
		storedValue = EncryptedLocalStore.getItem("selectedResizeType");
		if(storedValue != null){
			selectedResizeType = storedValue.readInt();
		}
		
		storedValue = EncryptedLocalStore.getItem("isCommentFontBold");
		if(storedValue != null){
			isCommentFontBold = storedValue.readBoolean();
		}
		
		storedValue = EncryptedLocalStore.getItem("isShowAlwaysNicowariArea");
		if(storedValue != null){
			isShowAlwaysNicowariArea = storedValue.readBoolean();
		}
		
		storedValue = EncryptedLocalStore.getItem("isHideTagArea");
		if(storedValue != null){
			isHideTagArea = storedValue.readBoolean();
		}
		
		storedValue = EncryptedLocalStore.getItem("isAlwaysEconomyForStreaming");
		if(storedValue != null){
			isAlwaysEconomyForStreaming = storedValue.readBoolean();
		}
		
		storedValue = EncryptedLocalStore.getItem("isReNameOldComment");
		if(storedValue != null){
			isReNameOldComment = storedValue.readBoolean();
		}
		
		storedValue = EncryptedLocalStore.getItem("isHideSekaShinComment");
		if(storedValue != null){
			isHideSekaShinComment = storedValue.readBoolean();
		}
		
		//x,y,w,h
//		storedValue = EncryptedLocalStore.getItem("playerVersion");
//		//インストール直後の初回起動ではウィンドウの大きさを反映しない。
//		if(storedValue != null){
//			var version:String = storedValue.readUTFBytes(storedValue.length);
//			if(version == NNDD.PLAYER_VERSION){
	
				storedValue = EncryptedLocalStore.getItem("controllerWindowPosition_x");
				if(storedValue != null){
					var controllerPosition_x:Number = storedValue.readDouble();
					this.addEventListener(FlexEvent.CREATION_COMPLETE, function():void{
						nativeWindow.x = lastRect.x = controllerPosition_x;
					});
				}
				storedValue = EncryptedLocalStore.getItem("controllerWindowPosition_y");
				if(storedValue != null){
					var controllerPosition_y:Number = storedValue.readDouble();
					this.addEventListener(FlexEvent.CREATION_COMPLETE, function():void{
						nativeWindow.y = lastRect.y = controllerPosition_y;
					});
				}
				storedValue = EncryptedLocalStore.getItem("controllerWindowPosition_w");
				if(storedValue != null){
					var controllerPosition_w:Number = storedValue.readDouble();
					this.addEventListener(FlexEvent.CREATION_COMPLETE, function():void{
						nativeWindow.width = lastRect.width = controllerPosition_w;
					});
				}
				storedValue = EncryptedLocalStore.getItem("controllerWindowPosition_h");
				if(storedValue != null){
					var controllerPosition_h:Number = storedValue.readDouble();
					this.addEventListener(FlexEvent.CREATION_COMPLETE, function():void{
						nativeWindow.height = lastRect.height = controllerPosition_h;
					});
				}
//			}
//		}
		
	}catch(error:Error){
		trace(error.getStackTrace());
		EncryptedLocalStore.reset();
		Alert.show(Message.M_LOCAL_STORE_IS_BROKEN, Message.M_ERROR);
		logManager.addLog(Message.FAIL_LOAD_LOCAL_STORE_FOR_VIDEO_INFO_VIEW + ":" + Message.M_LOCAL_STORE_IS_BROKEN + ":" + error);
	}
	
}

public function saveStore():void{
	
	try{
		
		/*ローカルストアに値を保存*/
		EncryptedLocalStore.removeItem("isRepeat");
		var bytes:ByteArray = new ByteArray();
		bytes.writeBoolean(isRepeat);
		EncryptedLocalStore.setItem("isRepeat", bytes);
		
		EncryptedLocalStore.removeItem("isShowComment");
		bytes = new ByteArray();
		bytes.writeBoolean(isShowComment);
		EncryptedLocalStore.setItem("isShowComment", bytes);
		
		EncryptedLocalStore.removeItem("isPlayListRepeat");
		bytes = new ByteArray();
		bytes.writeBoolean(isPlayListRepeat);
		EncryptedLocalStore.setItem("isPlayListRepeat", bytes);
		
		EncryptedLocalStore.removeItem("isSyncComment");
		bytes = new ByteArray();
		bytes.writeBoolean(isSyncComment);
		EncryptedLocalStore.setItem("isSyncComment", bytes);
		
		EncryptedLocalStore.removeItem("isPlayerFollow");
		bytes = new ByteArray();
		bytes.writeBoolean(isPlayerFollow);
		EncryptedLocalStore.setItem("isPlayerFollow", bytes);
		
		EncryptedLocalStore.removeItem("isRenewCommentEachPlay");
		bytes = new ByteArray();
		bytes.writeBoolean(isRenewCommentEachPlay);
		EncryptedLocalStore.setItem("isRenewCommentEachPlay", bytes);
		
		EncryptedLocalStore.removeItem("isResizePlayerEachPlay");
		bytes = new ByteArray();
		bytes.writeBoolean(isResizePlayerEachPlay);
		EncryptedLocalStore.setItem("isResizePlayerEachPlay", bytes);
		
		EncryptedLocalStore.removeItem("isHideUnderController");
		bytes = new ByteArray();
		bytes.writeBoolean(isHideUnderController);
		EncryptedLocalStore.setItem("isHideUnderController", bytes);
		
		// Playerバージョン保存
		EncryptedLocalStore.removeItem("playerVersion");
		bytes = new ByteArray();
		bytes.writeUTFBytes((Application.application as NNDD).version);
		EncryptedLocalStore.setItem("playerVersion", bytes);
		
		// ウィンドウの位置情報保存
		EncryptedLocalStore.removeItem("controllerWindowPosition_x");
		bytes = new ByteArray();
		bytes.writeDouble(lastRect.x);
		EncryptedLocalStore.setItem("controllerWindowPosition_x", bytes);
		
		EncryptedLocalStore.removeItem("controllerWindowPosition_y");
		bytes = new ByteArray();
		bytes.writeDouble(lastRect.y);
		EncryptedLocalStore.setItem("controllerWindowPosition_y", bytes);
		
		EncryptedLocalStore.removeItem("controllerWindowPosition_w");
		bytes = new ByteArray();
		bytes.writeDouble(lastRect.width);
		EncryptedLocalStore.setItem("controllerWindowPosition_w", bytes);
		
		EncryptedLocalStore.removeItem("controllerWindowPosition_h");
		bytes = new ByteArray();
		bytes.writeDouble(lastRect.height);
		EncryptedLocalStore.setItem("controllerWindowPosition_h", bytes);
		
		EncryptedLocalStore.removeItem("commentScale");
		bytes = new ByteArray();
		bytes.writeDouble(commentScale);
		EncryptedLocalStore.setItem("commentScale", bytes);
		
		EncryptedLocalStore.removeItem("commentFps");
		bytes = new ByteArray();
		bytes.writeDouble(fps);
		EncryptedLocalStore.setItem("commentFps", bytes);
		
		EncryptedLocalStore.removeItem("isShowOnlyPermissionComment");
		bytes = new ByteArray();
		bytes.writeBoolean(isShowOnlyPermissionComment);
		EncryptedLocalStore.setItem("isShowOnlyPermissionComment", bytes);
		
		EncryptedLocalStore.removeItem("showCommentCount");
		bytes = new ByteArray();
		bytes.writeInt(showCommentCount);
		EncryptedLocalStore.setItem("showCommentCount", bytes);
		
		EncryptedLocalStore.removeItem("showCommentSec");
		bytes = new ByteArray();
		bytes.writeInt(showCommentSec);
		EncryptedLocalStore.setItem("showCommentSec", bytes);
		
		EncryptedLocalStore.removeItem("isRenewOtherCommentWithCommentEachPlay");
		bytes = new ByteArray();
		bytes.writeBoolean(isRenewOtherCommentWithCommentEachPlay);
		EncryptedLocalStore.setItem("isRenewOtherCommentWithCommentEachPlay", bytes);
		
		EncryptedLocalStore.removeItem("isAntiAlias");
		bytes = new ByteArray();
		bytes.writeBoolean(isAntiAlias);
		EncryptedLocalStore.setItem("isAntiAlias", bytes);
		
		EncryptedLocalStore.removeItem("commentAlpha");
		bytes = new ByteArray();
		bytes.writeInt(this.commentAlpha);
		EncryptedLocalStore.setItem("commentAlpha", bytes);
		
		EncryptedLocalStore.removeItem("isEnableJump");
		bytes = new ByteArray();
		bytes.writeBoolean(this.isEnableJump);
		EncryptedLocalStore.setItem("isEnableJump", bytes);
		
		EncryptedLocalStore.removeItem("isAskToUserOnJump");
		bytes = new ByteArray();
		bytes.writeBoolean(this.isAskToUserOnJump);
		EncryptedLocalStore.setItem("isAskToUserOnJump", bytes);
		
		EncryptedLocalStore.removeItem("isInfoViewAlwaysFront");
		bytes = new ByteArray();
		bytes.writeBoolean(this.isInfoViewAlwaysFront);
		EncryptedLocalStore.setItem("isInfoViewAlwaysFront", bytes);
		
		EncryptedLocalStore.removeItem("selectedResizeType");
		bytes = new ByteArray();
		bytes.writeInt(this.selectedResizeType);
		EncryptedLocalStore.setItem("selectedResizeType", bytes);
		
		EncryptedLocalStore.removeItem("isCommentFontBold");
		bytes = new ByteArray();
		bytes.writeBoolean(this.isCommentFontBold);
		EncryptedLocalStore.setItem("isCommentFontBold", bytes);
		
		EncryptedLocalStore.removeItem("isShowAlwaysNicowariArea");
		bytes = new ByteArray();
		bytes.writeBoolean(this.isShowAlwaysNicowariArea);
		EncryptedLocalStore.setItem("isShowAlwaysNicowariArea", bytes);
		
		EncryptedLocalStore.removeItem("isAlwaysEconomyForStreaming");
		bytes = new ByteArray();
		bytes.writeBoolean(this.isAlwaysEconomyForStreaming);
		EncryptedLocalStore.setItem("isAlwaysEconomyForStreaming", bytes);
		
		EncryptedLocalStore.removeItem("isHideTagArea");
		bytes = new ByteArray();
		bytes.writeBoolean(this.isHideTagArea);
		EncryptedLocalStore.setItem("isHideTagArea", bytes);
		
		EncryptedLocalStore.removeItem("isReNameOldComment");
		bytes = new ByteArray();
		bytes.writeBoolean(this.isReNameOldComment);
		EncryptedLocalStore.setItem("isReNameOldComment", bytes);
		
		EncryptedLocalStore.removeItem("isHideSekaShinComment");
		bytes = new ByteArray();
		bytes.writeBoolean(this.isHideSekaShinComment);
		EncryptedLocalStore.setItem("isHideSekaShinComment", bytes);
		
		
	}catch(error:Error){
		Alert.show(Message.M_LOCAL_STORE_IS_BROKEN, Message.M_ERROR);
		logManager.addLog(Message.FAIL_LOAD_LOCAL_STORE_FOR_VIDEO_INFO_VIEW + ":" + Message.M_LOCAL_STORE_IS_BROKEN + ":" + error);
		EncryptedLocalStore.reset();
		trace(error.getStackTrace());
	}
	
}

public function resetWindowPosition():void{
	// ウィンドウの位置情報保存
	try{
		// ウィンドウの位置情報保存を初期値で上書き
		EncryptedLocalStore.removeItem("controllerWindowPosition_x");
		var bytes:ByteArray = new ByteArray();
		bytes.writeDouble(0);
		EncryptedLocalStore.setItem("controllerWindowPosition_x", bytes);
		
		EncryptedLocalStore.removeItem("controllerWindowPosition_y");
		bytes = new ByteArray();
		bytes.writeDouble(0);
		EncryptedLocalStore.setItem("controllerWindowPosition_y", bytes);
		
		EncryptedLocalStore.removeItem("controllerWindowPosition_w");
		bytes = new ByteArray();
		bytes.writeDouble(380);
		EncryptedLocalStore.setItem("controllerWindowPosition_w", bytes);
		
		EncryptedLocalStore.removeItem("controllerWindowPosition_h");
		bytes = new ByteArray();
		bytes.writeDouble(520);
		EncryptedLocalStore.setItem("controllerWindowPosition_h", bytes);
		
	}catch(error:Error){
		Alert.show(Message.M_LOCAL_STORE_IS_BROKEN, Message.M_ERROR);
		logManager.addLog(Message.FAIL_LOAD_LOCAL_STORE_FOR_VIDEO_PLAYER + ":" + Message.M_LOCAL_STORE_IS_BROKEN + ":" + error);
		EncryptedLocalStore.reset();
		trace(error.getStackTrace());
	}
	
	if(this.nativeWindow != null && !(this as Window).closed){
		this.nativeWindow.x = 0;
		this.nativeWindow.y = 0;
		
		this.width = 380;
		this.height = 520;
	}
	
}

/**
 * 
 * @param urlList
 * @param videoNameList
 * @param playListName
 */
public function setPlayList(urlList:Array, videoNameList:Array, playListName:String):void{
	
	this.playListName = playListName;
	if(label_playListTitle != null){
		label_playListTitle.text = playListName;
	}else{
		canvas_playList.addEventListener(FlexEvent.CREATION_COMPLETE, function(event:FlexEvent):void{
			label_playListTitle.text = playListName;
		});
	}
	
	for each(var title:String in videoNameList){
		playListProvider.addItem(title);
	}
	
	for(var index:int = 0; index<urlList.length; index++){
		videoUrlMap[videoNameList[index]] = urlList[index];
	}
	
	if(this.dataGrid_playList != null){
//		(dataGrid_playList as DataGrid).validateDisplayList();
	}
}

/**
 * 
 * @param url
 * @param title
 * 
 */
public function addPlayListItem(url:String, title:String):void{
	
	videoUrlMap[title] = url;
	
}

/**
 * 
 * @param url
 * @param title
 * @param index
 * 
 */
public function addPlayListItemWithList(url:String, title:String, index:int):void{
	playListProvider.addItemAt(title,index);
	
	addPlayListItem(url, title);
	
	if(this.dataGrid_playList != null){
		(dataGrid_playList as DataGrid).dataProvider = playListProvider;
		(dataGrid_playList as DataGrid).validateDisplayList();
	}
	
}


/**
 * 
 * @param title
 * @param index
 * 
 */
public function removePlayListItem(index:int):void{
	var title:String = String(playListProvider.removeItemAt(index));
	
	//同名のファイルが存在しないかどうかチェック
	for each(var videoName:String in playListProvider){
		if(title == videoName){
			//存在するならvideoUrlMapからは消さない
			return;
		}
	}
	//存在しないならvideoUrlMapから消す
	videoUrlMap[title] = null;
	
	if(this.dataGrid_playList != null){
		(dataGrid_playList as DataGrid).dataProvider = playListProvider;
		(dataGrid_playList as DataGrid).validateDisplayList();
	}
}

/**
 * 
 * @return 
 * 
 */
public function getPlayList():Array{
	var array:Array = new Array();
	for(var i:int = 0; i<playListProvider.length; i++){
		array.push(String(playListProvider[i]));
	}
	
	var returnArray:Array = new Array();
	
	for each(var title:String in array){
		returnArray.push(videoUrlMap[title]);
	}
	
	return returnArray;
}

/**
 * プレイリスト内の項目の名前一覧を返します。
 * @return 
 * 
 */
public function getNameList():Array{
	var array:Array = new Array();
	for(var i:int = 0; i<playListProvider.length; i++){
		array.push(String(playListProvider[i]));
	}
	
	return array;
}

/**
 * 
 * 
 */
public function resetPlayList():void{
	this.playListName = "";
	if(label_playListTitle != null){
		label_playListTitle.text = playListName;
	}else{
		canvas_playList.addEventListener(FlexEvent.CREATION_COMPLETE, function(event:FlexEvent):void{
			label_playListTitle.text = playListName;
		});
	}
	
	videoUrlMap = new Object();
	
	playListProvider.removeAll();
	
	if(this.dataGrid_playList != null){
		(dataGrid_playList as DataGrid).dataProvider = playListProvider;
		(dataGrid_playList as DataGrid).validateDisplayList();
	}
}

/**
 * 
 * @param index
 * @return 
 * 
 */
public function getPlayListUrl(index:int):String{
	var videoTitle:String = playListProvider[index];
	
	return videoUrlMap[videoTitle];
}

/**
 * 
 * @param event
 * 
 */
public function playListDragDropHandler(event:DragEvent):void{
	if(event.dragInitiator == dataGrid_playList){
		
		//何もしない(デフォルトの並べ替えのみ実行)
		
	}else{
		
		//DataGridからのDrag。中身を詰め替える。
		
		if(event.dragInitiator as DataGrid){
			var selectedItems:Array = (event.dragInitiator as DataGrid).selectedItems;
			var addItems:Array = new Array();
			
			for(var i:int=0; i<selectedItems.length; i++){
				
				//ライブラリの場合
				var url:String = selectedItems[i].dataGridColumn_videoPath;
				if(url == null || url == ""){
					//ランキング or 検索でvideoPathが空だった場合
					url = selectedItems[i].dataGridColumn_nicoVideoUrl;
					
					if(url == null || url == ""){
						//マイリストだったとき
						url = selectedItems[i].dataGridColumn_videoLocalPath;
						
						if(url == null || url == ""){
							//マイリストでvideoLocalPathが空だったとき
							url = selectedItems[i].dataGridColumn_videoUrl;
							
							if(url == null || url == ""){
								//いずれでもない。
								continue;
							}
						}
					}
				}
				
				var title:String = selectedItems[i].dataGridColumn_videoName;
				var index:int = title.indexOf("\n");
				if(index != -1){
					//タイトルに改行が含まれている場合は改行の前を取得
					title = title.substring(0, index);
				}
				
				addItems.push(title);
				addPlayListItem(url, title);
			}
			
		}
		
		event.dragSource = new DragSource();
		event.dragSource.addData(addItems, "items");
	}
}

/**
 * 
 * @param event
 * 
 */
public function playListClearButtonClicked(event:MouseEvent):void{
	resetPlayList();
}

/**
 * 
 * @param event
 * 
 */
public function playListItemDeleteButtonClicked(event:MouseEvent):void{
	var selectedIndices:Array =  (dataGrid_playList as DataGrid).selectedIndices;
	
	for(var index:int = selectedIndices.length; index != 0; index--){
		removePlayListItem(selectedIndices[index-1]);
	}
}

/**
 * 
 * @param event
 * 
 */
public function playListSaveButtonClicked(event:MouseEvent):void{
	//1.プレイリストのファイルを物理的に追加（or置き換え）
	//2.プレイリストの一覧を再読み込み
	//3.プレイリストを再読み込み
	var urlArray:Array = new Array();
	var nameArray:Array = new Array();
	for each(var name:String in playListProvider){
		urlArray.push(videoUrlMap[name]);
		nameArray.push(name);
	}
	if(playListName == ""){
		playerController.addNewPlayList(urlArray, nameArray);
	}else{
		Application.application.activate();
		Alert.show("既存のプレイリスト(" + playListName + ")を上書きしますか？", Message.M_MESSAGE, Alert.OK | Alert.NO, null, function(event:CloseEvent):void{
			if(event.detail == Alert.OK){
				playerController.updatePlayList(playListName, urlArray, nameArray);
			}else{
				var title:String = playerController.addNewPlayList(urlArray, nameArray);
			}
		});
		
	}
	
}

/**
 * 
 * @param index
 * 
 */
public function showPlayingTitle(index:int):void{
	if(dataGrid_playList != null){
		(dataGrid_playList as DataGrid).scrollToIndex(index);
		(dataGrid_playList as DataGrid).selectedIndex = index;
	}else{
		canvas_playList.addEventListener(FlexEvent.CREATION_COMPLETE, function(event:FlexEvent):void{
			(dataGrid_playList as DataGrid).scrollToIndex(index);
			(dataGrid_playList as DataGrid).selectedIndex = index;
		});
	}
}

/**
 * 
 * @param event
 * 
 */
public function tagListDoubleClickEventHandler(event:ListEvent):void{
	if(event.itemRenderer.data != null){
		if(event.itemRenderer.data is String){
			var word:String = String(event.itemRenderer.data);
			Application.application.search(new SearchItem(word, SearchSortType.NEW, SearchType.TAG, word));
		}
	}
}

/**
 * 
 * @param event
 * 
 */
public function button_goToWebClicked(event:Event):void{
	this.playerController.watchOnWeb();
}

/**
 * 
 * @param event
 * 
 */
public function button_addDownloadList(event:Event):void{
	this.playerController.addDlList();
}

/**
 * 
 * @param event
 * 
 */
public function myListAddButtonClicked(event:Event):void{
	var selectedItem:Object = comboBox_mylist.selectedItem;
	
	if(selectedItem != null){
		var name:String = String(selectedItem);
		this.playerController.addMyList(myListMap[name]);
	
	}else{
		
	}
}

/**
 * 
 * @param myListNames
 * @param myListNums
 * 
 */
public function setMyLists(myListNames:Array, myListNums:Array):void{
	myListDataProvider = new Array();
	for(var i:int = 0; i<myListNames.length; i++){
		myListMap[myListNames[i]] = myListNums[i];
		myListDataProvider[i] = myListNames[i];
	}
	
	comboBox_mylist.dataProvider = myListDataProvider;
	
	if(myListDataProvider.length >= 1){
		comboBox_mylist.selectedIndex = 0;
	}
	
	comboBox_mylist.validateNow();
	
}

private function ownerTextLinkClicked(event:TextEvent):void{
	if(event.text.indexOf("mylist/") != -1){
//		trace(event.text);
		Application.application.renewMyList(event.text);
	}else if(event.text.indexOf("watch/") != -1){
		var videoId:String = PathMaker.getVideoID(event.text);
//		trace(videoId);
		playerController.playMovie("http://www.nicovideo.jp/watch/" + videoId);
	}else{
		trace(event);
	}
}

private function saveCommentButtonClicked(event:Event):void{
	new LocalCommentManager();
}

private function deleteCommentButtonClicked(event:Event):void{
	
}