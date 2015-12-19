// Christophe Coenraets, christophe@coenraets.org - http://coenraets.org
package com.salesbuilder.dao
{
	import com.salesbuilder.model.Contact;
	
	import mx.collections.ArrayCollection;
	
	public interface IContactDAO
	{
		function getItem(contactId:int):Contact;
		
		function findAll():ArrayCollection;
		
		function findByAccount(accountId:int):ArrayCollection;
		
		function findByManager(managerId:int):ArrayCollection;

		function findByName(name:String):ArrayCollection;
		
		function findByPhoneNumber(phoneNumber:String):Contact;

		function getChanges():ArrayCollection;
		
		function save(contact:Contact):void;

		function update(contact:Contact):void;
		
		function create(contact:Contact):void;

		function unflagChanges():void;
	}
}