package com.adobe.lineup.events
{
	import com.adobe.cairngorm.control.CairngormEvent;

	public class InvocationEvent extends CairngormEvent
	{
		public static var INVOCATION_EVENT:String = "invocationEvent";
		
		public function InvocationEvent()
		{
			super(INVOCATION_EVENT);
		}

	}
}
