package com.adobe.empdir.data.parsers
{
	/**
	 * This is an interface used to define a data parser that returns an array of results. 
	 */ 
	public interface IDataParser
	{
		/** 
		 * Parse the given data object and return an array of results.
		 * 
		 * @param data The data object that will be parsed. 
		 * @return An array of parsed objects. Subclasses will determine what type of object is returned.
		 */
		function parse( data:Object ) : Array;
	}
}