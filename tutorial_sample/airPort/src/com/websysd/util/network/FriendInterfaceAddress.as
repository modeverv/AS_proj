package com.websysd.util.network
{
	import flash.net.InterfaceAddress;
	import flash.utils.ByteArray;
	
	public class FriendInterfaceAddress extends InterfaceAddress
	{
		/**
		 * ネットワークユーザ情報 
		 */		
		public var port:int;
		public var strData:String;
		public var intData:int;

		/**
		 * ユーザ情報などのデータ格納するオブジェクト
		 */		
		private var objData:Object;		
		private var binData:ByteArray;
		public function setData( itf:InterfaceAddress ) :void {
			this.address = itf.address;
			this.broadcast = itf.broadcast;
			this.ipVersion = itf.ipVersion;
			this.prefixLength = itf.prefixLength;
		}
		public function setObject( obj:Object ):void {
			this.objData = obj;
		}
		public function setByteArray( ba:ByteArray ):void {
			this.binData = ba;
		}
		public function FriendInterfaceAddress()
		{
			super();
		}
	}
}