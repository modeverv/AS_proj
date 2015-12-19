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
	 * This command is responsible for fully populating an Employee record 
	 * with other data.
	 */ 
	public class PopulateEmployeeCommand extends SQLCommand
	{
		private var employee : Employee;
		
		
		/**
		 * Constructor
		 */ 
		public function PopulateEmployeeCommand( employee:Employee ) 
		{
			this.employee = employee;
		}
		
		override protected function executeSQL():void
		{	
			// load the manager information
			if ( employee.managerId == null )
			{
				loadDirectReports();
			}
			else
			{
				stmt.itemClass = Employee;
				stmt.text = "select * from employee where id = '" + employee.managerId + "';" ;
				stmt.execute( -1, new Responder( onManagerResult, onSQLError ) );
			}
		}
		
		
		
		private function onManagerResult( res:SQLResult ):void
		{
			//logDebug("onManagerResult()");
			if ( res.data != null )
			{
				employee.manager = res.data[0];	
			}
			loadDirectReports();
		}
		
		private function loadDirectReports() : void
		{
			stmt.text = "select * from employee where managerId = '" + employee.id + "' ORDER BY lastName;" ;
			stmt.itemClass = Employee;
			stmt.execute( -1, new Responder( onDirectReportResult, onSQLError ) );
		}
		
	
		private function onDirectReportResult( res:SQLResult ) : void
		{
			//logDebug("loadDirectReports(): " + res.data);
			if (  res.data ) 
			{
				employee.directReports = res.data.slice();
			}
			notifyComplete();
		}
	}
}