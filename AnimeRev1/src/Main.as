package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import modeverv.movable.ball.Ball;
	import modeverv.movable.Movable;
	import modeverv.movable.Arrow;
	
	
	/**
	 * ...
	 * @author modeverv
	 */
	public class Main extends Sprite 
	{
		private var b:Ball;
		private var a:Arrow;
		
		private var eb:Ball;
		private var easing:Number = 0.2;
		
		private var ec:Ball;
		private var spring:Number = 0.1;
		private var friction:Number = 0.95;
		private var gravity:Number = 5;
		
		private var b0:Ball;
		private var b1:Ball;
		private var b2:Ball;
		private var ball0Dragging:Boolean = false;
		private var ball1Dragging:Boolean = false;
		private var ball2Dragging:Boolean = false;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			b = new Ball(20,20,-20);
			addChild(b);
			b.x = 0;
			b.y = 200;
			addEventListener(Event.ENTER_FRAME, onEF);
			b.addEventListener(Ball.XCOLLISION, chgC);
			b.addEventListener(Ball.YCOLLISION, chgC);
			
			a = new Arrow;
			addChild(a);
			a.x = stage.width / 2;
			a.y = stage.height / 2;
//			addEventListener(Event.ENTER_FRAME, onEFA);
			a.addEventListener(Arrow.XCOLLISION, chgCA);
			a.addEventListener(Arrow.YCOLLISION, chgCA);
			
			eb = new Ball;
			addChild(eb);
//			addEventListener(Event.ENTER_FRAME, onEFB);
			
			ec = new Ball;
			addChild(ec);
//			addEventListener(Event.ENTER_FRAME, onEFC);
			
			b0 = new Ball;
			b1 = new Ball;
			b2 = new Ball;
			b0.x = Math.random() * stage.stageWidth;
			b0.y = Math.random() * stage.stageHeight;
			b1.x = Math.random() * stage.stageWidth;
			b1.y = Math.random() * stage.stageHeight;
			b2.x = Math.random() * stage.stageWidth;
			b2.y = Math.random() * stage.stageHeight;
			b0.addEventListener(MouseEvent.MOUSE_DOWN, onPress);
			b1.addEventListener(MouseEvent.MOUSE_DOWN, onPress);
			b2.addEventListener(MouseEvent.MOUSE_DOWN, onPress);
			stage.addEventListener(MouseEvent.MOUSE_UP, onRelease);
			addChild(b0);
			addChild(b1);
			addChild(b2);
			addEventListener(Event.ENTER_FRAME, onEFD);			
		}
		private function onEFD(e:Event):void {
//			if ( ! ball0Dragging) { springTo(b0, b1);	}
			if ( ! ball1Dragging) { springTo(b1, b2);	}
			if ( ! ball2Dragging) { springTo(b2, b0);	}
			graphics.clear();
			graphics.lineStyle(1);
			graphics.moveTo(b0.x, b0.y);
			graphics.lineTo(b1.x, b1.y);
			graphics.lineTo(b2.x, b2.y);
			graphics.lineTo(b0.x, b0.y);
		}
		
		private function springTo(ballA:Ball, ballB:Ball):void {
			var dx:Number = ballB.x - ballA.x;
			var dy:Number = ballB.y - ballA.y;
			var angle:Number = Math.atan2(dy, dx);
			var targetX:Number = ballB.x - Math.cos(angle) * springLength;
			var targetY:Number = ballB.y - Math.sin(angle) * springLength;
			ballA.vx += (targetX - ballA.x) * spring;
			ballA.vy += (targetY - ballA.y) * spring;
			ballA.vx *= friction;
			ballA.vy *= friction;
			ballA.x += ballA.vx;
			ballA.y += ballA.vy;		
		}
		
		private function onPress(e:MouseEvent):void {
			e.target.startDrag();
			if (e.target == b0) {
				ball0Dragging = true;
			}
			if (e.target == b1) {
				ball1Dragging = true;
			}
			if (e.target == b2) {
				ball2Dragging = true;
			}
		}
		
		private function onRelease(e:MouseEvent):void {
			b0.stopDrag();
			b1.stopDrag();
			b2.stopDrag();
			ball0Dragging = false;
			ball1Dragging = false;
			ball2Dragging = false;
		}
		
		private var springLength:Number = 100;
		
		private function onEFC(e:Event):void {
			var dx:Number = ec.x -  mouseX;
			var dy:Number = ec.y - mouseY;
			var angle:Number = Math.atan2(dy, dx);
			var targetX:Number = mouseX + Math.cos(angle) * springLength;
			var targetY:Number = mouseY + Math.sin(angle) * springLength;
			//ec.ax = dx * spring;
			//ec.ay = dy * spring;
			ec.vx += (targetX - ec.x) * spring;
			ec.vy += (targetY - ec.y) * spring;
			ec.vy += gravity;
			ec.vx *= friction;
			ec.vy *= friction;
			ec.x += ec.vx;
			ec.y += ec.vy;
			graphics.clear();
			graphics.lineStyle(1);
			graphics.moveTo(ec.x, ec.y);
			graphics.lineTo(mouseX, mouseY);			
		}

		private function onEFB(e:Event):void {
			eb.vx = (mouseX - eb.x) * easing;
			eb.vy = (mouseY - eb.y) * easing;
			eb.x += eb.vx;
			eb.y += eb.vy;
		}
		private function chgC(e:Event):void {
			b.chgColor(0xffffff * Math.random());
		}
		private function chgCA(e:Event):void {
			a.chgColor(0xffffff * Math.random());
		}
		
		private function onEF(e:Event):void {
			b.move();
			b.doRebound(600, 400,0.7);
//			b.axelle(0.00, 0.00);
	    b.fliction(0.99);
			b.gravity(0.0, 0.8);
		}
		private function onEFA(e:Event):void {
			a.move();
			a.pointXY(mouseX, mouseY);
			a.doRebound(600, 400, 1.0);
//			a.axelle(.50, .50);
			
//	    a.fliction(0.99);
//			a.gravity(0.0, 0.8);
		}
		
	}
	
}