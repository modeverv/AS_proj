package com.salesbuilder.util
{
	import com.salesbuilder.context.Context;
	import com.salesbuilder.dao.AccountDAO;
	import com.salesbuilder.dao.CalendarItemDAO;
	import com.salesbuilder.dao.ContactDAO;
	import com.salesbuilder.dao.OpportunityDAO;
	import com.salesbuilder.events.DataSyncEvent;
	import com.salesbuilder.events.EventManager;
	import com.salesbuilder.model.Account;
	import com.salesbuilder.model.CalendarItemModel;
	import com.salesbuilder.model.Contact;
	import com.salesbuilder.model.Opportunity;
	import com.salesbuilder.view.SyncDialog;
	
	import flash.data.SQLConnection;
	import flash.data.SQLTransactionLockType;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import ilog.utils.GregorianCalendar;
	import ilog.utils.TimeUnit;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.AsyncToken;
	import mx.rpc.Responder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	public class SyncManager
	{
		private var serverAccounts:ArrayCollection;
		private var serverCalendarItems:ArrayCollection;
		
		private var localAccounts:ArrayCollection;
		private var localContacts:ArrayCollection;
		private var localOpportunities:ArrayCollection;
		private var localCalendarItems:ArrayCollection;
		
		private var syncDialog:SyncDialog;
		private var count:int = 0;

		private var sqlConnection:SQLConnection;
		
		public function SyncManager()
		{
			sqlConnection = Context.getAttribute("sqlConnection");
		}
		
		public function synchronize():void
		{
        	syncDialog = new SyncDialog();
			syncDialog.open();

			// Get server data
			var srv:HTTPService = new HTTPService();
			srv.url = "data/serverdata.xml";
			var token:AsyncToken = srv.send();
			token.addResponder(new Responder(
				function (event:ResultEvent):void
				{
					serverAccounts = event.result.data.account;
					serverCalendarItems = event.result.data.calendaritem;
					serverToLocal();
				},
				function (event:FaultEvent):void
				{
					Alert.show(event.fault.faultString);
				}));
		}
 
		private function serverToLocal():void
		{
			var accountDAO:AccountDAO = new AccountDAO();
			localAccounts = accountDAO.findAll();
			var contactDAO:ContactDAO = new ContactDAO();
			localContacts = contactDAO.findAll();
			var opportunityDAO:OpportunityDAO = new OpportunityDAO();
			localOpportunities = opportunityDAO.findAll();
			var calendarItemDAO:CalendarItemDAO = new CalendarItemDAO();
			localCalendarItems = calendarItemDAO.findAll();
			
			sqlConnection.begin(SQLTransactionLockType.IMMEDIATE);

			for (var i:int=0; serverAccounts!=null && i<serverAccounts.length; i++)
			{
				var xmlAccount:Object = serverAccounts.getItemAt(i);
				var account:Account = typeAccount(xmlAccount);
				var localAccount:Account = findLocalAccount(account.accountId);

				if (localAccount == null)
				{
					syncDialog.logMessage("Creating local account " + account.name);
					accountDAO.create(account);
					count++;
				}
				else if (localAccount.lastUpdated < account.lastUpdated)
				{
					syncDialog.logMessage("Updating local account " + account.name);
					accountDAO.update(account);
					count++;
				}
					
				for (var j:int=0; xmlAccount.contact!=null && j<xmlAccount.contact.length; j++)
				{
					var contact:Contact = typeContact(xmlAccount.contact.getItemAt(j));
					contact.account = account;
					
					var localContact:Contact = findLocalContact(contact.contactId);
	
					if (localContact == null)
					{
						syncDialog.logMessage("Creating local contact " + contact.firstName + " " + contact.lastName);
						contactDAO.create(contact);
						count++;
					}
					else if (localContact.lastUpdated < contact.lastUpdated)
					{
						syncDialog.logMessage("Updating local contact " + contact.firstName + " " + contact.lastName);
						contactDAO.update(contact);
						count++;
					}
				}
				
				for (var k:int=0; xmlAccount.opportunity!=null && k<xmlAccount.opportunity.length; k++)
				{
					var opportunity:Opportunity = typeOpportunity(xmlAccount.opportunity.getItemAt(k));
					opportunity.account = account;
					
					var localOpportunity:Opportunity = findLocalOpportunity(opportunity.opportunityId);
	
					if (localOpportunity == null)
					{
						syncDialog.logMessage("Creating local opportunity " + opportunity.name);
						opportunityDAO.create(opportunity);
						count++;
					}
					else if (localOpportunity.lastUpdated < opportunity.lastUpdated)
					{
						syncDialog.logMessage("Updating local opportunity " + opportunity.name);
						opportunityDAO.update(opportunity);
						count++;
					}
				}
			}
			
			for (var l:int=0; serverCalendarItems!=null && l<serverCalendarItems.length; l++)
			{
				var serverItem:CalendarItemModel = typeCalendarItem(serverCalendarItems.getItemAt(l));
				var localItem:CalendarItemModel = calendarItemDAO.getItem(serverItem.id);
				if (localItem == null)
				{
					syncDialog.logMessage("Creating local calendar item " + serverItem.summary);
					calendarItemDAO.create(serverItem);
					count++;
				}
				else if (localItem.lastUpdated < serverItem.lastUpdated)
				{
					syncDialog.logMessage("Updating local calendar item " + serverItem.summary);
					calendarItemDAO.update(serverItem);
					count++;
				}
			}
			
			sqlConnection.commit();
			localToServer();
		}

		private function findLocalAccount(accountId:int):Account
		{
			if (!localAccounts) return null;
			for (var i:int=0; i<localAccounts.length; i++)
			{
				var account:Account = localAccounts.getItemAt(i) as Account;
				if (account.accountId == accountId)
				{
					return account;
				}
			}
			return null;
		}

		private function findLocalContact(contactId:int):Contact
		{
			if (!localContacts) return null;
			for (var i:int=0; i<localContacts.length; i++)
			{
				var contact:Contact = localContacts.getItemAt(i) as Contact;
				if (contact.contactId == contactId)
				{
					return contact;
				}
			}
			return null;
		}

		private function findLocalOpportunity(opportunityId:int):Opportunity
		{
			if (!localOpportunities) return null;
			for (var i:int=0; i<localOpportunities.length; i++)
			{
				var opportunity:Opportunity = localOpportunities.getItemAt(i) as Opportunity;
				if (opportunity.opportunityId == opportunityId)
				{
					return opportunity;
				}
			}
			return null;
		}

		private function findLocalCalendarItem(id:int):CalendarItemModel
		{
			if (!localCalendarItems) return null;
			for (var i:int=0; i<localCalendarItems.length; i++)
			{
				var item:CalendarItemModel = localCalendarItems.getItemAt(i) as CalendarItemModel;
				if (item.id == id)
				{
					return item;
				}
			}
			return null;
		}

		private function localToServer():void
		{
			var accountDAO:AccountDAO = new AccountDAO();
			localAccounts = accountDAO.getChanges();
			var contactDAO:ContactDAO = new ContactDAO();
			localContacts = contactDAO.getChanges();
			var opportunityDAO:OpportunityDAO = new OpportunityDAO();
			localOpportunities = opportunityDAO.getChanges();
			var calendarItemDAO:CalendarItemDAO = new CalendarItemDAO();
			localCalendarItems = calendarItemDAO.getChanges();

			for (var i:int=0; localAccounts && i<localAccounts.length; i++)
			{
				var localAccount:Account = localAccounts.getItemAt(i) as Account;
				if (localAccount.offlineOperation == "INSERT")
				{
					syncDialog.logMessage("Creating server account " + localAccount.name);
					count++;
				}
				else if (localAccount.offlineOperation == "UPDATE")
				{
					syncDialog.logMessage("Updating server account " + localAccount.name);
					count++;
				}
			}

			for (var j:int=0; localContacts && j<localContacts.length; j++)
			{
				var localContact:Contact = localContacts.getItemAt(j) as Contact;
				if (localContact.offlineOperation == "INSERT")
				{
					syncDialog.logMessage("Creating server contact " + localContact.firstName + " " + localContact.lastName);
					count++;
				}
				else if (localContact.offlineOperation == "UPDATE")
				{
					syncDialog.logMessage("Updating server contact " + localContact.firstName + " " + localContact.lastName);
					count++;
				}
			}
			for (var k:int=0; localOpportunities && k<localOpportunities.length; k++)
			{
				var localOpportunity:Opportunity = localOpportunities.getItemAt(k) as Opportunity;
				if (localOpportunity.offlineOperation == "INSERT")
				{
					syncDialog.logMessage("Creating server opportunity " + localOpportunity.name);
					count++;
				}
				else if (localOpportunity.offlineOperation == "UPDATE")
				{
					syncDialog.logMessage("Updating server opportunity " + localOpportunity.name);
					count++;
				}
			}

			for (var l:int=0; localCalendarItems && l<localCalendarItems.length; l++)
			{
				var localItem:CalendarItemModel = localCalendarItems.getItemAt(l) as CalendarItemModel;
				if (localItem.offlineOperation == "INSERT")
				{
					syncDialog.logMessage("Creating server calendar item " + localItem.summary);
					count++;
				}
				else if (localItem.offlineOperation == "UPDATE")
				{
					syncDialog.logMessage("Updating server calendar item  " + localItem.summary);
					count++;
				}
				else if (localItem.offlineOperation == "DELETE")
				{
					syncDialog.logMessage("Deleting server calendar item  " + localItem.summary);
					count++;
				}
			}
			syncDialog.logMessage("Synchronization complete (" + count + " items synchronized)");
			accountDAO.unflagChanges();
			contactDAO.unflagChanges();
			opportunityDAO.unflagChanges();
			calendarItemDAO.unflagChanges();
			syncDialog.completeSync(count);
			
			EventManager.dispatchEvent(new DataSyncEvent(DataSyncEvent.COMPLETE));
		}

		protected function typeAccount(o:Object):Account
		{
			var a:Account = new Account();
			a.accountId = o.accountId;
			a.annualRevenue = Number(o.annualRevenue);
			a.address1 = o.address1;
			a.address2 = o.address2;
			a.city = o.city;
			a.state = o.state;
			a.zip = o.zip;
			a.fax = o.fax;
			a.industry = o.industry;
			a.lastUpdated = Number(o.lastUpdated);
			a.name = o.name;
			a.notes = o.notes;
			a.numberEmployees = parseInt(o.numberEmployees);
			a.owner = o.owner;
			a.ownership = o.ownership;
			a.phone = o.phone;
			a.priority = o.priority
			a.rating = parseInt(o.rating);
			a.url = o.url;
			a.ticker = o.ticker
			a.type = o.type;
			a.currentYearResults = Number(o.currentYearResults);
			a.lastYearResults = Number(o.lastYearResults);
			a.offlineOperation = o.offlineOperation;
			return a;
		}
		
		protected function typeContact(o:Object):Contact
		{
			var c:Contact = new Contact();
			c.manager = new Contact();
			var manager:Contact = new Contact();
			manager.contactId = o.managerId;
			c.manager = manager;
			c.address1 = o.address1;
			c.address2 = o.address2;
			c.cellPhone = o.cellPhone;
			c.city = o.city;
			c.contactId = o.contactId;
			c.email = o.email;
			c.fax = o.fax;
			c.firstName = o.firstName;
			c.lastName = o.lastName;
			c.lastUpdated = Number(o.lastUpdated);
			c.notes = o.notes;
			c.officePhone = o.officePhone;
			c.offlineOperation = o.offlineOperation;
			c.owner = parseInt(o.owner);
			c.state = o.state;
			c.title = o.title;
			c.zip = o.zip;
			c.priority = parseInt(o.priority);

			if (o.picture)
			{			
				var bytes:ByteArray = new ByteArray();
				var file:File = File.applicationDirectory.resolvePath("pics/"+o.picture);
				if (file.exists)
				{
					var stream:FileStream = new FileStream();
		 			stream.open(file, FileMode.READ);
					stream.readBytes(bytes);
					stream.close();
					c.picture = bytes
				}
				else
				{
					trace("File " + file.nativePath + " does not exist");
				}
			}
 			return c;
		}

		protected function typeOpportunity(o:Object):Opportunity
		{
			var opp:Opportunity = new Opportunity();
			opp.opportunityId = o.opportunityId;
			opp.name = o.name;
			opp.owner = parseInt(o.owner);
			opp.expectedCloseDate = new Date(new Date().time + o.daysBeforeClose * 24 * 60 * 60 * 1000);
			opp.expectedAmount = o.expectedAmount;
			opp.probability = o.probability;
			opp.status = o.status;
			opp.leadSource = o.leadSource;
			opp.notes = o.notes;
			opp.lastUpdated = Number(o.lastUpdated);
			opp.offlineOperation = o.offlineOperation;
			return opp;
		}

		protected function typeCalendarItem(o:Object):CalendarItemModel
		{
			var gc:GregorianCalendar = new GregorianCalendar();
			var item:CalendarItemModel = new CalendarItemModel();
			item.id = o.id;
			item.startTime = gc.addUnits(new Date(), TimeUnit.DAY, o.dayOffset);
			item.startTime.hours = o.hours;
			item.startTime.minutes = o.minutes;
			item.endTime = gc.addUnits(item.startTime, TimeUnit.MINUTE, o.length);
			item.summary = o.summary;
			item.description = o.description;
			item.lastUpdated = Number(o.lastUpdated);
			return item;
		}


	}

}