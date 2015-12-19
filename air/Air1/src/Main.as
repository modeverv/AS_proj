package 
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import fortest.Ball;
	
	/**
	 * ...
	 * @author modeverv
	 */
	public class Main extends Sprite 
	{
		public var b:Ball;	
		public function Main():void 
		{
			b = new Ball();
			addChild(b);
			addEventListener(MouseEvent.MOUSE_OVER, onMO);
		}
		private function onMO(e:MouseEvent):void {
			b.chgColor(Math.random() * 0xffffff);
		}
		
	}
	
}