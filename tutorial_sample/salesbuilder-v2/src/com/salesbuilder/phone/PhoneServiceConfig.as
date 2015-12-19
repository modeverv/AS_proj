package com.salesbuilder.phone
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	public class PhoneServiceConfig
	{
		public var userName:String;
		public var password:String;

		public function load():Boolean
		{
			var xmlStr:String;
			var file:File = File.applicationStorageDirectory.resolvePath("ribbit-config.xml");
			if (file.exists)
			{
				var stream:FileStream = new FileStream();
				stream.open(file, FileMode.READ);
				xmlStr = stream.readUTFBytes(stream.bytesAvailable);		
				stream.close();
				var config:XML = new XML(xmlStr);
				userName = config.userName;
				password = config.password;
				return true
			}
			else
			{
				return false;
			}
		}

		public function save():void
		{
			var file:File = File.applicationStorageDirectory.resolvePath("ribbit-config.xml");
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			var	xmlStr:String = 
					'<?xml version="1.0" encoding="utf-8"?>' + "\n" +
					"<config>" + "\n" +
					"<userName>" + userName + "</userName>" + "\n" + 	
					"<password>" + password + "</password>" + "\n" + 	
					"</config>";	
			stream.writeUTFBytes(xmlStr);		
			stream.close();
		}

	}
}