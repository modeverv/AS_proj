package com.adobe.empdir
{
	import com.adobe.empdir.data.parsers.ConferenceRoomCSVParser;
	import com.adobe.empdir.data.parsers.EmployeeCSVParser;
	import com.adobe.empdir.ui.skins.SimpleTwoColorBorder;
	
	/**
	 * Include classes that may not be included elsewhere. This is currently used for parser implementations.
	 */ 
	public class IncludeClasses
	{
		
		private var ecp : EmployeeCSVParser;
		private var ccp : ConferenceRoomCSVParser;
		private var stcb : SimpleTwoColorBorder;
	}
}