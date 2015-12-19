package com.adobe.empdir.commands.data
	
	import com.adobe.empdir.commands.data.BatchSQLCommand;
	import com.adobe.empdir.events.CommandCompleteEvent;
	import com.adobe.empdir.managers.ConfigManager;
	
	import flash.data.SQLResult;
	import flash.errors.SQLError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.net.Responder;
	/**
	 * This class is responsible for checking if the database needs initialization and 
	 */ 
	public class InitDatabaseCommand extends SQLCommand
	{
		/**
		 * Execute the database initialization command.
		 */ 
		override protected function executeSQL() : void
		{
			var batchExec : BatchSQLCommand = new BatchSQLCommand();
		}
		
		}
		
		}
	}
}