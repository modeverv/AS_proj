package com.adobe.empdir.avail
{
	
	/**
	 * This interface indicates that an object has an associated availability with it.
	 */ 
	public interface ICalendarObject
	{
		/** Get the id associated with this object that can be used to query for calendar/scheduling. **/
		function get calendarId() : String;
		
	}
}