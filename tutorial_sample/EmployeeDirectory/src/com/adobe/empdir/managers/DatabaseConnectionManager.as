package com.adobe.empdir.managers
{
	import com.adobe.empdir.util.LogUtil;
	
	import flash.data.SQLConnection;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;

	/** 
	 * An event indicating that the manager is initialized and the database connection is available.  
	 * @eventType mx.events.Event.INIT
	 */
	[Event(name="init", type="flash.events.Event")]

	/**
	 * This singleton is a factory class for creating new database conenctions
	 */ 
	public class DatabaseConnectionManager extends EventDispatcher
	{
		
		private static var instance : DatabaseConnectionManager;
		
		private static const DBPATH : String = "employeedirectoryM6.db";
		private var dbFile : File;
		
		private var conn : SQLConnection;
		private var inited : Boolean = false;
		/**
		 * Private constructor. Use getInstance() instead.
		 */
		public function DatabaseConnectionManager()
		{
			if ( instance != null )
			{
				throw new Error("Private constructor. Use getIntance() instead.");	
			}
			dbFile = File.applicationStorageDirectory.resolvePath( DBPATH );
			
		}

		
		/**
		 * Get an instance of the DataManager.
		 */ 
		public static function getInstance() : DatabaseConnectionManager
		{
			if ( instance == null )
			{
				instance = new DatabaseConnectionManager();
			}
			return instance;
		}
		
		/**
		 * Initialize the database connection. 
		 */ 
		public function init() : void
		{
			if ( ! inited )
			{
				inited = true;
				conn = new SQLConnection();
				conn.addEventListener( SQLEvent.OPEN, onConnOpen );
				conn.addEventListener( SQLErrorEvent.ERROR, onConnOpenError );
				conn.openAsync( dbFile );	
			}
		}
		
		
		/**
		 * Get the SQLConnection.
		 */ 
		public function getConnection( ) : SQLConnection
		{
			if ( ! inited )
			{
				init();
			}
			return conn;
		}
		
		private function onConnOpen( evt:SQLEvent ) : void
		{
			dispatchEvent( new Event( Event.INIT ) );
		}
		
		private function onConnOpenError( evt:SQLErrorEvent ) : void
		{
			LogUtil.getLogger(this).error( "Error opening database connection: " + evt );
		}
		
		
	}
}