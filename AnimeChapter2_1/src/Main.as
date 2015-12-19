package 
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author modeverv
	 */
	public class Main extends Sprite 
	{
		public var b:Ball;		
		private var v:Sprite;
		private var mv:Sprite;
		private var dx:Number;
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			b = new Ball();
			v = new Sprite();
			addChild(v);
			
			mv = new Sprite();
			addChild(mv);
			
			v.graphics.beginFill(0xff0000);
			v.graphics.drawCircle(0, 0, 40);
			v.graphics.endFill();
			v.x = 100; v.y = stage.height / 2;
			dx = 1;
			addEventListener(Event.ENTER_FRAME, updategame);
			// mouse event
			addEventListener(MouseEvent.MOUSE_MOVE, mouseehandle);
			trace(Math.sin(30 * Math.PI / 180));
			trace(Math.cos(60 * Math.PI / 180));
		}
		
		private function mouseehandle(e:MouseEvent):void {
			var c:Number = (e.stageX + e.stageY);
			mv.graphics.beginFill(0x00ff00 );
			mv.graphics.drawCircle(e.stageX, e.stageY, 20);
			mv.graphics.endFill();
		}
		
		private function updategame(e:Event):void {
			b.nextPoint(graphics);
			if ((v.x += dx) > stage.width - 100 ) {
				dx *= -1;
			}
			if (v.x  < 80 ) {
				dx *= -1;
			}
			
		}
	}
	
	
}