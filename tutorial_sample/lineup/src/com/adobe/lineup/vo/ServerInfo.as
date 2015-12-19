package com.adobe.lineup.vo
{
	import com.adobe.cairngorm.vo.IValueObject;
	
	[Bindable]
	public class ServerInfo implements IValueObject
	{
		public var exchangeServer:String;
		public var exchangeDomain:String;
		public var exchangeUsername:String;
		public var exchangePassword:String;
		public var useHttps:Boolean;
	}
}
