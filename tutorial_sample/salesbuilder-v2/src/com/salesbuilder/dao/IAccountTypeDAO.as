// Christophe Coenraets, christophe@coenraets.org - http://coenraets.org
package com.salesbuilder.dao
{
	import mx.collections.ArrayCollection;
	
	public interface AccountTypeDAO
	{
		function getItem(accountTypeId:int):AccountType;

		function findAll():ArrayCollection;
		
		function getChanges():ArrayCollection;

		function update(accountType:Object):void;
		
		function create(accountType:Object):void;

		function unflagChanges():void;
		
	}
}