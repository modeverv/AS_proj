package com.adobe.lineup.events
{
	import com.adobe.cairngorm.control.CairngormEvent;

	public class ShowAlertEvent extends CairngormEvent
	{
		public static var SHOW_ALERT_EVENT:String = "showAlertEvent";
		public var title:String;
		public var message:String;
		
		public function ShowAlertEvent()
		{
			super(SHOW_ALERT_EVENT);
		}

	}
}
