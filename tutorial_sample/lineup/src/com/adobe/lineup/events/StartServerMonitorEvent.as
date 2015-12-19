package com.adobe.lineup.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class StartServerMonitorEvent extends CairngormEvent
	{

		public static var START_SERVER_MONITOR_EVENT:String = "startServerMonitorEvent";
		
		public function StartServerMonitorEvent()
		{
			super(START_SERVER_MONITOR_EVENT);
		}
		
	}
}
