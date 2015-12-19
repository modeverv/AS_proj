package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import fortest.Box;
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
		private var box:Box;
		private var boxes:Array;
		private var gravity:Number = 0.8;
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			boxes = new Array();
			
			createBox();
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			
		}
		private function onEnterFrame(e:Event):void {
			box.vy += gravity;
			box.y += box.vy;
			if (box.y + box.height / 2 > stage.stageHeight) {
				box.y = stage.stageHeight - box.height / 2;
		//		box.chgColor(Math.random() * 0xffffff);
				createBox();
			}
			for (var i :uint = 0; i < boxes.length; ++i) {
				if (box != boxes[i] && box.hitTestObject(boxes[i])) {
					box.y - boxes[i].y -boxes[i].height / 2 -box.height / 2;
		//			box.chgColor(Math.random() * 0xffffff);
					createBox()
				}
			}
		}
		
		private function createBox():void {
			box = new Box(Math.random() * 40 + 10, 
				Math.random() * 40 + 10, 
				Math.random() * 0xffffff);
			box.x = Math.random() * stage.stageWidth;
			addChild(box);
			boxes.push(box);
		}
		
		
	}
	
}