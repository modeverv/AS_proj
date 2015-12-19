package com.adobe.empdir.commands.data
{
	import com.adobe.empdir.commands.Command;
	import com.adobe.empdir.managers.DatabaseConnectionManager;
	
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;


	/**
	 * This is an abstract command that takes care of opening a SQLConnection and providing
	 * a statement. 
	 * 
	 * Subclasses should implement the executeSQL() method, which will be invoked
	 * after the connection is fully open. 
	 * 
	 * @author Daniel Wabyick
	 */ 
	public class SQLCommand extends Command
	{
		protected var conn : SQLConnection;
		protected var stmt : SQLStatement;
		
		/**
		 * Constructor
		 */ 
		public function SQLCommand() : void
		{
		}
		
		
		/**
		 * Execute the command. Subclasses should not override this method, but instead override executeSQL.
		 */ 
		override public function execute() : void
		{
			conn = DatabaseConnectionManager.getInstance().getConnection( );
			stmt = new SQLStatement();
			stmt.sqlConnection = conn;
			
			executeSQL();
			
		}	
		
		/**
		 * Start executing the actual SQL. This will automatically get invoked after the connection is opened.
		 */ 
		protected function executeSQL() : void
		{
			throw new Error( "SQLCommand: Subclasses must override executeSQL.");
		}
		
		
		/**
		 * This function can be passed to responders for a default error callback. 
		 */ 
		protected function onSQLError( err:SQLError ) : void
		{
			notifyError( "Error executing SQL: " + err.message + " : " + err.errorID);
		}
		
	
		/**
		 * 
		 */ 	
		override protected function notifyComplete():void
		{
			closeSQLConnection();
			super.notifyComplete();
		}
		
		override protected function notifyError( msg:String ) : void
		{
			closeSQLConnection();
			super.notifyError(msg);
		}
		

		
		/**
		 * Cleanup the SQL connection.
		 */ 
		protected function closeSQLConnection() : void
		{
			if ( stmt  )
			{
				if ( stmt.executing ) 
					stmt.cancel();
				stmt.sqlConnection = null;
				
			}
			stmt = null;
			conn = null;
		}
		
	}
}