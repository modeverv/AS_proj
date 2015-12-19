﻿package {
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	public class MovingCube extends Sprite
	{
		private var points:Array;
		private var triangles:Array;
		private var fl:Number = 250;
		private var vpX:Number = stage.stageWidth / 2;
		private var vpY:Number = stage.stageHeight / 2;
		private var offsetX:Number = 0;
		private var offsetY:Number = 0;
		
		public function MovingCube()
		{
			init();
		}
		
		private function init():void
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			points = new Array();
			// 前の4隅
			points[0] = new Point3D(-100, -100, -100);
			points[1] = new Point3D( 100, -100, -100);
			points[2] = new Point3D( 100,  100, -100);
			points[3] = new Point3D(-100,  100, -100);
			// 後の4隅
			points[4] = new Point3D(-100, -100,  100);
			points[5] = new Point3D( 100, -100,  100);
			points[6] = new Point3D( 100,  100,  100);
			points[7] = new Point3D(-100,  100,  100);
			for(var i:uint = 0; i < points.length; i++)
			{
				points[i].setVanishingPoint(vpX, vpY);
				points[i].setCenter(0, 0, 200);
			}
			
			triangles = new Array();
			// 正面
			triangles[0] = new Triangle(points[0], points[1], points[2], 0x6666cc);
			triangles[1] = new Triangle(points[0], points[2], points[3], 0x6666cc);
			// 上面
			triangles[2] = new Triangle(points[0], points[5], points[1], 0x66cc66);
			triangles[3] = new Triangle(points[0], points[4], points[5], 0x66cc66);
			// 背面
			triangles[4] = new Triangle(points[4], points[6], points[5], 0xcc6666);
			triangles[5] = new Triangle(points[4], points[7], points[6], 0xcc6666);
			// 底面
			triangles[6] = new Triangle(points[3], points[2], points[6], 0xcc66cc);
			triangles[7] = new Triangle(points[3], points[6], points[7], 0xcc66cc);
			// 右側面
			triangles[8] = new Triangle(points[1], points[5], points[6], 0x66cccc);
			triangles[9] = new Triangle(points[1], points[6], points[2], 0x66cccc);
			// 左側面
			triangles[10] = new Triangle(points[4], points[0], points[3], 0xcccc66);
			triangles[11] = new Triangle(points[4], points[3], points[7], 0xcccc66);
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		private function onEnterFrame(event:Event):void
		{
			var angleX:Number = (mouseY - vpY) * .001;
			var angleY:Number = (mouseX - vpX) * .001;
			for(var i:uint = 0; i < points.length; i++)
			{
				var point:Point3D = points[i];
				point.rotateX(angleX);
				point.rotateY(angleY);
			}
			
			graphics.clear();
			for(i = 0; i < triangles.length; i++)
			{
				triangles[i].draw(graphics);
			}
		}
		
		private function onKeyDown(event:KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.LEFT)
			{
				offsetX -= 5;
			}
			else if(event.keyCode == Keyboard.RIGHT)
			{
				offsetX += 5;
			}
			else if(event.keyCode == Keyboard.UP)
			{
				offsetY -= 5;
			}
			else if(event.keyCode == Keyboard.DOWN)
			{
				offsetY += 5;
			}
			for(var i:Number = 0; i < points.length; i++)
			{
				points[i].setCenter(offsetX, offsetY, 200);
			}
		}
	}
}
