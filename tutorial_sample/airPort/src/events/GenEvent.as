package events
{
	import flash.events.Event;
	/**
	 * GeneralEvent Class 
	 * @author R. Miyata
	 * 
	 */	
	public class GenEvent extends Event
	{
		public var genEventType:int; 
		public var obj:Object;
		
		public function GenEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}