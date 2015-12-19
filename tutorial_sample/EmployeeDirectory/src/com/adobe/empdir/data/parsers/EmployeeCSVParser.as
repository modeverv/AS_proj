package com.adobe.empdir.data.parsers
{
	import flash.events.EventDispatcher;
	import com.adobe.empdir.commands.Command;
	import com.adobe.empdir.model.Employee;
	
	/**
	 * This class is a custom implementation of a CSV parser. This particular implementation 
	 * is specific to the empdir CSV data format.
	 */
	public class EmployeeCSVParser implements IDataParser
	{
		
		/** 
		 * Parse the given data (assumed to be CSV, line delimited data.)
		 * 
		 * @param data The data object that will be parsed. 
		 * @return An array of Employee objects.
		 */
		public function parse( data:Object ) : Array
		{
			var results : Array = new Array();
			
			var entries : Array = String( data ).split("\n");
			var employee : Employee;
			var itemArr : Array
			
			for each ( var entry:String in entries )
			{
				itemArr = entry.split(",");
				employee = new Employee();
		
				employee.firstName = (itemArr[0] != '' ? itemArr[0]:null);
				employee.lastName = (itemArr[1] != '' ? itemArr[1]:null);
				employee.displayName = itemArr[0] + " " + itemArr[1];
				employee.id = (itemArr[2] != '' ? itemArr[2]:null);				
				employee.title = (itemArr[3] != '' ? itemArr[3]:null);			
				employee.email = (itemArr[4] != '' ? itemArr[4]:null);	
				employee.managerId = (itemArr[5] != '' ? itemArr[5]:null);
				employee.department = (itemArr[6] != '' ? itemArr[6]:null);
				employee.location = (itemArr[7] != '' ? itemArr[7]:null);
				employee.phone = (itemArr[8] != '' ? itemArr[8]:null);
				employee.phoneExtension = (itemArr[9] != '' ? itemArr[9]:null);				
				employee.deskLocation = (itemArr[10] != '' ? itemArr[10]:null);
				employee.city = (itemArr[11] != '' ? itemArr[11]:null);				
				employee.state = (itemArr[12] != '' ? itemArr[12]:null);
				employee.countryCode = (itemArr[13] != '' ? itemArr[13]:null);
				employee.postalCode = (itemArr[14] != '' ? itemArr[14]:null);		
				results.push( employee );
			}
			
			return results;
			
		}
	}
}