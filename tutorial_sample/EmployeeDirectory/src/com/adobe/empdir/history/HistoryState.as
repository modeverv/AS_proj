package com.adobe.empdir.history
{
	/**
	 * This is a basic implementation of IHistoryState. 
	 */
	public class HistoryState implements IHistoryState
	{
		private var client : IHistoryStateClient;
		private var _value : Object;
		
		/**
		 * Constructor
		 * @param client The client of the HistoryState object whose value we will restore.
		 * @param value The history value / memento we are storing.
		 */ 
		public function HistoryState( client:IHistoryStateClient, value:Object ) 
		{
			this.client = client;
			_value = value;
		}

		/**
		 * Get the value object associated with this history state.
		 */ 
		public function get value() : Object
		{
			return _value;
		}
		
		/**
		 * Restore the history state to its current implementation.
		 */ 
		public function restore() : void
		{
			client.historyState = this;
		}
		
		public function equals( state:IHistoryState ) : Boolean
		{
			return value == state.value;
		}
		
		public function toString() : String
		{
			return "[ HistoryState client: " + client + " : " + value + " ]";
		}
	}
}