package 
{
	import flash.display.Sprite;
	import flash.events.Event;
		
	/**
	 * ...
	 * @author modeverv
	 */
	[SWF(width = "465", height = "465", frameRate = "30")]
	public class Main extends Sprite 	
	{
		public function Main():void 
		{
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			// entry point
			stage.addChild(new BlockBreaker2());
		}
		
	}
	
}