﻿package
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class ShapeFlag extends Sprite
	{
		private var ball:Ball;
		
		public function ShapeFlag()
		{
			init();
		}
		
		private function init():void
		{
			ball = new Ball();
			addChild(ball);
			ball.x = stage.stageWidth / 2;
			ball.y = stage.stageHeight / 2;
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);			
		}
		
		private function onEnterFrame(event:Event):void
		{
			if(ball.hitTestPoint(mouseX, mouseY, true))
			{
				trace("ヒット");
			}
		}
	}
}
