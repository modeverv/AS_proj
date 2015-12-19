package com.adobe.lineup.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.lineup.vo.CalendarEntry;

	public class OpenDetailsEvent extends CairngormEvent
	{
		public static var OPEN_DETAILS_EVENT:String = "openDetailsEvent";
		public var event:CalendarEntry;
		public var clickX:Number;
		public var clickY:Number;
		
		public function OpenDetailsEvent()
		{
			super(OPEN_DETAILS_EVENT);
		}

	}
}
