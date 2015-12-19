package com.websysd.util.network
{
	import flash.net.InterfaceAddress;
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;
	import mx.collections.ArrayCollection;

	private var interfaces:Vector.<NetworkInfo>;
	private var addresses:ArrayCollection;

	/**
	 *　ネットワークインタフェース情報を表示するファンクション 
	 */	
	public function getNetworkInterfaceInfo():void
	{
		var nn:int = 1, no:int;
		networkInfo = new NetworkInfo();
		info_ta.text = "The network interfaces Information:\n";
		var interfaces:Vector.<NetworkInterface> = networkInfo.findInterfaces();
		for each(var networkInterface:NetworkInterface in interfaces)
		{					
			info_ta.text += "\n**NetworkInterface" + nn++ + "\n";
			info_ta.text += "Active:" + networkInterface.active + "\n";
			if ( networkInterface.active ) {
				info_ta.text += "Display Name:" + networkInterface.displayName + "\n";
				info_ta.text += "Hardware Address:" + networkInterface.hardwareAddress + "\n";
				info_ta.text += "MTU:" + networkInterface.mtu + "\n";
				info_ta.text += "Name:" + networkInterface.name + "\n";
				
				var addresses:Vector.<InterfaceAddress> = networkInterface.addresses;
				no = 1;
				for each(var interfaceAddress:InterfaceAddress in addresses)
				{
					info_ta.text += "  ipVersion:" + interfaceAddress.ipVersion + "\n";
					if ( interfaceAddress.ipVersion == "IPv4" ) {
						info_ta.text += "\n **InterfaceAddress " + no++ + ":\n";
						info_ta.text += "  Address:" + interfaceAddress.address + "\n";
						info_ta.text += "  Broadcast:" + interfaceAddress.broadcast + "\n";
						info_ta.text += "  Prefix Length:" + interfaceAddress.prefixLength + "\n";
					}
				}						
			}
		}
	}						
}