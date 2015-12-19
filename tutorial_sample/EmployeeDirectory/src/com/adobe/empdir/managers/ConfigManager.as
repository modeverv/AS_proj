package com.adobe.empdir.managers
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.desktop.NativeApplication;

	
	/** An event that occurs when the configuration has completed loading. **/
	[Event(name="complete", type="flash.events.Event")]
	
	/** An event that occurs when the configuration has loaded with an error. **/
	[Event(name="error", type="flash.events.ErrorEvent")]
	
	/**
	 * This is a singleton class that can be used to load a configuration file and provide
	 * values. The manager supports simple  string and numeric values, objects, and arrays.
	 * 
	 * @author Daniel Wabyick
	 *
	 */ 
	public class ConfigManager extends EventDispatcher
	{
		private static var instance : ConfigManager;
		
		private var props : Object;
		
		/** The application-id pulled from the AIR application descriptor. **/
		public var applicationId : String;	
		
		/** The application version pulled from the AIR application descriptor. **/ 
		public var applicationVersion : String;
		
		/**
		 * Private constructor
		 */ 
		public function ConfigManager()
		{
			if ( instance != null )
				throw new Error("Private constructor. User ConfigManager.getInstance() instead.");
			
			props = new Object();		
		
			var desc : XML = NativeApplication.nativeApplication.applicationDescriptor;
			applicationId = desc.*::id.text();
			applicationVersion = desc.*::version.text();
		}
		
		public static function getInstance() : ConfigManager
		{
			if ( instance == null )
			{
				instance = new ConfigManager();
			}
			return instance;
		}
		
		
		/**
		 * Load the given configuration file. Invokes Event.COMPLETE
		 */ 
		public function loadConfig( url:String ) : void
		{
			var req : URLRequest = new URLRequest( url );
			var loader : URLLoader = new URLLoader( req );
			loader.addEventListener( Event.COMPLETE, onLoad );	
			loader.addEventListener( IOErrorEvent.IO_ERROR, onLoadError );
		}
		
		/**
		 * Get the configurable property with the given key.
		 * @param key
		 * @return The value for the given key. 
		 */ 
		public function getProperty( key:String ) : String
		{
			var val : *  = props[ key ];
			if ( val == null )
				return null;
			else
			{		
				return props[ key ].toString();
			}
		}
		
		/**
		 * Get the configurable property with the given key cast as a number.
		 * @param key
		 * @return The value for the given key. 
		 */ 
		public function getNumericProperty( key:String ) : Number
		{
			return Number( props[ key ] );
		}
		
		/**
		 * Get the configurable property with the given key cast as an Array. 
		 * @param key
		 * @return The value for the given key. 
		 * 
		 */ 
		public function getArrayProperty( key:String ) : Array
		{
			var val:* = props[key];
			if ( val is Array )
			{
				return val;
			}
			else
			{
				return [ val ];
			}
		}
		
		/**
		 * Get the configurable property with the given key cast as a boolean.
		 * @param key
		 * @return The value for the given key. 
		 */ 
		public function getBooleanProperty( key:String ) : Boolean
		{
			return String( props[ key ] ).toLowerCase() == "true";
		}
		
		/**
		 * Get the configurable property cast as an object.
		 * @param key
		 * @return The value for the given key. 
		 */ 
		public function getObjectProperty( key:String ) : Object
		{
			return props[ key ];
		}
		
		
		private function onLoad( evt:Event ) : void
		{
			try 
			{
				var x : XML = new XML( URLLoader( evt.target ).data );
				
				var val : String;
				for each ( var propXML:XML in x..property )
				{					
					if ( propXML.hasSimpleContent() )
					{
						val = propXML.@value;
						if ( ! val )
						{
							val = propXML.text().toString();
						}
						props[ propXML.@key ] = val;
					}
					else 
					{
						// array list parsing:
						//  <array> <item>Val1</item><itemVal2</item></array>
						var list : XMLList = propXML..item;
						if ( list.length() > 0 )
						{
							var valArr:Array = new Array();
							for each ( var v:XML in list )
							{
								valArr.push( v.text().toString() );	
							}
							props[ propXML.@key ] = valArr;
						}
						
						// object parsing:
						//  <object> <attribute key="key" value="val" /> </object>
	
						list = propXML..attribute;
						if ( list.length() > 0 )
						{
							var obj : Object = new Object();
							for each ( var a:XML in list )
							{
								obj[ a.@key.toString() ] = a.@value.toString();
							}	
							
							props[ propXML.@key ] = obj;
						}
						
					}
				}
				
				dispatchEvent( new Event( Event.COMPLETE ) );
			}
			catch ( e:Error ) 
			{
				notifyError( e.message );
			}
		}
		
		private function onLoadError( evt:ErrorEvent ) : void
		{
			notifyError( evt.text );
		}
		
		private function notifyError( msg:String ) : void
		{
			var evt : ErrorEvent = new ErrorEvent( ErrorEvent.ERROR );
			evt.text = "ConfigManager - error loading config: " + msg; 
			dispatchEvent( evt );
		}
	}
}