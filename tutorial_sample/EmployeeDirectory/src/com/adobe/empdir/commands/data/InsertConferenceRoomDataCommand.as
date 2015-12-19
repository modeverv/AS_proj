package com.adobe.empdir.commands.data
{
	import com.adobe.empdir.data.parsers.IDataParser;
	import com.adobe.empdir.managers.ConfigManager;
	import com.adobe.empdir.model.ConferenceRoom;
	
	import flash.data.SQLResult;
	import flash.errors.SQLError;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.net.Responder;
	import flash.utils.getDefinitionByName;


	/**
	 * This command is used to load conference room and insert it into the database.
	 */ 
	public class InsertConferenceRoomDataCommand extends SQLCommand
	{
		private var rooms : Array;
		private var configManager : ConfigManager;
		private var insertResponder : Responder;

		private var data : Object;
		
		/**
		 * Constructor
		 * @param data The data we need to insert
		 */ 
		public function InsertConferenceRoomDataCommand( data:Object ) 
		{
			this.data = data;
			configManager = ConfigManager.getInstance();
		}
		
		/**
		 * Execute the SQL.
		 */ 
		override protected function executeSQL() : void
		{
		
			var confRoomParserClass : String = configManager.getProperty( "conferenceRoomParserClass" );
			if ( confRoomParserClass == null )
			{
				notifyError( "Error parsing data. No 'conferenceRoomParserClass' config property defined." );
			}
			else
			{
			  	try {
					var parser : IDataParser = new ( getDefinitionByName( confRoomParserClass ) ) as IDataParser;
			  	}
			  	catch ( e:Error ) 
			  	{
			  		notifyError( "Error instantiating parser - " + confRoomParserClass );
			  		return;
			  	}
			  		
			  	try {
			  		rooms = parser.parse( data );
			  		parser = null;
			  	}
			  	catch ( e:Error )
			  	{
			  		notifyError( "Error parsing room data - " + e.message );
			  		throw (e);  // for debugging
			  		return;
			  	}
			  	
			  	logDebug("beginning transaction.");
			  	conn.addEventListener( SQLEvent.BEGIN, onBegin );
			  	conn.begin(); //SQLTransactionLockType.IMMEDIATE );
			}
		}
			
		private function onBegin( evt:SQLEvent ) : void
		{
			// first, delete all the existing data.
			conn.removeEventListener( SQLEvent.BEGIN, onBegin );
			
			stmt.text = "delete from conferenceroom";
			stmt.execute( -1, new Responder( insertRecord, onSQLError ) );
		}
		
		
		
		private function insertRecord( res:SQLResult ) : void
		{	
			stmt.text = "INSERT into conferenceroom( 'id', 'extendedName', 'localName', 'location'," + 
     				"'building', 'floor', 'capacity', 'phone', 'phoneExtension'," + 
     				"'polycomPhone', 'polycomPhoneExtension', 'type', 'serviceLevel', 'restricted') " + 
     				"VALUES ( :id, :extendedName, :localName, :location," + 
     				":building, :floor, :capacity, :phone, :phoneExtension," + 
     				":polycomPhone, :polycomPhoneExtension, :type, :serviceLevel, :restricted);";

			insertResponder = new Responder( onInsertSuccess, onSQLError );
			insertNextRecord();
		}

		/**
		 * Callback when we successfully insert all records. 
		 */ 
		private function onInsertSuccess( res:SQLResult ) : void
		{
			//logDebug("onInsertSuccess: " + dataArr.length);
			if ( rooms.length == 0 )
			{
				stmt.clearParameters();
				
				doCommit();
			}
			else
			{
				insertNextRecord();
			}
		}
		
		private function doCommit() : void
		{
			logDebug( "doCommit()" );
			
			conn.addEventListener( SQLEvent.COMMIT, onCommit );
			conn.addEventListener( SQLErrorEvent.ERROR, onCommitError );
			conn.commit();
		}
		
		private function onCommit( evt:SQLEvent ) : void
		{
			conn.removeEventListener( SQLEvent.COMMIT, onCommit );
			conn.removeEventListener( SQLErrorEvent.ERROR, onCommitError );
		
			notifyComplete();
		}
		
		private function onCommitError( evt:SQLErrorEvent ) : void
		{
			logError( "onCommitError: " + evt );
			conn.removeEventListener( SQLEvent.COMMIT, onCommit );
			conn.removeEventListener( SQLErrorEvent.ERROR, onCommitError );
			
			conn.addEventListener( SQLEvent.ROLLBACK, onRollback );
			conn.addEventListener( SQLErrorEvent.ERROR, onRollbackError );
			
			conn.rollback();
		}
		
		private function onRollback( evt:SQLEvent ) : void
		{
			logDebug("onRollback()");
			conn.removeEventListener( SQLEvent.ROLLBACK, onRollback );
			conn.removeEventListener( SQLErrorEvent.ERROR, onRollbackError ); 
			notifyError( "Error committing transaction. Rolled back.");
		}
		
		private function onRollbackError( evt:SQLErrorEvent ) : void
		{
			logError( "onRollbackError()" );
			conn.removeEventListener( SQLEvent.ROLLBACK, onRollback );
			conn.removeEventListener( SQLErrorEvent.ERROR, onRollbackError );
			notifyError( "Error committing transaction. Error rolling back!" );
		}
		
		
		override protected function onSQLError( err:SQLError ) : void
		{
			var msg : String = "An error occurred executing the SQL : " + err.details + " : " + err.message + " - " + stmt.text;
			logDebug( msg );
			try
			{
				conn.rollback();
			}
			catch ( e:Error ) { }
			
			//dispatchEvent( new DataSynchronizationEvent( DataSynchronizationEvent.SYNC_COMPLETE ) );
			notifyError( msg );
		}

		private function insertNextRecord() : void
		{
			var room : ConferenceRoom = rooms.shift() as ConferenceRoom;

			stmt.parameters[":id"] = room.id;
			stmt.parameters[":extendedName"] =  room.extendedName;
			stmt.parameters[":localName"] = room.localName;
			stmt.parameters[":location"] = room.location;
			stmt.parameters[":building"] =  room.building;
			stmt.parameters[":floor"] =  room.floor;
			stmt.parameters[":capacity"] =  room.capacity;
			stmt.parameters[":phone"] =  room.phone ;
			stmt.parameters[":phoneExtension"] =  room.phoneExtension ;
			stmt.parameters[":polycomPhone"] = room.polycomPhone ;
			stmt.parameters[":polycomPhoneExtension"] = room.polycomPhoneExtension ;
			stmt.parameters[":type"] =  room.type ;
			stmt.parameters[":serviceLevel"] =  room.serviceLevel ;
			stmt.parameters[":restricted"] =  room.restricted ;
			
			stmt.execute( -1, insertResponder );		
		}
		
		override protected function notifyError(msg:String) : void
		{
			data = null;
			

			super.notifyComplete();
		}
		
		override protected function notifyComplete() : void
		{
			data = null;
			super.notifyComplete();
		}

	}	
}