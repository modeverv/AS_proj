package com.adobe.empdir.managers
{
	import flash.events.EventDispatcher;
	import flash.net.SharedObject;
	
	
	/**
	 * This is a singleton class that manages LocalSharedObject settings. It also 
	 * works as a registry of settings objects names. 
	 */ 
	public class SettingsManager extends EventDispatcher
	{
		/** The selected CSS stylesheet that is configured for this application. **/
		public static const STYLESHEET : String = "stylesheetPath";
		
		/** The stored window position. **/
		public static const WINDOW_POSITION : String = "windowPosition";
		
		private static var instance : SettingsManager;
		
		private var so : SharedObject;
		
		/**
		 * Private constructor
		 */ 
		public function SettingsManager()
		{
			if ( instance != null )
				throw new Error("Private constructor. User SettingsManager.getInstance() instead.");
			
			so = SharedObject.getLocal( "localSettings" );		
		}
		
		public static function getInstance() : SettingsManager
		{
			if ( instance == null )
			{
				instance = new SettingsManager();
			}
			return instance;
		}
		
		
		/**
		 * Get the given setting value from the LocalSharedObject.
		 */ 
		public function getSetting( key:String ) : Object
		{
			return so.data[ key ];
		}
		
		/**
		 * Set and save the given setting.
		 */
		public function setSetting( key:String, value:Object ) : void
		{
			so.data[ key ] = value;
			so.flush();
		}
		
	}
}