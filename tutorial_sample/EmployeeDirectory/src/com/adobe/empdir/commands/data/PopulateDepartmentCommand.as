package com.adobe.empdir.commands.data
{
	import flash.net.Responder;
	import flash.data.SQLResult;
	import com.adobe.empdir.model.Department;
	import com.adobe.empdir.model.Employee;
	
	/**
	 * This command will populate a department with all its member employees
	 */ 
	public class PopulateDepartmentCommand extends SQLCommand
	{
		public var department : Department;
		
		/**
		 * Constructor
		 */ 
		public function PopulateDepartmentCommand( department:Department ) 
		{
			this.department = department;
		}
		
		override protected function executeSQL():void
		{
			stmt.itemClass = Employee;
			
			var deptName : String = department.name;
			deptName = deptName.replace( "'", "''" );  // escape single quotes, yeah!
			
			stmt.text = "select * from employee where department = '" + deptName + "' ORDER BY lastName;"
			logDebug("executing: " + stmt.text);
			stmt.execute( -1, new Responder( onDepartmentResult, onSQLError ) );
		}
		
		private function onDepartmentResult( res:SQLResult ):void
		{
			if ( res.data ) 
			{
				department.employees = res.data.slice(); 
			}
			notifyComplete();
		}
		
	}
}