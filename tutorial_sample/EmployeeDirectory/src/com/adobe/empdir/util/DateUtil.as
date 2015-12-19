package com.adobe.empdir.util
{
	/**
	 * Some basic date utility functions for use in Actionscript.
	 */ 
	public class DateUtil
	{
		public static const HOUR_MSEC : int = 1000 * 60 * 60;
		public static const MINUTE_MSEC : int = 1000 * 60;
		
		/**
		 * Get a date that represents the first second of the given day.
		 */ 
		public static function getStartOfDay( date:Date ) : Date
		{
			var dt : Date = new Date();
			dt.setTime( date.getTime() );
			dt.setHours( 0, 0, 0, 0 );
			return dt;
		}
		
		/**
		 * Get a date that represents the last second of the given day.
		 */ 
		public static function getEndOfDay( date:Date ) : Date
		{
			var dt : Date = new Date();
			dt.setTime( date.getTime() );
			dt.setHours( 23, 59, 59, 9999 );
			return dt;
		}
		
		/**
		 * Get a date that represents the given date with the addition of a certain number of hours, minutes, seconds, etc. 
		 */ 
		public static function addHours( date:Date, hours:int, minutes:uint = 0, seconds:int = 0, millis:int = 0 ) : Date
		{
			var time : Number  = date.getTime();
			time += hours * HOUR_MSEC + minutes * MINUTE_MSEC + seconds * 1000 + millis;
			var dt : Date = new Date();
			dt.setTime( time );
			return dt;
		}
		
		
		
	}
}