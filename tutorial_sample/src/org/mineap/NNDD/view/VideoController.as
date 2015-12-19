/**
 * 
 * VideoController.as
 * 
 * Copyright (c) 2008-2009 MAP - MineApplicationProject. All Rights Reserved.
 * 
 */

import flash.data.EncryptedLocalStore;
import flash.display.StageDisplayState;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.ui.Mouse;
import flash.utils.ByteArray;
import flash.utils.Timer;

import org.mineap.NNDD.LogManager;
import org.mineap.NNDD.Message;
import org.mineap.NNDD.PlayerController;

import mx.containers.Canvas;
import mx.controls.Alert;
import mx.controls.HSlider;
import mx.controls.sliderClasses.Slider;
import mx.events.FlexEvent;
import mx.events.SliderEvent;


private var videoPlayer:VideoPlayer;
private var playerController:PlayerController;
private var logManager:LogManager;

private var bAlpha:Number = 2;
private var statusAlpha:Number = 2;
private var timer:Timer = null;

private var isMouseWheelChangeing:Boolean = false;
private var seekValue:int = 0;
private var seekTimer:Timer = null;

private var isRollOn:Boolean = false;

/**
 * 
 * @param playerController
 * @param videoPlayer
 * @param logManager
 * @param enableTimer
 * 
 */
public function init(playerController:PlayerController, videoPlayer:VideoPlayer, logManager:LogManager, enableTimer:Boolean = true):void{
	this.videoPlayer = videoPlayer;
	this.playerController = playerController;
	this.logManager = logManager;
	
	readStore();
	
	this.commentPostView.init(playerController, videoPlayer, playerController.videoInfoView);
	
	if(enableTimer){
		timer = new Timer(100);
		timer.addEventListener(TimerEvent.TIMER, hideController);
		timer.start();
	}
}

/**
 * アルファ値をリセットします。
 * 
 */
public function resetAlpha(isWithFocusReset:Boolean):void{
	bAlpha = 2;
	statusAlpha = 2;
	if(videoPlayer != null && !videoPlayer.videoInfoView.isHideUnderController && videoPlayer.stage.displayState != StageDisplayState.FULL_SCREEN_INTERACTIVE){
		(this as Canvas).visible = false;
	}else{
		(this as Canvas).visible = true;
	}
	if(videoPlayer != null){
		videoPlayer.text_shortCutInfo.visible = true;
		videoPlayer.label_playSourceStatus.visible = true;
		videoPlayer.button_ChangeFullScreen.visible = true;
		videoPlayer.label_economyStatus.visible = true;
		
		if(isWithFocusReset){
			this.videoPlayer.canvas_video_back.setFocus();
		}
	}
	
	Mouse.show();
	if(videoPlayer != null){
		this.videoPlayer.isMouseHide = false;
	}
}


/**
 * ストリーミング状況表示用ラベルのアルファ値のみをリセットします
 * 
 */
public function resetStatusAlpha():void{
	statusAlpha = 2;
}

private function hideController(event:TimerEvent):void{
	if(this.stage != null){
		var percent:int = playerController.getStreamingProgres();
		
		if(!isRollOn){
			if(bAlpha > 0){
				bAlpha -= 0.2;
				statusAlpha -= 0.2;
			}else if(statusAlpha > 0){
				bAlpha = 0;
				statusAlpha -= 0.2;
			}else{
				bAlpha = 0;
				statusAlpha = 0;
			}
		}
		
		if(bAlpha > 1){
			if(videoPlayer.stage.displayState != StageDisplayState.FULL_SCREEN_INTERACTIVE && !videoPlayer.videoInfoView.isHideUnderController){
				(this as Canvas).visible = false;
			}else{
				(this as Canvas).alpha = 1;
			}
			if(videoPlayer != null){
				videoPlayer.text_shortCutInfo.alpha = 1;
				videoPlayer.label_playSourceStatus.alpha = 1;
				videoPlayer.button_ChangeFullScreen.alpha = 1;
				videoPlayer.label_economyStatus.alpha = 1;
			}
		}else{
			if(videoPlayer.stage.displayState != StageDisplayState.FULL_SCREEN_INTERACTIVE && !videoPlayer.videoInfoView.isHideUnderController){
				(this as Canvas).visible = false;
			}else{
				(this as Canvas).alpha = bAlpha;
			}
			if(videoPlayer != null){
				videoPlayer.text_shortCutInfo.alpha = bAlpha;
				if(percent >= 100){
					videoPlayer.label_playSourceStatus.alpha = statusAlpha;
				}else{
					statusAlpha = 1;
					videoPlayer.label_playSourceStatus.alpha = statusAlpha;
				}
				videoPlayer.button_ChangeFullScreen.alpha = bAlpha;
				videoPlayer.label_economyStatus.alpha = bAlpha;
			}
		}
		if(bAlpha <= 0.5){
			(this as Canvas).visible = false;
			if(videoPlayer != null){
				videoPlayer.text_shortCutInfo.visible = false;
				if(percent >= 100 && statusAlpha <= 0.5){
					videoPlayer.label_playSourceStatus.visible = false;
				}else{
					videoPlayer.label_playSourceStatus.visible = true;
				}
				videoPlayer.button_ChangeFullScreen.visible = false;
				videoPlayer.label_economyStatus.visible = false;
				
				if(videoPlayer.stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE){
					if(videoPlayer.enableMouseHide()){
						Mouse.hide();
						videoPlayer.isMouseHide = true;
					}
				}
			}
		}
	}
}

private function mouseWheel(event:MouseEvent):void{
	
	if(event.currentTarget == this.slider_timeline){
		
		if(event.delta != 0){
			isMouseWheelChangeing = true;
			if(seekTimer != null){
				seekTimer.stop();
			}
			seekTimer = new Timer(100, 1);
			seekTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function(event:Event):void{
				var newValue:Number = slider_timeline.value + seekValue;
				if(newValue <= (slider_timeline as HSlider).minimum){
					newValue = 0;
				}else if(newValue >= (slider_timeline as HSlider).maximum){
					newValue = (slider_timeline as HSlider).maximum;
				}
//				trace(newValue +" = "+slider_timeline.value +"+"+ seekValue);
				playerController.seek(newValue);
				seekValue = 0;
				isMouseWheelChangeing = false;
			});
			seekTimer.start();
			this.seekValue += event.delta;
		}
		
	}else if(event.currentTarget == this.slider_volume){
		this.playerController.setVolume(this.slider_volume.value + event.delta / 20);
	}
}

public function rollOver(event:MouseEvent):void{
	isRollOn = true;
}

public function rollOut(event:MouseEvent):void{
	isRollOn = false;
}

private function play():void{
	this.playerController.play();
}

private function stop():void{
	this.playerController.stop();
}

private function thumbPress(event:SliderEvent):void{
	this.playerController.sliderChanging = true;
}

private function thumbRelease(event:SliderEvent):void{
	this.playerController.sliderChanging = false;
	this.playerController.seek(event.value);
}

private function sliderTimelineChanged(evt:SliderEvent):void{
	if(this.playerController.sliderChanging){
		this.slider_timeline.value = evt.value;
	}else{
		this.playerController.seek(evt.value);
	}
}
private function sliderVolumeChanged(evt:SliderEvent):void{
	this.playerController.setVolume(evt.value);	
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

private function readStore():void{
	try{
		var storedValue:ByteArray = EncryptedLocalStore.getItem("volume");
		if(storedValue != null){
			var volume:Number = storedValue.readDouble();
			if(this.slider_volume != null){
				this.slider_volume.value = volume;
			}else{
				this.addEventListener(FlexEvent.ADD, function():void{
					slider_volume.value = volume;
				});
			}
			
		}
		
	}catch(error:Error){
		EncryptedLocalStore.reset();
		Alert.show(Message.M_LOCAL_STORE_IS_BROKEN, Message.M_ERROR);
		logManager.addLog(Message.FAIL_LOAD_LOCAL_STORE_FOR_VIDEO_CONTROLLER + ":" + Message.M_LOCAL_STORE_IS_BROKEN);
	}
}

public function saveStore():void{
	try{
		trace("saveStore");
		//音量保存
		
		EncryptedLocalStore.removeItem("volume");
		var bytes:ByteArray = new ByteArray();
		bytes.writeDouble(this.slider_volume.value);
		EncryptedLocalStore.setItem("volume", bytes);
	}catch(error:Error){
		trace(error);
	}
}

public function setControlEnable(isEnable:Boolean):void{
	(button_play as Button).enabled = isEnable;
//	(button_stop as Button).enabled = isEnable;
	(slider_timeline as Slider).enabled = isEnable;
}