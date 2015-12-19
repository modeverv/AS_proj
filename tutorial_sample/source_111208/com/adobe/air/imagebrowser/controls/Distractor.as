package com.adobe.air.imagebrowser.controls {
	import com.gskinner.motion.GTween;
	
	import flash.display.MovieClip;
	import flash.events.Event;

	public class Distractor extends MovieClip {
		
		protected var tween:GTween;
		protected var startAlpha:Number;
		
		public function Distractor() {
			super();
			tween = new GTween(this, .5, null, {autoPlay:false});
			tween.addEventListener(Event.COMPLETE, onTweenComplete, false, 0, true);
		}
		
		protected function onTweenComplete(p_event:Event):void {
			if (alpha == 0) {
				stop();
			} else {
				play();
			}
		}
		
		public function show(p_animate:Boolean = true):void {
			tween.setProperties({alpha:1});
			p_animate?tween.play():tween.end();
		}
		
		public function hide(p_animate:Boolean = true):void {
			tween.setProperties({alpha:0});
			p_animate?tween.play():tween.end();
		}
		
	}
}