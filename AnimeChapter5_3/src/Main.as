package 
{//加速移動
	//俺俺
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	import net.hires.debug.Stats;
	
	//fortest
	import fortest.Ball;
	import fortest.Arrow;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import Ship;
	
	/**
	 * ...
	 * @author modeverv
	 */
	public class Main extends Sprite 
	{
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		
		private var ship:Ship;
		private var vr:Number = 0;
		private var thrust:Number = 0;
		private var vx:Number = 0;
		private var vy:Number = 0;
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			//俺俺
			var stats:Stats = new Stats();
			stats.y = 200;
			addChild(stats);
			
			ship = new Ship();
			addChild(ship);
			ship.x = stage.stageWidth / 2;
			ship.y = stage.stageHeight / 2;
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			addEventListener(Event.ENTER_FRAME, TimeGensui);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);	
			
		}
		
		private function onKeyDown(evt:KeyboardEvent):void
		{
			switch(evt.keyCode) {
				case Keyboard.LEFT:
					vr = -5;
					break;
				case Keyboard.RIGHT:
					vr = 5;
					break;
				case Keyboard.UP:
					thrust = 0.2;
					ship.draw(true);
					break;
				default:
					break;
			}
		}
		
		private function onKeyUp(evt:KeyboardEvent):void
		{
			vr = 0;
			thrust = 0;
			ship.draw(false);
		}
		private function TimeGensui(evt:Event):void {
			trace(vx); trace(vy);
			if (vx > 0) vx -= 0.1;
			if (vy > 0) vy -= 0.1;
			if (vx > 4) vx -= 0.01;
			if (vy > 4) vy -= 0.01;
			//if (vx > 5) vx -= 0.1;
			//if (vy > 5) vy -= 0.1;
			
		}
		private function onEnterFrame(evt:Event):void 
		{
			ship.rotation += vr;
			var angle:Number = ship.rotation * Math.PI / 180;
			var ax:Number = Math.cos(angle) * thrust;
			var ay:Number = Math.sin(angle) * thrust;
			vx += ax;
			vy += ay;
			ship.x += vx;
			ship.y += vy;			
			if (ship.x > stage.stageWidth || ship.x < 0) {
			 ship.y = stage.stageHeight / 2;
				
			  ship.x = stage.stageWidth / 2;
			  vx = 0;
			  vy = 0;	
			}
			if (    ship.y > stage.stageHeight || ship.y < 0) {
			ship.y = stage.stageHeight / 2;
			  ship.x = stage.stageWidth / 2;
			  vx = 0;
			  vy = 0;	
				
			}
			

		}
		
	}
	
}