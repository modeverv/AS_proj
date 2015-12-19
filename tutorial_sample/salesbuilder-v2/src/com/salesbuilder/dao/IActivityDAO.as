package com.salesbuilder.dao
{
	import com.salesbuilder.model.Activity;
	
	import mx.collections.ArrayCollection;
	
	public interface IActivityDAO
	{
		function getItem(id:int):Activity;

		function findAll():ArrayCollection;
		
		function findByContact(contactId:int):ArrayCollection;

		function getChanges():ArrayCollection;

		function save(activity:Activity):void;

		function update(activity:Activity):void;
		
		function create(activity:Activity):void;

		function unflagChanges():void;
		
	}
}