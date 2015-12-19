package com.adobe.empdir.data.parsers
{
	import flash.events.EventDispatcher;
	import com.adobe.empdir.model.ConferenceRoom;
	import com.adobe.empdir.model.Employee;
	
	/**
	 * This class is a custom implementation of a CSV parser. This particular implementation 
	 * is specific to the empdiradobe data format.
	 */
	public class ConferenceRoomCSVParser implements IDataParser
	{
		
		/** 
		 * Parse the given data (assumed to be CSV, line delimited data.)
		 * 
		 * @param data The data object that will be parsed. 
		 * @return An array of ConferenceRoom objects.
		 */
		public function parse( data:Object ) : Array
		{
			var results : Array = new Array();
			
			var entries : Array = String( data ).split("\n");
			var room : ConferenceRoom;
			var itemArr : Array
			
			for each ( var entry:String in entries )
			{
				itemArr = entry.split(",");
				room = new ConferenceRoom();

				room.id = (itemArr[0] != '' ? itemArr[0]:null);
				room.extendedName = (itemArr[1] != '' ? itemArr[1]:null);
				room.localName = (itemArr[2] != '' ? itemArr[2]:null);
				room.location = (itemArr[3] != '' ? itemArr[3]:null);
				room.building = (itemArr[4] != '' ? itemArr[4]:null);
				room.floor = (itemArr[5] != '' ? itemArr[5]:null);
				room.capacity = (itemArr[6] != '' ? itemArr[6]:null);
				room.phone = (itemArr[7] != '' ? itemArr[7]:null);
				room.phoneExtension = (itemArr[8] != '' ? itemArr[8]:null);
				room.polycomPhone = (itemArr[9] != '' ? itemArr[9]:null);
				room.polycomPhoneExtension = (itemArr[10] != '' ? itemArr[10]:null);
				room.type = (itemArr[11] != '' ? itemArr[11]:null);
				room.serviceLevel = (itemArr[12] != '' ? itemArr[12]:null);
				room.restricted = (itemArr[13] != '' ? itemArr[13]:null);
				results.push( room );
			}
			
			return results;
			
		}
	}
}