package events
{
	import data.SocketData;	
	import flash.events.Event;
	/**
	 * Network Data Event Object Class 
	 * @author R. Miyata
	 * 
	 */	
	public class NetworkDataEvent extends Event
	{
		
		public var socketData:data.SocketData;
		
		public function NetworkDataEvent(type:String, data:SocketData , bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.socketData = data;
		}
		override public function clone():Event
		{
			return new NetworkDataEvent(type, socketData, false, false );
		}
	}
}