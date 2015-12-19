package com.adobe.empdir.model
{
	import flash.events.EventDispatcher;
	
	/**
	 * A model object representing a department of peoplee.
	 */ 
	[Bindable]
	public class Department extends EventDispatcher implements IModelObject
	{
		private var _name : String;
		
		/** An array of Employee objects that are direct members of this department. **/
		public var employees : Array = new Array();
	
		override public function toString() : String
		{
			return "Department : " + displayName;
		}
		
		[Bindable(event="nameChanged")]
		public function get displayName() : String
		{
			return _name;
		}
		
		public function get name() : String
		{
			return _name;
		}
		
		public function set name( aName:String ) : void
		{
			_name = aName;
			dispatchEvent( new Event("nameChanged") );
		}
		
	}
}