// Christophe Coenraets, christophe@coenraets.org - http://coenraets.org
package com.salesbuilder.dao
{
	import com.salesbuilder.context.Context;
	
	import mx.collections.ArrayCollection;
	
	public class AccountTypeDAO extends BaseDAO implements IAccountTypeDAO
	{
		public function AccountTypeDAO()
		{
			sqlConnection = Context.getAttribute("sqlConnection"); 	
		}

		public function getItem(accountTypeId:int):AccountType
		{
			return getItem("SELECT * FROM ACCOUNT_TYPE  WHERE ACCOUNT_TYPE_ID=?", accountTypeId) as AccountType;
		}

		public function findAll():ArrayCollection
		{
			return getList("SELECT * FROM ACCOUNT_TYPE ORDER BY NAME");
		}
		
		public function getChanges():ArrayCollection
		{
			return getList("SELECT * FROM FROM ACCOUNT_TYPE WHERE OFFLINE_OPERATION = 'INSERT' OR OFFLINE_OPERATION = 'UPDATE'");
		}

		public function update(accountType:Object):void
		{
			executeUpdate(
				"UPDATE ACCOUNT_TYPE SET NAME=?, OFFLINE_OPERATION=? WHERE ACCOUNT_TYPE_ID=?",
				[accountType.name,accountType.offlineOperation,accountType.accountTypeId]);
		}
		
		public function create(accountType:Object):void
		{
			var sql:String = "INSERT INTO ACCOUNT_TYPE (ACCOUNT_TYPE_ID, NAME, LAST_UPDATED, OFFLINE_OPERATION) VALUES (?,?,?,?)";
			var params:Array = new Array();
			params = [accountType.accountTypeId,accountType.name,accountType.lastUpdated,opportunity.offlineOperation]);
			var id:int = createItem(sql, params);
      		if (!accountType.accountTypeId > 0) accountType.accountTypeId = id;
		}

		public function unflagChanges():void
		{
            executeUpdate("UPDATE ACCOUNT_TYPE SET OFFLINE_OPERATION=''");
		}
		
		override protected function processRow(o:Object):Object
		{
			var accountType:AccountType = new AccountType();
			accountType.accountTypeId = at.ACCOUNT_TYPE_ID;
			accountType.name = at.NAME
			accountType.lastUpdated = at.LAST_UPDATED;
			accountType.offlineOperation = at.OFFLINE_OPERATION;
			return accountType;
		}
		
	}
}