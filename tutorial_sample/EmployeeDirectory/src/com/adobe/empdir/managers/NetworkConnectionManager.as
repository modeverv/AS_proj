package com.adobe.empdir.managers
{
	import com.adobe.empdir.util.LogUtil;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.StatusEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.desktop.NativeApplication;
	
	import mx.logging.ILogger;

	/** 
	 * An event indicating that the manager is initialized and network status is available.  
	 * @eventType mx.events.Event.INIT
	 */
	[Event(name="init", type="flash.events.Event")]
	
	/** 
	 * An event indicating that network status has been updated.
	 * @eventType mx.events.StatusEvent.STATUS
	 */
	[Event(name="status", type="flash.events.StatusEvent")]
	
	
	/**
	 * This is a singleton class that broadcasts events regarding network connectivity. It essentially 
	 * a centralized wrapper around the AIR URLMonitor class.
	 */  
	public class NetworkConnectionManager extends EventDispatcher
	{
		
		private static var instance : NetworkConnectionManager;
		
	//	private var monitor : URLMonitor;
	
		private var monitorURL : String;
		private var inited : Boolean;
		private var isAvailable : Boolean = false;
		private var logger : ILogger;
		
		private var loader : URLLoader;
		
		/**
		 * @private constructor
		 */ 
		public function NetworkConnectionManager() 
		{
			if ( instance != null )
				throw new Error("Private constructor. User SettingsManager.getInstance() instead.");
		
			logger = LogUtil.getLogger( this );
			inited = false;
		}
		
		/**
		 * Get a singleton instance of the connection monitor.
		 */ 
		public static function getInstance() : NetworkConnectionManager
		{
			if ( instance == null )
			{
				instance = new NetworkConnectionManager();
			}
			return instance;
		}
		
		/**
		 * Initialize the mnager
		 */ 
		public function init() : void
		{
			if ( ! inited )
			{
				monitorURL = ConfigManager.getInstance().getProperty( "appCurrentVersionURL" );
				
				loader = new URLLoader();
				loader.addEventListener( HTTPStatusEvent.HTTP_STATUS, onHTTPRequestStatus );
				loader.addEventListener( IOErrorEvent.IO_ERROR, onIOError );
				checkLoadStatus();
				
				NativeApplication.nativeApplication.addEventListener( Event.NETWORK_CHANGE, onNetworkChange );
			}
		}
		
		private function onNetworkChange( evt:Event ) : void
		{
			logDebug("onNetworkChange()");
			checkLoadStatus();
		}
		
		private function checkLoadStatus() : void
		{
						
			var req : URLRequest = new URLRequest( monitorURL );
			req.method = "HEAD";
			
			loader.load( req );	
		
		}
		
		private function onIOError( evt:IOErrorEvent ) : void
		{
			isAvailable = false;
		}
		
		private function onHTTPRequestStatus( evt:HTTPStatusEvent ) : void
		{
			var status : int = evt.status;
			logDebug("onHTTPRequestStatus: " + evt.status);
			
			isAvailable = status >= 200 && status <= 206;
			
			if ( ! inited )
			{
				inited = true;
				dispatchEvent( new Event( Event.INIT ) );
			}
			
			dispatchEvent( new StatusEvent( StatusEvent.STATUS ) );
		}
		
		
		/**
		 * Get whether or not the network is available, based on connectivity to a configured URL.
		 */ 
		public function get networkAvailable() : Boolean
		{
			return isAvailable;
		}
		
		
		
		private function logDebug( msg:String ) : void
		{
			logger.debug( msg );
		}
	}
}