package com.salesbuilder.dao
{
	import com.salesbuilder.context.Context;
	import com.salesbuilder.model.Activity;
	import com.salesbuilder.model.Contact;
	
	import mx.collections.ArrayCollection;
	
	public class ActivityDAO extends BaseDAO implements IActivityDAO
	{
		public function ActivityDAO()
		{
			sqlConnection = Context.getAttribute("sqlConnection"); 	
		}

		public function getItem(id:int):Activity
		{
			return getSingleItem("SELECT * FROM ACTIVITY WHERE ID=? AND OFFLINE_OPERATION <> 'DELETE'", id) as Activity;
		}

		public function findAll():ArrayCollection
		{
			return getList("SELECT * FROM ACTIVITY WHERE OFFLINE_OPERATION <> 'DELETE'");
		}
		
		public function findByContact(contactId:int):ArrayCollection
		{
			return getList("SELECT * FROM ACTIVITY WHERE CONTACT_ID = ? AND OFFLINE_OPERATION <> 'DELETE'", [contactId]);
		}

		public function getChanges():ArrayCollection
		{
			return getList("SELECT * FROM ACTIVITY WHERE OFFLINE_OPERATION = 'INSERT' OR OFFLINE_OPERATION = 'UPDATE'");
		}

		public function save(activity:Activity):void
		{
			activity.lastUpdated = new Date().time;
			if (activity.id)
			{
				 // Check if we aren't updating an account that has been created offline
				 // and not yet sent to the server
				if (activity.offlineOperation != "INSERT")
				{
					activity.offlineOperation = "UPDATE";
				}
				update(activity);
			}
			else
			{
				activity.offlineOperation = "INSERT";
				create(activity);
			}
		}

		public function update(activity:Activity):void
		{
			executeUpdate(
				"UPDATE ACTIVITY SET CONTACT_ID=?, TYPE=?, PHONE_NUMBER=?, NOTES=?, START_TIME=?, END_TIME=?, LAST_UPDATED=?, OFFLINE_OPERATION=? WHERE ID=?",
				[	
					activity.contact.contactId,
					activity.type,
					activity.phoneNumber,
					activity.notes,
					activity.startTime,
					activity.endTime,
					activity.lastUpdated,
					activity.offlineOperation,
					activity.id 
				]);

		}
		
		public function create(activity:Activity):void
		{
			var id:int = createItem(
				"INSERT INTO ACTIVITY (ID, CONTACT_ID, TYPE, PHONE_NUMBER, NOTES, START_TIME, END_TIME, LAST_UPDATED, OFFLINE_OPERATION) " +
				"VALUES (?,?,?,?,?,?,?,?,?)",
				[	activity.id > 0 ? activity.id : null,
					activity.contact.contactId,
					activity.type,
					activity.phoneNumber,
					activity.notes,
					activity.startTime,
					activity.endTime,
					activity.lastUpdated,
					activity.offlineOperation
				]);
      		activity.id = id;
      		activity.loaded = true;
		}

		public function unflagChanges():void
		{
            executeUpdate("UPDATE ACTIVITY SET OFFLINE_OPERATION=''");
		}
		
		override protected function processRow(o:Object):Object
		{
			var activity:Activity = new Activity();
			activity.id = o.ID;
			var contact:Contact = new Contact();
			contact.contactId = o.CONTACT_ID;
			contact.loaded = false;
			activity.contact = contact;
			activity.type = o.TYPE;
			activity.phoneNumber = o.PHONE_NUMBER;
			activity.notes = o.NOTES;
			activity.startTime = o.START_TIME;
			activity.endTime = o.END_TIME;
			activity.lastUpdated = o.LAST_UPDATED;
			activity.offlineOperation = o.OFFLINE_OPERATION;
			return activity;
		}
		
	}
}