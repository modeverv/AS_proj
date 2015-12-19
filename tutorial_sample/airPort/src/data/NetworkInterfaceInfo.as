package data
{
	import com.websysd.util.network.FriendInterfaceAddress;
	
	import flash.net.DatagramSocket;
	import flash.net.InterfaceAddress;
	import flash.net.NetworkInterface;
	import flash.utils.ByteArray;

	public class NetworkInterfaceInfo
	{
		private var networkInterface_:NetworkInterface;
		private var addresses_:Vector.<InterfaceAddress>;
		private var addressesFriends_:Vector.<FriendInterfaceAddress>;

		public function NetworkInterfaceInfo(){}
		public function get networkInterface():NetworkInterface {
			return this.networkInterface_;
		}
		public function set networkInterface(networkInterface:NetworkInterface):void {
			this.networkInterface_ = networkInterface;
		}
		public function get addresses():Vector.<InterfaceAddress> {
			return this.addresses_;
		}
		public function set addresses(addresses:Vector.<InterfaceAddress>):void {
			this.addresses_ = addresses;
		}
		public function get addressesFriends():Vector.<FriendInterfaceAddress> {
			return this.addressesFriends_;
		}
		public function set addressesFriends(addresses:Vector.<FriendInterfaceAddress>):void {
			this.addressesFriends_ = addresses;
		}

		/**
		 * Friendの追加 
		 * @param adr
		 * Address to be added
		 * @return 
		 * when added=true  already exists=false
		 */		
		public function addFriend( adr:FriendInterfaceAddress ):Boolean { 
			trace( "NetworkInterfaceInfo.as addFriend() new address=" + adr.address );
			for ( var i:int = 0 ; i < addressesFriends_.length ; i++ ) {
				trace( "NetworkInterfaceInfo.as addFriend(). checking existing address:" + addressesFriends_[i].address );
				if ( addressesFriends_[i].address == adr.address ) {
					trace( "NetworkInterfaceInfo.as addFriend() " + adr.address + " exists. return" );
					return false;
				}
			}
			addressesFriends_.push( adr );
			return true;
		}
		/**
		 * Addressの追加 
		 * @param adr
		 * Address to be added
		 * @return 
		 * when added=true  already exists=false
		 */		
		public function addAddress( adr:InterfaceAddress ):Boolean { 
			for ( var i:int = 0 ; i < addresses_.length ; i++ ) {
				if ( addresses_[i].address == adr.address ) {
					return false;
				}
			}
			addresses_.push( adr );
			return true;
		}
		public function sendToAllFriends( udp:DatagramSocket, port:int, dat:ByteArray ):Boolean {
			try {
				for ( var i:int = 0 ; i < addressesFriends_.length ; i++ ) {
					trace( "sendToAllFriends(). sending to " + addressesFriends_[i].address + ", port:" + port );
					udp.send( dat, 0, 0, addressesFriends_[i].address, port );
				}				
			} catch ( e:Error ) {
				trace( "sendToAllFriends(). Error. : " + e );
				return false;
			}
			return true;			
		}
	}
}