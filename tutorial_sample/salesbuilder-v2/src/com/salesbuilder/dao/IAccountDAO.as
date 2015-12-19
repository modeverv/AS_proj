// Christophe Coenraets, christophe@coenraets.org - http://coenraets.org
package com.salesbuilder.dao
{
    import com.salesbuilder.model.Account;
    
    import mx.collections.ArrayCollection;
	
	public interface IAccountDAO
	{
		 function getItem(accountId:int):Account;

		 function findAll():ArrayCollection;

		 function findTop(size:int):ArrayCollection;

		 function findByName(name:String):ArrayCollection;

		 function getChanges():ArrayCollection;

		 function unflagChanges():void;
		
		 function save(account:Account):void;
		
		 function update(account:Account):void;
		
		 function create(account:Account):void;
		
	}
}