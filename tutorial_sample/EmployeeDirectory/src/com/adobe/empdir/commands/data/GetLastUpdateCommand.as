package com.adobe.empdir.commands.data
{
	import com.adobe.empdir.model.Employee;
	
	import flash.events.SQLEvent;
	import flash.net.Responder;
	import flash.data.SQLResult;
	import flash.events.Event;
	import flash.events.SQLErrorEvent;
	import flash.errors.SQLError;
	
	
	/**
	 * This command is responsible for getting the last time the database was updated.
	 */ 
	public class GetLastUpdateCommand extends SQLCommand
	{
		public var lastUpdated : Date;
		
		
		/**
		 * Constructor
		 */ 
		public function GetLastUpdateCommand() 
		{
			
		}
		
		override protected function executeSQL():void
		{
			stmt.text = "SELECT lastUpdated from updatelog";
			stmt.execute( -1, new Responder( onCheckLastRead, onSQLError ) );
			
		}
		
		private function onCheckLastRead( res:SQLResult ):void
		{
			if ( res.data != null )
			{
				lastUpdated = new Date();
				lastUpdated.setTime(  Number( res.data[0].lastUpdated ) );
			}
			notifyComplete();
		}
	}
}