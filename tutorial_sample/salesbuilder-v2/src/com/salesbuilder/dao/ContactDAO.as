package com.salesbuilder.dao
{
	import com.salesbuilder.context.Context;
	import com.salesbuilder.model.Account;
	import com.salesbuilder.model.Contact;
	
	import mx.collections.ArrayCollection;
	
	public class ContactDAO extends BaseDAO implements IContactDAO
	{
		public function ContactDAO()
		{
			sqlConnection = Context.getAttribute("sqlConnection"); 	
		}

		public function getItem(contactId:int):Contact
		{
			return getSingleItem("SELECT * FROM CONTACT WHERE CONTACT_ID=? AND OFFLINE_OPERATION <> 'DELETE'", contactId) as Contact;
		}

		public function findByPhoneNumber(phoneNumber:String):Contact
		{
			var list:ArrayCollection = getList("SELECT * FROM CONTACT WHERE OFFICE_PHONE=? OR CELL_PHONE=? AND OFFLINE_OPERATION <> 'DELETE'", 
				[phoneNumber, phoneNumber]);
			if (list != null && list.length > 0)
			{
				return list.getItemAt(0) as Contact;
			}
			return null;
		}
		
		public function findAll():ArrayCollection
		{
			return getList("SELECT * FROM CONTACT WHERE OFFLINE_OPERATION <> 'DELETE' ORDER BY LAST_NAME, FIRST_NAME");
		}
		
		public function findByAccount(accountId:int):ArrayCollection
		{
			return getList("SELECT * FROM CONTACT WHERE ACCOUNT_ID = ? AND OFFLINE_OPERATION <> 'DELETE' ORDER BY FIRST_NAME, LAST_NAME", [accountId]);
		}

		public function findByManager(managerId:int):ArrayCollection
		{
			return getList("SELECT * FROM CONTACT WHERE MANAGER_ID = ? AND OFFLINE_OPERATION <> 'DELETE'", [managerId]);
		}

		public function findByName(name:String):ArrayCollection
		{
			return getList("SELECT * FROM CONTACT WHERE OFFLINE_OPERATION <> 'DELETE' AND (FIRST_NAME LIKE '%"+name+"%' OR LAST_NAME LIKE '%"+name+"%')");
		}

		public function getChanges():ArrayCollection
		{
			return getList("SELECT * FROM CONTACT WHERE OFFLINE_OPERATION = 'INSERT' OR OFFLINE_OPERATION = 'UPDATE' OR OFFLINE_OPERATION = 'DELETE'");
		}
		
		public function save(contact:Contact):void
		{
			contact.lastUpdated = new Date().time;
			if (contact.contactId>0)
			{
				 // Check if we aren't updating an account that has been created offline
				 // and not yet sent to the server
				if (contact.offlineOperation != "INSERT")
				{
					contact.offlineOperation = "UPDATE";
				}
				update(contact);
			}
			else
			{
				contact.offlineOperation = "INSERT";
				create(contact);
				contact.account.contacts.addItem(contact);
			}
		}

		public function update(contact:Contact):void
		{
			executeUpdate(
					"UPDATE CONTACT SET ACCOUNT_ID=?, MANAGER_ID=?, FIRST_NAME=?, LAST_NAME=?, TITLE=?, OWNER=?, OFFICE_PHONE=?, CELL_PHONE=?, EMAIL=?, FAX=?, ADDRESS1=?, ADDRESS2=?, CITY=?, STATE=?, ZIP=?, NOTES=?, PRIORITY=?, PICTURE=?, LAST_UPDATED=?, OFFLINE_OPERATION=? WHERE CONTACT_ID=?",
					[	contact.account.accountId,
						contact.manager.contactId,
						contact.firstName,
						contact.lastName,
						contact.title,
						contact.owner,
						contact.officePhone,
						contact.cellPhone,
						contact.email,
						contact.fax,
						contact.address1,
						contact.address2,
						contact.city,
						contact.state,
						contact.zip,
						contact.notes,
						contact.priority,
						contact.picture,
						contact.lastUpdated,
						contact.offlineOperation,
						contact.contactId	]);
		}
		
		public function create(contact:Contact):void
		{
			var id:int = createItem(
				"INSERT INTO CONTACT (CONTACT_ID, ACCOUNT_ID, MANAGER_ID, FIRST_NAME, LAST_NAME, TITLE, OWNER, OFFICE_PHONE, CELL_PHONE, EMAIL, FAX, ADDRESS1, ADDRESS2, CITY, STATE, ZIP, NOTES, PRIORITY, PICTURE, LAST_UPDATED, OFFLINE_OPERATION) " +
					"VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
					[	contact.contactId > 0 ? contact.contactId : null,
						contact.account.accountId,
						contact.manager ? contact.manager.contactId : null,
						contact.firstName,
						contact.lastName,
						contact.title,
						contact.owner,
						contact.officePhone,
						contact.cellPhone,
						contact.email,
						contact.fax,
						contact.address1,
						contact.address2,
						contact.city,
						contact.state,
						contact.zip,
						contact.notes,
						contact.priority,
						contact.picture,
						contact.lastUpdated,
						contact.offlineOperation ]);
      		contact.contactId = id;
      		contact.loaded = true;
		}

		public function unflagChanges():void
		{
			executeUpdate("UPDATE CONTACT SET OFFLINE_OPERATION=''");
		}
		
		override protected function processRow(o:Object):Object
		{
			var c:Contact = new Contact();
			var account:Account = new Account();
			account.accountId = o.ACCOUNT_ID;
			account.loaded = false;
			c.account = account;
			var manager:Contact = new Contact();
			manager.contactId = o.MANAGER_ID;
			manager.loaded = false;
			c.manager = manager;
			c.address1 = o.ADDRESS1;
			c.address2 = o.ADDRESS2;
			c.cellPhone = o.CELL_PHONE;
			c.city = o.CITY;
			c.contactId = o.CONTACT_ID;
			c.email = o.EMAIL;
			c.fax = o.FAX;
			c.firstName = o.FIRST_NAME;
			c.lastName = o.LAST_NAME;
			c.lastUpdated = o.LAST_UPDATED;
			c.notes = o.NOTES;
			c.officePhone = o.OFFICE_PHONE;
			c.offlineOperation = o.OFFLINE_OPERATION;
			c.owner = o.OWNER;
			c.state = o.STATE;
			c.title = o.TITLE;
			c.zip = o.ZIP;
			c.priority = o.PRIORITY;
			c.picture = o.PICTURE;
			c.loaded = true;
			return c;
		}
		
	}
}