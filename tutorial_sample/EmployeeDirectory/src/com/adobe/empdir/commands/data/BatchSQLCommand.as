package com.adobe.empdir.commands.data
{
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.SQLErrorEvent;
	import com.adobe.empdir.commands.Command;
	import flash.events.SQLEvent;
	import flash.net.Responder;
	import flash.data.SQLResult;
	import flash.errors.SQLError;


	/**
	 * This commands executes a number of SQL statements within a transaction.
	 * 
	 * @author Daniel Wabyick
	 */ 
	public class BatchSQLCommand extends SQLCommand
	{
	
		private var numStatements : uint;
		private var statements : Array;
	
		public function BatchSQLCommand() : void
		{
			super();
			statements = new Array();
		}
		
		/**
		 * Add a SQL statement to execute.
		 */ 
		public function addStatement( text:String ) : void
		{
			statements.push( text );
			numStatements++;
		}
		
		
		/**
		 * Execute the list of statements.
		 */ 
		override protected function executeSQL() : void
		{
			numStatements = statements.length;
			if ( statements.length == 0 )
			{
				notifyComplete();
			}
			else
			{
				logDebug("beginning transaction");
				conn.addEventListener( SQLEvent.BEGIN, onBeginTransaction );
				conn.begin();		
			}
		}
		
		private function onBeginTransaction( evt:SQLEvent ) : void
		{
			conn.removeEventListener( SQLEvent.BEGIN, onBeginTransaction );
			executeNext();
		}
		
		
		private function executeNext() : void
		{
			stmt.text = statements.shift();
			logDebug("executing SQL: " + stmt.text);
			stmt.execute( -1, new Responder( onExecResult, onExecError ) );
		}
		
		protected function onExecResult( res:SQLResult ) : void
		{
			if ( statements.length == 0 )
			{
				conn.addEventListener( SQLEvent.COMMIT, onSQLCommit );
				conn.commit();
				
			}
			else
			{
				notifyProgress( statements.length / numStatements * 100 );		
				executeNext();
			}
		}
		
		
		protected function onSQLCommit( evt:SQLEvent ) : void
		{
			logDebug("onSQLCommit()");
			conn.removeEventListener( SQLEvent.COMMIT, onSQLCommit );
			notifyComplete();
		}
		
		/**
		 * Invoked when an error occurs. Automatically performs a rollback and invoked notifyError.
		 */ 
	 	protected function onExecError( err:SQLError ) : void
		{
			logError("onExecError()");
			conn.rollback();
			notifyError( err.details + " : " + err.errorID + " : " + err.message );
		}
	}
}