package com.adobe.lineup.events
{
	import com.adobe.cairngorm.control.CairngormEvent;

	public class SaveServerConfigEvent extends CairngormEvent
	{
		public static var SAVE_SERVER_CONFIG_EVENT:String = "saveServerConfigEvent";
		
		public var exchangeServer:String;
		public var exchangeDomain:String;
		public var exchangeUsername:String;
		public var exchangePassword:String;
		public var useHttps:Boolean;
		
		public function SaveServerConfigEvent()
		{
			super(SAVE_SERVER_CONFIG_EVENT);
		}

	}
}
