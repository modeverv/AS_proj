package 
{
	//rotation
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;	
	import flash.events.MouseEvent;
	import fortest.Ball;
	import net.hires.debug.Stats;
	
	/**
	 * ...
	 * @author modeverv
	 */
	public class Main extends Sprite 
	{
		private var ball:Ball;
		private var vx:Number;
		private var vy:Number;
		
		private var vr:Number = 0.5;
		private var cos:Number = Math.cos(vr);
		private var sin:Number = Math.sin(vr);
		
		private var mb:Ball;
		
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;			
			var stats:Stats = new Stats()
			stats.y = 200;
			addChild(stats);			
			
			ball = new Ball();
			addChild(ball);
			ball.x = Math.random() * stage.stageWidth;
			ball.y = Math.random() * stage.stageHeight;
			
			mb = new Ball(40, Math.random() * 0xffffff);
			addChild(mb);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);			
			addEventListener(Event.ENTER_FRAME, onEnterFrameMouse);			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		private function onMouseDown(e:MouseEvent):void {
			ball.x = Math.random() * stage.stageWidth;
			ball.y = Math.random() * stage.stageHeight;
			ball.chgColor(Math.random() * 0xffffff);
		}
		
		private function onEnterFrameMouse(e:Event) {
			mb.x = mouseX;
			mb.y = mouseY;
		}
		
		private function onEnterFrame(e:Event):void {
			/*
			 *  x1,y1はオフセットを引くのでベクトル
			 *  ベクトルを回転させて
			 *  オフセットを戻して座標変換が終了です。
			 */
			var offsetX = mb.x;// stage.stageWidth / 2;
			var offsetY = mb.y;// stage.stageHeight / 2;
			var x1:Number = ball.x - offsetX;
			var y1:Number = ball.y - offsetY;
			//ベクトル回転
			var x2:Number = cos * x1 - sin * y1;
			var y2:Number = cos * y1 + sin * x1;
			ball.x = offsetX + x2;
			ball.y = offsetY + y2;
		}
	
		
	}
	
}