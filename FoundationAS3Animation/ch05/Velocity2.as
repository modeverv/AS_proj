﻿package
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class Velocity2 extends Sprite
	{
		private var ball:Ball;
		private var vx:Number = 5;
		private var vy:Number = 5;
		
		public function Velocity2()
		{
			init();
		}
		
		private function init():void
		{
			ball = new Ball();
			addChild(ball);
			ball.x = 50;
			ball.y = 100;
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		private function onEnterFrame(event:Event):void
		{
			ball.x += vx;
			ball.y += vy;
		}
	}
}
