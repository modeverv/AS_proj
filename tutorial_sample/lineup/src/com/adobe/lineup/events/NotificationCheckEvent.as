package com.adobe.lineup.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class NotificationCheckEvent extends CairngormEvent
	{

		public static var NOTIFICATION_CHECK_EVENT:String = "notificationCheckEvent";
		
		public function NotificationCheckEvent()
		{
			super(NOTIFICATION_CHECK_EVENT);
		}
		
	}
}
