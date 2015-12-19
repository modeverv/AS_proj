package com.adobe.lineup.events
{
	import com.adobe.cairngorm.control.CairngormEvent;

	public class ActivateEvent extends CairngormEvent
	{
		public static var ACTIVATE_EVENT:String = "activateEvent";
		
		public function ActivateEvent()
		{
			super(ACTIVATE_EVENT);
		}

	}
}
