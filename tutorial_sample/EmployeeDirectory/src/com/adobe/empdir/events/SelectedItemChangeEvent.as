package com.adobe.empdir.events
{

	import flash.events.Event;
	
	/**
	 * A generic event indicating that a selected item changed.
	 */ 
	public class SelectedItemChangeEvent extends Event
	{
		public static const CHANGE : String = "selectedItemChange";
		
		public var item : Object;
		
		/**
		 * Constructor
		 */ 
		public function SelectedItemChangeEvent( item:Object ) : void
		{
			super( CHANGE );
			this.item = item;
		}
	}
}