package jp.fores.common.controls
{
	import flash.display.DisplayObject;
	import flash.display.StageDisplayState;
	import flash.events.*;
	
	import mx.controls.VideoDisplay;
	import mx.core.mx_internal;
	
	use namespace mx_internal;
	
	public class FSVideoDisplay extends VideoDisplay
	{
		private var _displayState:String = StageDisplayState.NORMAL;
	
		[Inspectable(category="General", enumeration="normal,fullScreen", defaultValue="normal")]
	
		/**
		 *  Specifies whether the object is in full-screen mode.
		 *
		 *  @see flash.display.Stage#displayState
		 *  @default StageDisplayState.NORMAL
		 */
		public function get displayState():String
		{
			return _displayState;
		}
		public function set displayState(value:String):void
		{
			if (value != _displayState)
			{
				_displayState = value;
	
				if (_displayState == StageDisplayState.FULL_SCREEN)
				{
					stage.addEventListener(FullScreenEvent.FULL_SCREEN, handleFullScreen);
	
					// Move video player to stage
					videoPlayer.visible = false;
					//stage.addChild(videoPlayer);
				}
	
				stage.displayState = _displayState;
			}
		}
	
		override protected function updateDisplayList(unscaledWidth:Number,
				unscaledHeight:Number):void
		{
			if (displayState == StageDisplayState.NORMAL){
				super.updateDisplayList(unscaledWidth, unscaledHeight);
			}else{
				// In full-screen mode, run layout with stage co-ordinates
				super.updateDisplayList(stage.stageWidth, stage.stageHeight);
			}
		}
	
		private function handleFullScreen(event:FullScreenEvent):void
		{
			if (stage.displayState == StageDisplayState.NORMAL)
			{
				stage.removeEventListener(FullScreenEvent.FULL_SCREEN, handleFullScreen);
	
				if (border)
					addChild(DisplayObject(border));
	
				addChild(videoPlayer);
				invalidateDisplayList();
			}
			else 
			{
				if (border)
					// Move border to stage, just behind video player
					stage.addChild(DisplayObject(border));
					stage.addChild(videoPlayer);
					//stage.addChildAt(DisplayObject(border), stage.getChildIndex(videoPlayer));
	
				invalidateDisplayList();
				videoPlayer.visible = true;
			}
	
			_displayState = stage.displayState;
		}
	}
}