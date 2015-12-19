package com.adobe.empdir.history
{
	/**
	 * This interface defines a client of the HistoryManager - an object that 
	 * can have its state saved and restored.
	 */ 
	public interface IHistoryStateClient
	{
		function get historyState() : IHistoryState;
		function set historyState( state:IHistoryState ) : void;
	}
}