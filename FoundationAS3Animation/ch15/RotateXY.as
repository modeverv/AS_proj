﻿package {
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;

	public class RotateXY extends Sprite
	{
		private var balls:Array;
		private var numBalls:uint = 50;
		private var fl:Number = 250;
		private var vpX:Number = stage.stageWidth / 2;
		private var vpY:Number = stage.stageHeight / 2;
		
		public function RotateXY()
		{
			init();
		}
		
		private function init():void
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			balls = new Array();
			for(var i:uint = 0; i < numBalls; i++)
			{
				var ball:Ball3D = new Ball3D(15);
				balls.push(ball);
				ball.xpos = Math.random() * 200 - 100;
				ball.ypos = Math.random() * 200 - 100;
				ball.zpos = Math.random() * 200 - 100;
				addChild(ball);
			}
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(event:Event):void
		{
			var angleX:Number = (mouseY - vpY) * .001;
			var angleY:Number = (mouseX - vpX) * .001;
			for(var i:uint = 0; i < numBalls; i++)
			{
				var ball:Ball3D = balls[i];
				rotateX(ball, angleX);
				rotateY(ball, angleY);
				doPerspective(ball);
			}
			sortZ();
		}
		
		private function rotateX(ball:Ball3D, angleX:Number):void
		{
			var cosX:Number = Math.cos(angleX);
			var sinX:Number = Math.sin(angleX);
			
			var y1:Number = ball.ypos * cosX - ball.zpos * sinX;
			var z1:Number = ball.zpos * cosX + ball.ypos * sinX;
			
			ball.ypos = y1;
			ball.zpos = z1;
		}
		private function rotateY(ball:Ball3D, angleY:Number):void
		{
			var cosY:Number = Math.cos(angleY);
			var sinY:Number = Math.sin(angleY);
			
			var x1:Number = ball.xpos * cosY - ball.zpos * sinY;
			var z1:Number = ball.zpos * cosY + ball.xpos * sinY;
			
			ball.xpos = x1;
			ball.zpos = z1;
		}
		
		private function doPerspective(ball:Ball3D):void
		{			
			if(ball.zpos > -fl)
			{
				var scale:Number = fl / (fl + ball.zpos);
				ball.scaleX = ball.scaleY = scale;
				ball.x = vpX + ball.xpos * scale;
				ball.y = vpY + ball.ypos * scale;
				ball.visible = true;
			}
			else
			{
				ball.visible = false;
			}
		}
		
		private function sortZ():void
		{
			balls.sortOn("zpos", Array.DESCENDING | Array.NUMERIC);
			for(var i:uint = 0; i < numBalls; i++)
			{
				var ball:Ball3D = balls[i];
				setChildIndex(ball, i);
			}
		}
	}
}
