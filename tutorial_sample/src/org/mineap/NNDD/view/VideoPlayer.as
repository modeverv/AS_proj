/**
 * VideoPlayer.as
 * 
 * Copyright (c) 2008-2009 MAP - MineApplicationProject. All Rights Reserved.
 *  
 * @author shiraminekeisuke
 * 
 */	

import flash.data.EncryptedLocalStore;
import flash.desktop.ClipboardFormats;
import flash.desktop.NativeDragManager;
import flash.display.NativeWindowDisplayState;
import flash.display.StageDisplayState;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.NativeDragEvent;
import flash.events.NativeWindowBoundsEvent;
import flash.events.TextEvent;
import flash.filesystem.File;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.ui.Keyboard;
import flash.utils.ByteArray;
import flash.utils.Timer;

import mx.collections.ArrayCollection;
import mx.containers.Canvas;
import mx.controls.Alert;
import mx.controls.Button;
import mx.controls.HSlider;
import mx.controls.Text;
import mx.controls.TextArea;
import mx.core.Application;
import mx.core.UITextField;
import mx.core.Window;
import mx.events.FlexEvent;
import mx.events.ListEvent;
import mx.events.ResizeEvent;
import mx.managers.PopUpManager;

import org.mineap.NNDD.LogManager;
import org.mineap.NNDD.Message;
import org.mineap.NNDD.PlayerController;
import org.mineap.NNDD.model.SearchItem;
import org.mineap.NNDD.model.SearchSortType;
import org.mineap.NNDD.model.SearchType;
import org.mineap.NNDD.util.PathMaker;


public var isAlwaysFront:Boolean = false;

public var isNicowariShow:Boolean = true;

private var playerController:PlayerController;
public var videoInfoView:VideoInfoView;
private var storeWidth:Number = 40;

public var isResize:Boolean = false;

public var lastRect:Rectangle = null;

private var logManager:LogManager;

private var videoPlayer:VideoPlayer;

private var text_key_info:Text;

private var isUnderControllerHideComplete:Boolean = true;

private var seekTimer:Timer;
private var seekValue:Number = 0;

private var _copyVideoInfoView:VideoInfoView = null;

private var _jumpDialog:JumpDialog = null;

private var isMouseHideEnable:Boolean = false;

public var isMouseHide:Boolean = false;

[Bindable]
public var textAreaTagProvider:String = "";

public function init(playerController:PlayerController, videoInfoView:VideoInfoView, logManager:LogManager):void
{
	this.videoPlayer = this;
	this.videoInfoView = videoInfoView;
	this.logManager = logManager;
	this.playerController = playerController;
	
	this.addEventListener(FlexEvent.CREATION_COMPLETE, function(event:FlexEvent):void{
		videoController.init(playerController, videoPlayer, logManager);
		videoController_under.init(playerController, videoPlayer, logManager, false);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyListener);
		stage.addEventListener(KeyboardEvent.KEY_UP, keyUpListener);
		stage.addEventListener(MouseEvent.MOUSE_OVER, mouseOverEventHandler);
		stage.addEventListener(MouseEvent.MOUSE_OUT, mouseOutEventHandler);
		stage.addEventListener(FullScreenEvent.FULL_SCREEN, fullScreen);
		playerController.resizePlayerJustVideoSize(null);
		videoController.resetAlpha(true);
	});
	
	readStore();
		
}

public function resetInfo():void{
	this.textAreaTagProvider = "";
	this.title = "Player - NNDD";
}

/**
 * 
 * @param tags
 * 
 */
public function setTagArray(tags:Array):void{
	var text:String = "";
	for each(var tag:String in tags){
		if(tag.indexOf("(取得できなかった") == -1 && tag.indexOf("(タグ情報の取得に失敗)") == -1 ){
			text += "<a href=\"event:" + tag + "\"><u><font color=\"#0000ff\">" + tag + "</font></u></a>  ";
		}else{
			text += tag + "  ";
		}
	}
	
	this.textAreaTagProvider = text;
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

private function mouseMove(event:MouseEvent):void{
	this.videoController.resetAlpha(false);
}

private function windowResized(event:NativeWindowBoundsEvent):void{
	lastRect = event.afterBounds;
	followInfoView(lastRect)
}

private function windowMove(event:NativeWindowBoundsEvent):void{
	lastRect = event.afterBounds;
	followInfoView(lastRect)
}

public function followInfoView(lastRect:Rectangle):void{
	if(lastRect != null && this.videoInfoView != null 
			&& this.videoInfoView.visible 
			&& this.videoInfoView.nativeWindow.displayState != NativeWindowDisplayState.MINIMIZED // infoViewが最小化されていない
			&& this.nativeWindow.displayState != NativeWindowDisplayState.MINIMIZED 	// videoPlayerが最小化されていない
			&& this.videoInfoView.isPlayerFollow 										// 追従が有効になっている
			&& this.stage.displayState != StageDisplayState.FULL_SCREEN_INTERACTIVE){	// videoPlayerがフルスクリーンではない
		this.videoInfoView.nativeWindow.x = lastRect.x + lastRect.width;
		this.videoInfoView.nativeWindow.y = lastRect.y;
	}
}

private function windowClosing(event:Event):void{
	
	this.playerController.isPlayerClosing = true;
	
	if(this.stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE){
		this.videoInfoView.changeFull();
	}
	
	(this as Window).restore();
	
	saveStore();
	
	if(canvas_video != null){
		canvas_video.removeAllChildren();
	}
	
	this.playerController.saveNgList();
	
	this.playerController.stop();
	
	this.playerController.destructor();
	
}

private function windowClosed():void{
	
	if(this.videoInfoView != null && !this.videoInfoView.closed){
		this.videoInfoView.close();
	}
	
	this.playerController.destructor();
}

public function getCommentListProvider():ArrayCollection{
	return this.videoInfoView.commentListProvider;
}

public function label_playSourceStatusInit(event:Event):void{
	
	label_playSourceStatus.setStyle("color", new int("0xFFFFFF"));
	label_playSourceStatus.setStyle("fontAntiAliasType", flash.text.AntiAliasType.ADVANCED);
	var filterArray:Array = new Array();
	filterArray.push(new DropShadowFilter(1));
	label_playSourceStatus.filters = filterArray;	
}

public function label_economyStatusInit(event:Event):void{
	label_economyStatus.setStyle("color", new int("0xFFFFFF"));
	label_economyStatus.setStyle("fontAntiAliasType", flash.text.AntiAliasType.ADVANCED);
	var filterArray:Array = new Array();
	filterArray.push(new DropShadowFilter(1));
	label_economyStatus.filters = filterArray;	
	
}

public function text_shortCutInit(event:Event):void{
	text_shortCutInfo.text = Message.L_SHORTCUT_INFO;
	
	text_shortCutInfo.setStyle("color", new int("0xFFFFFF"));
	text_shortCutInfo.setStyle("fontAntiAliasType", flash.text.AntiAliasType.ADVANCED);
	var filterArray:Array = new Array();
	filterArray.push(new DropShadowFilter(1));
	text_shortCutInfo.filters = filterArray;		
}

private function fullScreen(event:FullScreenEvent):void{
	
	if(event.fullScreen){
		this.videoInfoView.button_full.label = Message.L_NORMAL;
		this.videoPlayer.button_ChangeFullScreen.label = Message.L_NORMAL;
		showUnderController(false, false);
		showTagArea(false, false);
		
		vbox_videoPlayer.setConstraintValue("bottom", 0);
		vbox_videoPlayer.setConstraintValue("left", 0);
		vbox_videoPlayer.setConstraintValue("right", 0);
		vbox_videoPlayer.setConstraintValue("top", 0);
		vbox_videoPlayer.setConstraintValue("backgroundColor", new int("0x000000"));
		this.showStatusBar = false;
		
	}else{
		//このイベントはキャッチされない？
		trace("ESC_fullScreen");
		vbox_videoPlayer.setConstraintValue("bottom", 5);
		vbox_videoPlayer.setConstraintValue("left", 5);
		vbox_videoPlayer.setConstraintValue("right", 5);
		vbox_videoPlayer.setConstraintValue("top", 58);
		vbox_videoPlayer.setConstraintValue("backgroundColor", new int("0xb7babc"));
		this.showStatusBar = true;
		this.videoInfoView.button_full.label = Message.L_FULL;
		this.videoPlayer.button_ChangeFullScreen.label = Message.L_FULL;
		if(this.videoInfoView.isHideUnderController){
			showUnderController(false, false);
		}else{
			showUnderController(true, false);
		}
		if(this.videoInfoView.isHideTagArea){
			showTagArea(false, false);
		}else{
			showTagArea(true, false);
		}
		
	}
	
	//ウィンドウの色の即時適応
	(this as Window).validateNow();
	
	Mouse.show();
	isMouseHide = false;
	
}

public function showUnderController(isShow:Boolean, isChangeWindowSize:Boolean = true):void{
	
	//下プレーヤを見せるか見せないか設定。
	if(!isShow){ //見せない
		(this.canvas_under as Canvas).height = 0;
		if(isChangeWindowSize){
			this.nativeWindow.height = this.nativeWindow.height - 60;
		}
	}else{ //見せる
		(this.canvas_under as Canvas).height = 60;
		if(isChangeWindowSize){
			this.nativeWindow.height = this.nativeWindow.height + 60;
		}
	}
	
}

public function showTagArea(isShow:Boolean, isChangeWindowSize:Boolean = true):void{
	
	//タグ領域を見せるかどうかの設定
	if(!isShow){	// 隠す
		(this.textArea_tag as TextArea).height = 0;
		vbox_videoPlayer.setConstraintValue("top", 0);
		if(isChangeWindowSize){
			this.nativeWindow.height = this.nativeWindow.height - 50;
		}
	}else{	// 表示
		(this.textArea_tag as TextArea).height = 50;
		vbox_videoPlayer.setConstraintValue("top", 58);
		if(isChangeWindowSize){
			this.nativeWindow.height = this.nativeWindow.height + 50;
		}
	}
	
}

private function keyUpListener(event:KeyboardEvent):void{
	if(event.keyCode == Keyboard.SPACE){
		if(!(event.target is Button) && !(event.target is TextField)){
			this.playerController.play();
		}
	}
}

private function keyListener(event:KeyboardEvent):void{
//	trace(event.keyCode);
	if(event.keyCode == Keyboard.ESCAPE){
		//Windowsだとこのイベントはキャッチされない？
		trace("ESC");
		this.videoInfoView.button_full.label = Message.L_FULL;
		if(this.videoInfoView.isHideUnderController){
			showUnderController(false, false);
		}else{
			showUnderController(true, false);
		}
		if(this.videoInfoView.isHideTagArea){
			showTagArea(false, false);
		}else{
			showTagArea(true, false);
		}
		
	}else if(event.keyCode == Keyboard.F11 || (event.keyCode == Keyboard.F && (event.controlKey || event.commandKey))){
//		trace("Ctrl + " + event.keyCode);
		this.videoInfoView.changeFull();
	}else if(event.keyCode == Keyboard.C){
		trace(event.keyCode + ":" + event);
		this.videoInfoView.stage.nativeWindow.activate();
	}else if(event.keyCode == Keyboard.LEFT){
		//左キー。戻る
		if(event.target as UITextField){
			return;
		}
		if(seekTimer != null){
			seekTimer.stop();
		}
		seekTimer = new Timer(100, 1);
		seekTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function(event:Event):void{
			var newValue:Number = videoController.slider_timeline.value + seekValue;
			if(newValue <= (videoController.slider_timeline as HSlider).minimum){
				newValue = 0;
			}else if(newValue >= (videoController.slider_timeline as HSlider).maximum){
				newValue = (videoController.slider_timeline as HSlider).maximum;
			}
			trace(newValue +" = "+videoController.slider_timeline.value +"+"+ seekValue);
			playerController.seek(newValue);
			seekValue = 0;
		});
		seekTimer.start();
		this.seekValue -= 10;
	}else if(event.keyCode == Keyboard.RIGHT){
		//右キー。進む。
		if(event.target as UITextField){
			return;
		}
		if(seekTimer != null){
			seekTimer.stop();
		}
		seekTimer = new Timer(100, 1);
		seekTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function(event:Event):void{
			var newValue:Number = videoController.slider_timeline.value + seekValue;
			if(newValue <= (videoController.slider_timeline as HSlider).minimum){
				newValue = 0;
			}else if(newValue >= (videoController.slider_timeline as HSlider).maximum){
				newValue = (videoController.slider_timeline as HSlider).maximum;
			}
			trace(newValue +" = "+videoController.slider_timeline.value +"+"+ seekValue);
			playerController.seek(newValue);
			seekValue = 0;
		});
		seekTimer.start();
		this.seekValue += 10;
	}else if(event.keyCode == Keyboard.UP){
		this.playerController.setVolume(this.videoController.slider_volume.value + 0.05);
	}else if(event.keyCode == Keyboard.DOWN){
		this.playerController.setVolume(this.videoController.slider_volume.value - 0.05);
	}
}

public function rollOver(event:MouseEvent):void{
	this.videoController.rollOver(event);
}

public function rollOut(event:MouseEvent):void{
	this.videoController.rollOut(event);
}

public function videoCanvasResize(event:ResizeEvent):void{
	this.playerController.windowResized();
}

private function readStore():void{
	
	try{
		
		/*ローカルストアから値の呼び出し*/
		var storedValue:ByteArray = EncryptedLocalStore.getItem("isAlwaysFront");
		if(storedValue != null){
			isAlwaysFront = storedValue.readBoolean();
		}
		
		//x,y,w,h
//		storedValue = EncryptedLocalStore.getItem("playerVersion");
//		//インストール直後の初回起動ではウィンドウの大きさを反映しない。
//		if(storedValue != null){
//			if(storedValue.readUTFBytes(storedValue.length) == NNDD.PLAYER_VERSION){
	
				storedValue = EncryptedLocalStore.getItem("playerWindowPosition_x");
				if(storedValue != null){
					var windowPosition_x:Number = storedValue.readDouble();
					this.addEventListener(FlexEvent.CREATION_COMPLETE, function():void{
						nativeWindow.x = lastRect.x = windowPosition_x;
					});
				}
				storedValue = EncryptedLocalStore.getItem("playerWindowPosition_y");
				if(storedValue != null){
					var windowPosition_y:Number = storedValue.readDouble();
					this.addEventListener(FlexEvent.CREATION_COMPLETE, function():void{
						nativeWindow.y = lastRect.y = windowPosition_y;
					});
				}
				storedValue = EncryptedLocalStore.getItem("playerWindowPosition_w");
				if(storedValue != null){
					var windowPosition_w:Number = storedValue.readDouble();
					this.addEventListener(FlexEvent.CREATION_COMPLETE, function():void{
						nativeWindow.width = lastRect.width = windowPosition_w;
					});
				}
				storedValue = EncryptedLocalStore.getItem("playerWindowPosition_h");
				if(storedValue != null){
					var windowPosition_h:Number = storedValue.readDouble();
					this.addEventListener(FlexEvent.CREATION_COMPLETE, function():void{
						nativeWindow.height = lastRect.height = windowPosition_h;
					});
//				}
//			}
		}else{
			this.addEventListener(FlexEvent.CREATION_COMPLETE, function():void{
				nativeWindow.height = lastRect.height = 540;
				nativeWindow.width = lastRect.width = 550;
			});
		}
		
	}catch(error:Error){
		Alert.show(Message.M_LOCAL_STORE_IS_BROKEN, Message.M_ERROR);
		logManager.addLog(Message.FAIL_LOAD_LOCAL_STORE_FOR_VIDEO_PLAYER + ":" + Message.M_LOCAL_STORE_IS_BROKEN + ":" + error);
		EncryptedLocalStore.reset();
		trace(error.getStackTrace());
	}
	
}

public function saveStore():void{
	
	try{
		
		/*ローカルストアに値を保存*/
		EncryptedLocalStore.removeItem("isAlwaysFront");
		var bytes:ByteArray = new ByteArray();
		bytes.writeBoolean(isAlwaysFront);
		EncryptedLocalStore.setItem("isAlwaysFront", bytes);
		
		// Playerバージョン保存
		EncryptedLocalStore.removeItem("playerVersion");
		bytes = new ByteArray();
		bytes.writeUTFBytes(Application.application.version);
		EncryptedLocalStore.setItem("playerVersion", bytes);
		
		// ウィンドウの位置情報保存
		EncryptedLocalStore.removeItem("playerWindowPosition_x");
		bytes = new ByteArray();
		bytes.writeDouble(lastRect.x);
		EncryptedLocalStore.setItem("playerWindowPosition_x", bytes);
		
		EncryptedLocalStore.removeItem("playerWindowPosition_y");
		bytes = new ByteArray();
		bytes.writeDouble(lastRect.y);
		EncryptedLocalStore.setItem("playerWindowPosition_y", bytes);
		
		EncryptedLocalStore.removeItem("playerWindowPosition_w");
		bytes = new ByteArray();
		bytes.writeDouble(lastRect.width);
		EncryptedLocalStore.setItem("playerWindowPosition_w", bytes);
		
		EncryptedLocalStore.removeItem("playerWindowPosition_h");
		bytes = new ByteArray();
		bytes.writeDouble(lastRect.height);
		EncryptedLocalStore.setItem("playerWindowPosition_h", bytes);
		
		this.videoController.saveStore();
		
	}catch(error:Error){
		Alert.show(Message.M_LOCAL_STORE_IS_BROKEN, Message.M_ERROR);
		logManager.addLog(Message.FAIL_LOAD_LOCAL_STORE_FOR_VIDEO_PLAYER + ":" + Message.M_LOCAL_STORE_IS_BROKEN + ":" + error);
		EncryptedLocalStore.reset();
		trace(error.getStackTrace());
	}
	
}

/**
 * ニコ割領域を表示するかどうかを設定します
 * @param isShowNicowariArea
 * 
 */
public function setShowAlwaysNicowariArea(isShowNicowariArea:Boolean):void{
	isNicowariShow = isShowNicowariArea;
	isResize = true;
	if(isNicowariShow == true){
		(canvas_nicowari as Canvas).percentHeight = 15;
	}else{
		(canvas_nicowari as Canvas).percentHeight = 0;
	}
}

/**
 * ニコ割領域を表示します。
 * 
 */
public function showNicowariArea():void{
	if(canvas_nicowari != null){
		(canvas_nicowari as Canvas).percentHeight = 15;
	}
}

/**
 * ニコ割領域を隠します。
 * 
 */
public function hideNicowariArea():void{
	if(canvas_nicowari != null){
		(canvas_nicowari as Canvas).percentHeight = 0;
	}
}


private function panelDoubleClicked(event:MouseEvent):void{
	isResize = true;
	if(isNicowariShow == false){
		(canvas_nicowari as Canvas).percentHeight = 15;
		isNicowariShow = true;
	}else{
		(canvas_nicowari as Canvas).percentHeight = 0;
		isNicowariShow = false;
	}
	
	videoInfoView.setShowAlwaysNicowariArea(isNicowariShow);
	
}

private function updateComplete():void{
	if(isResize){
		isResize = false;
//		trace("updateComplete");
		playerController.windowResized();
	}
}

public function resetWindowPosition():void{
	// ウィンドウの位置情報保存
	try{
		// ウィンドウの位置情報保存
		EncryptedLocalStore.removeItem("playerWindowPosition_x");
		var bytes:ByteArray = new ByteArray();
		bytes.writeDouble(0);
		EncryptedLocalStore.setItem("playerWindowPosition_x", bytes);
		
		EncryptedLocalStore.removeItem("playerWindowPosition_y");
		bytes = new ByteArray();
		bytes.writeDouble(0);
		EncryptedLocalStore.setItem("playerWindowPosition_y", bytes);
		
		EncryptedLocalStore.removeItem("playerWindowPosition_w");
		bytes = new ByteArray();
		bytes.writeDouble(550);
		EncryptedLocalStore.setItem("playerWindowPosition_w", bytes);
		
		EncryptedLocalStore.removeItem("playerWindowPosition_h");
		bytes = new ByteArray();
		bytes.writeDouble(540);
		EncryptedLocalStore.setItem("playerWindowPosition_h", bytes);
		
	}catch(error:Error){
		Alert.show(Message.M_LOCAL_STORE_IS_BROKEN, Message.M_ERROR);
		logManager.addLog(Message.FAIL_LOAD_LOCAL_STORE_FOR_VIDEO_PLAYER + ":" + Message.M_LOCAL_STORE_IS_BROKEN + ":" + error);
		EncryptedLocalStore.reset();
		trace(error.getStackTrace());
	}
	
	if(this.nativeWindow != null && !(this as Window).closed){
		this.nativeWindow.x = 0;
		this.nativeWindow.y = 0;
		
		this.width = 540;
		this.height = 550;
	}
	
}

private function resizeNow(event:ResizeEvent):void{
	isResize = true;
	followInfoView(lastRect);
}

private function canvasVideoDroped(event:NativeDragEvent):void{
	if(event.clipboard.hasFormat(ClipboardFormats.TEXT_FORMAT)){
		var url:String = (event.clipboard.getData(ClipboardFormats.TEXT_FORMAT) as String);
		if(url != null && url.match(new RegExp("http://www.nicovideo.jp/watch/|file:///")) != null){
			playerController.playMovie(url);
			return;
		}
		var videoId:String = PathMaker.getVideoID(url);
		if(videoId != null){
			url = "http://www.nicovideo.jp/watch/" + videoId;
			playerController.playMovie(url);
			return;
		}
	}else if(event.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT)){
		var array:Array = (event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array);
		if(array != null && (array[0] as File).url.match(new RegExp("http://www.nicovideo.jp/watch/|file:///")) != null){
			playerController.playMovie(array[0].url);
		}
	}
}

private function canvasVideoDragEnter(event:NativeDragEvent):void{
	if(event.clipboard.hasFormat(ClipboardFormats.TEXT_FORMAT) || event.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT)){
		NativeDragManager.acceptDragDrop(canvas_video);
	}
}

public function setControllerEnable(isEnable:Boolean):void{
	if(this.nativeWindow != null && !this.closed){
		if(videoController != null){
			videoController.setControlEnable(isEnable);
		}
		if(videoController_under != null){
			videoController_under.setControlEnable(isEnable);
		}
	}
}

private function changeFullButtonClicked(event:MouseEvent):void{
	if(this.playerController != null && this.playerController.videoInfoView != null ){
		this.playerController.videoInfoView.changeFull();
		// ボタンからフォーカスをずらす
//		(this.focusManager as FocusManager).moveFocus(FocusRequestDirection.BACKWARD);
		(this.canvas_video_back as Canvas).setFocus();
	}
}
public function showAskToUserOnJump(open:Function, cancel:Function, videoId:String):void{
	_jumpDialog = PopUpManager.createPopUp(this, JumpDialog, true) as JumpDialog;
	_jumpDialog.setVideoId(videoId);
	PopUpManager.centerPopUp(_jumpDialog);
	_jumpDialog.addEventListener(Event.OPEN, function(event:Event):void{
		PopUpManager.removePopUp(_jumpDialog);
		open.call();
		_jumpDialog = null;
	});
	_jumpDialog.addEventListener(Event.CANCEL, function(event:Event):void{
		PopUpManager.removePopUp(_jumpDialog);
		cancel.call();
		_jumpDialog = null;
	});
}

public function enableMouseHide():Boolean{
	if(_jumpDialog == null && isMouseHideEnable){
		return true;
	}else{
		return false;
	}
}


private function mouseOverEventHandler(event:MouseEvent):void{
	
	isMouseHideEnable = true;
	
}

private function mouseOutEventHandler(event:MouseEvent):void{
	if(event.stageX == -1 && event.stageY == -1){
		isMouseHideEnable = false;
	}
}

private function infoAreaLinkClicked(event:TextEvent):void{
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

private function tagTextAreaLinkClikced(event:TextEvent):void{
	var word:String = String(event.text);
	Application.application.search(new SearchItem(word, SearchSortType.NEW, SearchType.TAG, word));
}