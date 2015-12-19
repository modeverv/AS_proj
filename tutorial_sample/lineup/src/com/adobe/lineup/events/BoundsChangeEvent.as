package com.adobe.lineup.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.NativeWindowBoundsEvent;

	public class BoundsChangeEvent extends CairngormEvent
	{
		public static var BOUNDS_CHANGE_EVENT:String = "boundsChangeEvent";
		
		public var nativeWindowBoundsEvent:NativeWindowBoundsEvent;
		
		public function BoundsChangeEvent()
		{
			super(BOUNDS_CHANGE_EVENT);
		}

	}
}
