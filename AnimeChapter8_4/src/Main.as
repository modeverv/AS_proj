package 
{
	//spring special sample
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
		private var ball0:Ball;
		private var ball1:Ball;
		private var ball2:Ball;
		private var ball0Dragging:Boolean = false;
		private var ball1Dragging:Boolean = false;
		private var ball2Dragging:Boolean = false;
		
		private var spring:Number = .002;
		private var friction:Number = 0.25;
		private var springLengh:Number = 100;
		
		
		
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
			
			ball0 = new Ball(20,0xff0000);
			ball0.x = Math.random() * stage.stageWidth;
			ball0.y = Math.random() * stage.stageHeight;
			ball0.addEventListener(MouseEvent.MOUSE_DOWN, onPress);
			addChild(ball0);
			
			ball1 = new Ball(20,0x00ff00);
			ball1.x = Math.random() * stage.stageWidth;
			ball1.y = Math.random() * stage.stageHeight;
			ball1.addEventListener(MouseEvent.MOUSE_DOWN, onPress);
			addChild(ball1);
			
			ball2 = new Ball(20,0x0000ff);
			ball2.x = Math.random() * stage.stageWidth;
			ball2.y = Math.random() * stage.stageHeight;
			ball2.addEventListener(MouseEvent.MOUSE_DOWN, onPress);
			addChild(ball2);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_UP, onRelease);
		}
		
		private function onEnterFrame(e:Event):void {
			if (!ball0Dragging) {
				springTo(ball0, ball1);
				springTo(ball0, ball2);
			}
			if (!ball1Dragging) {
				springTo(ball1, ball0);
				springTo(ball1, ball2);
			}
			if (!ball2Dragging) {
				springTo(ball2, ball1);
				springTo(ball2, ball0);
			}
			if (ball0.x< 0 || ball0.x > stage.stageWidth
				|| ball0.y < 0 || ball0.y > stage.stageHeight) {
				ball0.x = Math.random() * stage.stageWidth;
				ball0.y = Math.random() * stage.stageHeight;					
				ball1.x = Math.random() * stage.stageWidth;
				ball1.y = Math.random() * stage.stageHeight;
				ball2.x = Math.random() * stage.stageWidth;
				ball2.y = Math.random() * stage.stageHeight;
				ball0.vx = 0;
				ball0.vy = 0;
				ball1.vx = 0;
				ball1.vx = 0;
				ball2.vx = 0;
				ball2.vx = 0;
			}
			
			graphics.clear();
			graphics.beginFill(0xff00ff);
			graphics.lineStyle(1);
			graphics.moveTo(ball0.x, ball0.y);
			graphics.lineTo(ball1.x, ball1.y);
			graphics.lineTo(ball2.x,ball2.y)
			graphics.lineTo(ball0.x, ball0.y);		
			graphics.endFill();
		}
		
		private function springTo(ballA:Ball, ballB:Ball):void {
			var dx:Number = ballB.x - ballA.x;
			var dy:Number = ballB.y - ballB.y;
			var angle:Number = Math.atan2(dy, dx);
			var targetX:Number = ballB.x - Math.cos(angle) * springLengh;
			var targetY:Number = ballB.y - Math.sin(angle) * springLengh;
			ballA.vx += (targetX - ballA.x) * spring * friction;
			ballA.vy += (targetY - ballA.y) * spring * friction;
			ballA.x += ballA.vx;
			ballA.y += ballA.vy;
		}
		
		private function onPress(e:MouseEvent):void {
			e.target.startDrag();
			if (e.target == ball0) {
				ball0Dragging = true;
			}
			if (e.target == ball1) {
				ball1Dragging = true;
			}
			if (e.target == ball2) {
				ball2Dragging = true;
			}
		}
		private function onRelease(e:MouseEvent):void {
			ball0.stopDrag();
			ball1.stopDrag();
			ball2.stopDrag();
			ball0Dragging = false;
			ball1Dragging = false;
			ball2Dragging = false;
		}
		
	}
	
}