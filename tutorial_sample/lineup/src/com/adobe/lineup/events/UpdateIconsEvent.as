package com.adobe.lineup.events
{
	import com.adobe.cairngorm.control.CairngormEvent;

	public class UpdateIconsEvent extends CairngormEvent
	{
		public static var UPDATE_ICONS_EVENT:String = "updateIconsEvent";
		
		public function UpdateIconsEvent()
		{
			super(UPDATE_ICONS_EVENT);
		}

	}
}
