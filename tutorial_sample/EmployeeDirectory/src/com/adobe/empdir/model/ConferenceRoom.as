package com.adobe.empdir.model
{
	import flash.events.EventDispatcher;
	import com.adobe.empdir.avail.ICalendarObject;
	
	/**
	 * A model object representing a conference room.
	 */ 
	[Bindable]
	public class ConferenceRoom extends EventDispatcher implements IModelObject, ICalendarObject
	{
		/** The base id of this ConferenceRoom (CR_Bon999). **/
		public var id : String; 
		
		/** The extended name of the conference room in Outlook (CR SJ AT10/Flathead (14)). **/
		public var extendedName : String;
		
		/** The short / local name of the conference room. (FlatHead) **/
		public var localName : String;
		
		/** The Adobe location of the room (e.g. San Francisco). **/
		public var location : String;
		
		/** The building this room is located in (e.g. Almaden Tower). **/
		public var building : String;
		
		/** The floor that this room is located open.. **/
		public var floor : String;
		
		/** Maximum number of people who can fit in the room. **/
		public var capacity : String;
		
		/** A 10-digit IP phone number. **/
		public var phone : String;

		/** A 5-digit IP phone extension. **/
		public var phoneExtension : String;
		
		/** A 10-digit polycom phone number. **/
		public var polycomPhone : String;
		
		/** A 5-digit polycom extension. **/
		public var polycomPhoneExtension : String;
		
		/** The type of this room (e.g. CPR) **/
		public var type : String;
		
		/** Whether or not the room is restricted. **/
		public var restricted : String;
		
		/** The level of service provided to the room. (managed, self service, etc.) **/
		public var serviceLevel : String;
		
		
		public function get displayName() : String
		{
			return localName;
		}
		
		/**
		 * Get the calendar-id for this room used for Adobe availability queries.
		 */ 
		public function get calendarId() : String
		{
			return id + "@samplecompany.com";
		}
				
		override public function toString() : String
		{
			return "ConferenceRoom : " + id;
		}
		
	}
}