package 
{
	//spring 
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;	
	import flash.events.MouseEvent;
	import flash.media.Video;
	import fortest.Ball;
	import net.hires.debug.Stats;
	/**
	 * ...
	 * @author modeverv
	 */
	public class Main extends Sprite 
	{
		
		private var ball:Ball;
		private var handles:Array;
		private var spring :Number = 0.1;
		private var friction:Number = 0.8;
		private var numHandles:Number = 7;
		
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
			
			ball = new Ball(20);
			addChild(ball);
			
			handles = new Array();
			for (var i:uint = 0; i < numHandles; i++) {
				var handle:Ball = new Ball(10, Math.random() * 0xffffff);
				handle.x = Math.random() * stage.stageWidth;
				handle.y = Math.random() * stage.stageHeight;
				handle.addEventListener(MouseEvent.MOUSE_DOWN, onPress);
				addChild(handle);
				handles.push(handle);
			}
			//ball.addEventListener(MouseEvent.MOUSE_DOWN, onPress);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			addEventListener(MouseEvent.MOUSE_UP, onRelease);
			ball.addEventListener(MouseEvent.MOUSE_DOWN, onInit);
			
			
		}
		private function onInit(e:Event):void {
			for (var i:uint = 0; i < numHandles; i++) {
				
				var handle:Ball = handles[i] as Ball;// new Ball(10, Math.random() * 0xffffff);
				handle.x = Math.random() * stage.stageWidth;
				handle.y = Math.random() * stage.stageHeight;
//				handle.addEventListener(MouseEvent.MOUSE_DOWN, onPress);
//				addChild(handle);
//				handles.push(handle);
			}
		}
		
		private function onEnterFrame(event:Event):void {
			for (var i:uint = 0; i < numHandles ; i++) {
				var handle :Ball = handles[i] as Ball;
				var dx:Number = handle.x - ball.x;
				var dy:Number = handle.y - ball.y;
				ball.vx += dx * spring;
				ball.vy += dy * spring;
			}
			
			ball.vx *= friction;
			ball.vy *= friction;
			ball.x += ball.vx;
			ball.y += ball.vy;
			
			graphics.clear();
			graphics.lineStyle(1);
			for (i = 0 ; i < numHandles; i++) {
				graphics.moveTo(ball.x, ball.y);
				graphics.lineTo(handles[i].x, handles[i].y);
				
			}
			
			
			
		}
		
		private function onPress(event:Event):void {
			event.target.startDrag();
		}
		private function onRelease(event:Event):void {
			stopDrag();
		}
		
	}
	
}