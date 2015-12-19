package com.adobe.empdir.history
{
	/**
	 * This is a interface defining a simple non-hierarchical history state in the system. The
	 * interface is designed as a modified memento pattern that also stores what client a particular
	 * object is associated with.
	 */ 
	public interface IHistoryState
	{

		/**
		 * Get the value object associated with this history state.
		 */ 
		function get value() : Object;
		
		/**
		 * Restore the history state. Implementation classes are responsible for implementing this.
		 */ 
		function restore() : void;
		
		/** Return true if a state equals a given state; false otherwise. **/
		function equals( state:IHistoryState ) : Boolean;
	}
}