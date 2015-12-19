package com.salesbuilder.dao
{
	import com.salesbuilder.model.Opportunity;
	
	import mx.collections.ArrayCollection;
	
	public interface IOpportunityDAO
	{
		function getItem(opportunityId:int):Opportunity;

		 function findAll():ArrayCollection;
		
		 function findByAccount(accountId:int):ArrayCollection;

		 function findByName(name:String):ArrayCollection;

		 function getChanges():ArrayCollection;

		 function save(opportunity:Opportunity):void;

		 function update(opportunity:Opportunity):void;
		
		 function create(opportunity:Opportunity):void;

		 function unflagChanges():void;
		
	}
}