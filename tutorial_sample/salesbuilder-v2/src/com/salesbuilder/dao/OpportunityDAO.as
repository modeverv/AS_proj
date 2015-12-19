package com.salesbuilder.dao
{
	import com.salesbuilder.context.Context;
	import com.salesbuilder.model.Account;
	import com.salesbuilder.model.Opportunity;
	
	import mx.collections.ArrayCollection;
	
	public class OpportunityDAO extends BaseDAO implements IOpportunityDAO
	{
		public function OpportunityDAO()
		{
			sqlConnection = Context.getAttribute("sqlConnection"); 	
		}

		public function getItem(opportunityId:int):Opportunity
		{
			return getSingleItem("SELECT * FROM OPPORTUNITY WHERE OPPORTUNITY_ID=? AND OFFLINE_OPERATION <> 'DELETE'", opportunityId) as Opportunity;
		}

		public function findAll():ArrayCollection
		{
			return getList("SELECT * FROM OPPORTUNITY WHERE OFFLINE_OPERATION <> 'DELETE'");
		}
		
		public function findByAccount(accountId:int):ArrayCollection
		{
			return getList("SELECT * FROM OPPORTUNITY WHERE ACCOUNT_ID = ? AND OFFLINE_OPERATION <> 'DELETE'", [accountId]);
		}

		public function findByName(name:String):ArrayCollection
		{
			return getList("SELECT * FROM OPPORTUNITY WHERE NAME LIKE '%"+name+"%' AND OFFLINE_OPERATION <> 'DELETE' ORDER BY NAME");
		}

		public function getChanges():ArrayCollection
		{
			return getList("SELECT * FROM OPPORTUNITY WHERE OFFLINE_OPERATION = 'INSERT' OR OFFLINE_OPERATION = 'UPDATE'");
		}

		public function save(opportunity:Opportunity):void
		{
			opportunity.lastUpdated = new Date().time;
			if (opportunity.opportunityId)
			{
				 // Check if we aren't updating an account that has been created offline
				 // and not yet sent to the server
				if (opportunity.offlineOperation != "INSERT")
				{
					opportunity.offlineOperation = "UPDATE";
				}
				update(opportunity);
			}
			else
			{
				opportunity.offlineOperation = "INSERT";
				create(opportunity);
				if (opportunity.account.opportunities) opportunity.account.opportunities.addItem(opportunity);
			}
		}

		public function update(opportunity:Opportunity):void
		{
			executeUpdate(
				"UPDATE OPPORTUNITY SET ACCOUNT_ID=?, NAME=?, OWNER=?, EXPECTED_CLOSE_DATE=?, EXPECTED_AMOUNT=?, PROBABILITY=?, STATUS=?, LEAD_SOURCE=?, NOTES=?, LAST_UPDATED=?, OFFLINE_OPERATION=? WHERE OPPORTUNITY_ID=?",
				[opportunity.account.accountId,opportunity.name,opportunity.owner,opportunity.expectedCloseDate.time,opportunity.expectedAmount,opportunity.probability,opportunity.status,opportunity.leadSource,opportunity.notes,opportunity.lastUpdated,opportunity.offlineOperation,opportunity.opportunityId]);
		}
		
		public function create(opportunity:Opportunity):void
		{
			var id:int = createItem(
				"INSERT INTO OPPORTUNITY (OPPORTUNITY_ID, ACCOUNT_ID, NAME, OWNER, EXPECTED_CLOSE_DATE, EXPECTED_AMOUNT, PROBABILITY, STATUS, LEAD_SOURCE, NOTES, LAST_UPDATED, OFFLINE_OPERATION) " +
					"VALUES (?,?,?,?,?,?,?,?,?,?,?,?)",
					[	opportunity.opportunityId > 0 ? opportunity.opportunityId : null,
						opportunity.account.accountId,
						opportunity.name,
						opportunity.owner,
						opportunity.expectedCloseDate is Date ? opportunity.expectedCloseDate.time : opportunity.expectedCloseDate,
						opportunity.expectedAmount,
						opportunity.probability,
						opportunity.status,
						opportunity.leadSource,
						opportunity.notes,
						opportunity.lastUpdated,
						opportunity.offlineOperation]);
      		opportunity.opportunityId = id;
      		opportunity.loaded = true;
		}

		public function unflagChanges():void
		{
            executeUpdate("UPDATE OPPORTUNITY SET OFFLINE_OPERATION=''");
		}
		
		override protected function processRow(o:Object):Object
		{
			var opp:Opportunity = new Opportunity();
			opp.opportunityId = o.OPPORTUNITY_ID;
			var account:Account = new Account();
			account.accountId = o.ACCOUNT_ID;
			account.loaded = false;
			opp.account = account;
			opp.name = o.NAME;
			opp.owner = o.OWNER;
			opp.owner = o.OWNER;
			opp.expectedCloseDate = new Date(o.EXPECTED_CLOSE_DATE);
			opp.expectedAmount = o.EXPECTED_AMOUNT;
			opp.probability = o.PROBABILITY;
			opp.status = o.STATUS;
			opp.leadSource = o.LEAD_SOURCE;
			opp.notes = o.NOTES;
			opp.lastUpdated = o.LAST_UPDATED;
			opp.offlineOperation = o.OFFLINE_OPERATION;
			return opp;
		}
		
	}
}