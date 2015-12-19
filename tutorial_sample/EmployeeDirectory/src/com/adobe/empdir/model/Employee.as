package com.adobe.empdir.model
{
	import com.adobe.empdir.avail.ICalendarObject;
	
	/**
	 * A simple record indicating an employee here at Adobe.
	 */ 
	[Bindable]
	public class Employee implements IModelObject, ICalendarObject
	{

		/** The user id of the employee, used to determine their email address. **/
		public var id : String;

		/** The first name of the employee. **/
		public var firstName : String;
		
		/** The last name of the employee. **/
		public var lastName : String;
		
		/** The display name of the employee. **/
		public var displayName : String;
		
		/** The title of the employee. **/
		public var title : String;
		
		/** The department that this employee belongs too. **/
		public var department : String;
		
		/** The identifier of the user's manager. **/
		public var managerId : String;
		
		/** The manager record associated with this employee.  **/
		public var manager : Employee;
		
		/** The email address of the employee. **/
		public var email : String;
		
		/** A 10-digit external phone number. **/
		public var phone : String;

		/** A 10-digit cell phone number. **/
		public var cellPhone : String;
		
		/** A 5-digit internal phone numnber. **/
		public var phoneExtension : String;
		
		/** The desk location identifier. **/
		public var deskLocation : String;
		
		/** The location of the employee. **/
		public var location : String;
		
		/** The city this employee belongs to. **/
		public var city : String
		
		/** The state of this employee. **/
		public var state : String;
	
		/** A 5 or 9 digit zip of the employee. **/
		public var postalCode : String;
		
		/** A two-digit country code. **/
		public var countryCode : String;
		
		/** A collection of Employee records who directly report to this individual (via managerId). **/
		public var directReports : Array;
		
		
		public function get calendarId() : String
		{
			return email;	
		}	
		
		public function toString():String
		{
			return "Employee : " + displayName;
		}
	}
}