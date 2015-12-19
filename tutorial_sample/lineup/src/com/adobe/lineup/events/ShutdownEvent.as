package com.adobe.lineup.events
{
	import com.adobe.cairngorm.control.CairngormEvent;

	public class ShutdownEvent extends CairngormEvent
	{
		public static var SHUTDOWN_EVENT:String = "shutdownEvent";
		
		public function ShutdownEvent()
		{
			super(SHUTDOWN_EVENT);
		}

	}
}
