package com.adobe.empdir.commands.data
{
	import com.adobe.empdir.data.parsers.IDataParser;
	import com.adobe.empdir.managers.ConfigManager;
	import com.adobe.empdir.model.Employee;
	
	import flash.data.SQLResult;
	import flash.errors.SQLError;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.net.Responder;
	import flash.utils.getDefinitionByName;


	/**
	 * This command is used to load employee data and insert it into the database.
	 * 
	 */ 
	public class InsertEmployeeDataCommand extends SQLCommand
	{
		private var employees : Array;
		private var configManager : ConfigManager;
		private var insertResponder : Responder;

		private var data : Object;
		
		/**
		 * Constructor
		 * @param data The data we need to insert
		 */ 
		public function InsertEmployeeDataCommand( data:Object ) 
		{
			this.data = data;
			configManager = ConfigManager.getInstance();
		}
		
		/**
		 * Execute the SQL.
		 */ 
		override protected function executeSQL() : void
		{
		
			var employeeParserClassName : String = configManager.getProperty( "employeeParserClass" );
			if ( employeeParserClassName == null )
			{
				notifyError( "Error parsing data. No 'employeeParserClass' config property defined." );
			}
			else
			{
			  	try {
					var parser : IDataParser = new ( getDefinitionByName( employeeParserClassName ) ) as IDataParser;
			  	}
			  	catch ( e:Error ) 
			  	{
			  		notifyError( "Error instantiating parser - " + employeeParserClassName );
			  		return;
			  	}
			  		
			  	try {
			  		employees = parser.parse( data );
			  		parser = null;
			  	}
			  	catch ( e:Error )
			  	{
			  		notifyError( "Error parsing employee data - " + e.message );
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
			
			stmt.text = "delete from employee";
			stmt.execute( -1, new Responder( insertRecord, onSQLError ) );
		}
		
		
		
		private function insertRecord( res:SQLResult ) : void
		{
			 // This has city, state, postalcode, countrycode
				stmt.text = "INSERT INTO employee ('id', 'firstName', 'lastName', 'displayName', 'title', 'department', 'managerId', 'email', " + 
					"'phone', 'phoneExtension', 'cellPhone', 'deskLocation', 'location', 'city', 'state', 'postalCode', 'countryCode') " + 
					" VALUES (:id, :firstName, :lastName, :displayName, :title, :department, :managerId, :email," +
					" :phone, :phoneExtension, :cellPhone, :deskLocation, :location, :city, :state, :postalCode, :countryCode);";

				insertResponder = new Responder( onInsertSuccess, onSQLError );
				insertNextRecord();
		}

		/**
		 * Callback when we successfully insert all records. 
		 */ 
		private function onInsertSuccess( res:SQLResult ) : void
		{
			//logDebug("onInsertSuccess: " + dataArr.length);
			if ( employees.length == 0 )
			{
				stmt.clearParameters();
				
				doCommit();
			}
			else
			{
				insertNextRecord();
			}
		}
		
		
		private function updateComplete( evt:SQLResult ) : void
		{	
			logDebug("updateComplete()");
			doCommit();
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
			var msg : String = "An error occurred executing the SQL : " + err.errorID + " : " + err.message + " - " + stmt.text;
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
			var employee : Employee = employees.shift() as Employee;
				
			stmt.parameters[":id"] = employee.id;
			stmt.parameters[":firstName"] =  employee.firstName;
			stmt.parameters[":lastName"] = employee.lastName ;
			stmt.parameters[":displayName"] = employee.displayName ;
			stmt.parameters[":title"] =  employee.title ;
			stmt.parameters[":department"] =  employee.department ;
			stmt.parameters[":email"] =  employee.email ;
			stmt.parameters[":phone"] =  employee.phone ;
			stmt.parameters[":managerId"] = employee.managerId ;
			stmt.parameters[":phoneExtension"] =  employee.phoneExtension ;
			stmt.parameters[":cellPhone"] = employee.cellPhone ;
			stmt.parameters[":deskLocation"] = employee.deskLocation ;
			stmt.parameters[":city"] =  employee.city ;
			stmt.parameters[":location"] =  employee.location ;
			stmt.parameters[":state"] =  employee.state ;
			stmt.parameters[":countryCode"] =  employee.countryCode ;
			stmt.parameters[":postalCode"] =  employee.postalCode ;
			stmt.execute( -1, insertResponder );
		}
		
		override protected function notifyError(msg:String) : void
		{
			data = null;
			super.notifyError(msg);
		}
		
		override protected function notifyComplete() : void
		{
			data = null;
			super.notifyComplete();
		}
	
	}	
}