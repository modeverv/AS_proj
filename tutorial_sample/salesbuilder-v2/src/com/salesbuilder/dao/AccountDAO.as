package com.salesbuilder.dao
{
    import com.salesbuilder.context.Context;
    import com.salesbuilder.model.Account;
    
    import mx.collections.ArrayCollection;
	
	public class AccountDAO extends BaseDAO implements IAccountDAO
	{
		public function AccountDAO()
		{
			sqlConnection = Context.getAttribute("sqlConnection"); 	
		}
		
		public function getItem(accountId:int):Account
		{
			return getSingleItem("SELECT * FROM ACCOUNT WHERE ACCOUNT_ID=?", accountId) as Account;
		}

		public function findAll():ArrayCollection
		{
			return getList("SELECT * FROM ACCOUNT ORDER BY NAME");
		}

		public function findTop(size:int):ArrayCollection
		{
			return getList("SELECT * FROM ACCOUNT ORDER BY (CURRENT_YEAR_RESULTS + LAST_YEAR_RESULTS) DESC", null, 0, size);
		}

		public function findByName(name:String):ArrayCollection
		{
			return getList("SELECT * FROM ACCOUNT WHERE NAME LIKE '%"+name+"%' ORDER BY NAME" );
		}

		public function getChanges():ArrayCollection
		{
			return getList("SELECT * FROM ACCOUNT WHERE OFFLINE_OPERATION='INSERT' OR OFFLINE_OPERATION='UPDATE'");
		}

		public function unflagChanges():void
		{
			executeUpdate("UPDATE ACCOUNT SET OFFLINE_OPERATION=''");
		}
		
		public function save(account:Account):void
		{
			account.lastUpdated = new Date().time;
			if (account.accountId>0)
			{
				 // Check if we aren't updating an account that has been created offline
				 // and not yet sent to the server
				if (account.offlineOperation != "INSERT")
				{
					account.offlineOperation = "UPDATE";
				}
				update(account);
			}
			else
			{
				account.offlineOperation = "INSERT";
				create(account);
			}
		}
		
		public function update(account:Account):void
		{
			executeUpdate(
					"UPDATE ACCOUNT SET NAME=?, TYPE=?, INDUSTRY=?, OWNER=?, PHONE=?, FAX=?, TICKER=?, OWNERSHIP=?, NUMBER_EMPLOYEES=?, ANNUAL_REVENUE=?, PRIORITY=?, RATING=?, URL=?, ADDRESS1=?, ADDRESS2=?, CITY=?, STATE=?, ZIP=?, NOTES=?, LAST_UPDATED=?, CURRENT_YEAR_RESULTS=?, LAST_YEAR_RESULTS=?, OFFLINE_OPERATION=? WHERE ACCOUNT_ID=?",
						[	account.name,
							account.type,
							account.industry,
							account.owner,
							account.phone,
							account.fax,
							account.ticker,
							account.ownership,
							account.numberEmployees,
							account.annualRevenue,
							account.priority,
							account.rating,
							account.url,
							account.address1,
							account.address2,
							account.city,
							account.state,
							account.zip,
							account.notes,
							account.lastUpdated,
							account.currentYearResults,
							account.lastYearResults,
							account.offlineOperation,
							account.accountId]);
		}
		
		public function create(account:Account):void
		{
			var id:int = createItem(
				"INSERT INTO ACCOUNT (ACCOUNT_ID, NAME, TYPE, INDUSTRY, OWNER, PHONE, FAX, TICKER, OWNERSHIP, NUMBER_EMPLOYEES, ANNUAL_REVENUE, PRIORITY, RATING, URL, ADDRESS1, ADDRESS2, CITY, STATE, ZIP, NOTES, LAST_UPDATED, CURRENT_YEAR_RESULTS, LAST_YEAR_RESULTS, OFFLINE_OPERATION) " +
					"VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
					[	account.accountId > 0 ? account.accountId : null,
						account.name,
						account.type,
						account.industry,
						account.owner,
						account.phone,
						account.fax,
						account.ticker,
						account.ownership,
						account.numberEmployees,
						account.annualRevenue,
						account.priority,
						account.rating,
						account.url,
						account.address1,
						account.address2,
						account.city,
						account.state,
						account.zip,
						account.notes,
						account.lastUpdated,
						account.currentYearResults,
						account.lastYearResults,
						account.offlineOperation]);
      		account.accountId = id;
			account.loaded = true;
		}

		override protected function processRow(o:Object):Object
		{
			var a:Account = new Account();
			a.accountId = o.ACCOUNT_ID;
			a.annualRevenue = o.ANNUAL_REVENUE;
			a.address1 = o.ADDRESS1;
			a.address2 = o.ADDRESS2;
			a.city = o.CITY;
			a.state = o.STATE;
			a.zip = o.ZIP;
			a.fax = o.FAX;
			a.industry = o.INDUSTRY;
			a.lastUpdated = o.LAST_UPDATED;
			a.name = o.NAME;
			a.notes = o.NOTES;
			a.numberEmployees = o.NUMBER_EMPLOYEES;
			a.owner = o.OWNER;
			a.ownership = o.OWNERSHIP;
			a.phone = o.PHONE;
			a.priority = o.PRIORITY;
			a.rating = o.RATING;
			a.url = o.URL;
			a.ticker = o.TICKER;
			a.type = o.TYPE;
			a.currentYearResults = o.CURRENT_YEAR_RESULTS;
			a.lastYearResults = o.LAST_YEAR_RESULTS;
			a.offlineOperation = o.OFFLINE_OPERATION;
			a.loaded = true;
			return a;
		}
		
	}
}