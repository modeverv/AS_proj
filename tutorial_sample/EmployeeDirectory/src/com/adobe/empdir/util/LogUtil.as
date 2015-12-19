package com.adobe.empdir.util
{
	import flash.utils.getQualifiedClassName;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	/**
	 * Utility class for logging.
	 */ 
	public class LogUtil
	{
		/**
		 * Get a logger for 
		 */ 
		public static function getLogger( obj:Object ) : ILogger
		{
			var nameParts : Array = getQualifiedClassName( obj ).split("::");
			var className : String = nameParts[ nameParts.length - 1 ];
			return Log.getLogger( className );
		}
	}
}