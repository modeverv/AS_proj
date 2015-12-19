package com.salesbuilder.util
{
	import com.salesbuilder.dao.ContactDAO;
	import com.salesbuilder.dao.OpportunityDAO;
	import com.salesbuilder.events.AccountEvent;
	import com.salesbuilder.events.ContactEvent;
	import com.salesbuilder.events.OpportunityEvent;
	import com.salesbuilder.model.Account;
	import com.salesbuilder.model.Contact;
	import com.salesbuilder.model.Opportunity;
	import com.salesbuilder.view.AccountPanel;
	import com.salesbuilder.view.ContactPanel;
	import com.salesbuilder.view.OpportunityPanel;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.containers.TabNavigator;
	import mx.core.Application;
	import mx.core.Container;
	
	public class TabManager
	{
		public var _tabNavigator:TabNavigator;

		public function set tabNavigator(tabNavigator:TabNavigator):void
		{
			_tabNavigator = tabNavigator;
			_tabNavigator.addEventListener(Event.CLOSE, 
				function(event:Event):void
				{
					_tabNavigator.removeChild(_tabNavigator.selectedChild);
				});
			var application:Application = Application.application as Application;
			application.addEventListener(AccountEvent.OPEN, 
				function(event:AccountEvent):void
				{
					openAccount(event.account);	
				});
			application.addEventListener(AccountEvent.NEW, 
				function(event:AccountEvent):void
				{
					openAccount(new Account());	
				});
			application.addEventListener(ContactEvent.OPEN, 
				function(event:ContactEvent):void
				{
					if (event.contact)
					{
						openContact(event.contact);	
					}
					else 
					{
						openContactById(event.contactId);
					}
				});
			application.addEventListener(OpportunityEvent.OPEN, 
				function(event:OpportunityEvent):void
				{
					openOpportunity(event.opportunity);	
				});
		}

		public function openAccount(account:Account):AccountPanel
		{
			var accountPanel:AccountPanel = findAccountPanel(account.accountId);
			if (accountPanel == null)
			{			
				accountPanel = new AccountPanel();
				accountPanel.account = account;
				_tabNavigator.addChild(accountPanel);
			}
			_tabNavigator.selectedChild = accountPanel;
			return accountPanel;
		}
		
		public function findAccountPanel(accountId:int):AccountPanel
		{
			var accountPanel:AccountPanel;
			var length:int = _tabNavigator.getChildren().length;
			if (length == 0) return null;
			for (var i:int=0; i < length; i++)
			{
				var tab:DisplayObject = _tabNavigator.getChildAt(i);
				if (tab is AccountPanel)
				{
					accountPanel = tab as AccountPanel;
					if (accountPanel.account.accountId != 0 && accountPanel.account.accountId == accountId)
					{
						return accountPanel;
					}		
				}
			}
			return null;
		}

		public function openContact(contact:Contact):ContactPanel
		{
			var contactPanel:ContactPanel = findContactPanel(contact.contactId);
			if (contactPanel == null)
			{			
				contactPanel = new ContactPanel();
				contactPanel.contact = contact;
				_tabNavigator.addChild(contactPanel);
			}
			_tabNavigator.selectedChild = contactPanel;
			return contactPanel;
		}

		public function openContactById(contactId:int):void
		{
			var contactPanel:ContactPanel = findContactPanel(contactId);
			if (contactPanel == null)
			{			
				contactPanel = new ContactPanel();
				var contactDAO:ContactDAO = new ContactDAO();
				contactPanel.contact = contactDAO.getItem(contactId);
				_tabNavigator.addChild(contactPanel);
			}
			_tabNavigator.selectedChild = contactPanel;
		}

		public function findContactPanel(contactId:int):ContactPanel
		{
			var contactPanel:ContactPanel;
			var length:int = _tabNavigator.getChildren().length;
			if (length == 0) return null;
			for (var i:int=0; i < length; i++)
			{
				var tab:DisplayObject = _tabNavigator.getChildAt(i);
				if (tab is ContactPanel)
				{
					contactPanel = tab as ContactPanel;
					if (contactPanel.contact.contactId != 0 && contactPanel.contact.contactId == contactId)
					{
						return contactPanel;
					}		
				}
			}
			return null;
		}

		public function openOpportunity(opportunity:Opportunity):OpportunityPanel
		{
			var opportunityPanel:OpportunityPanel = findOpportunityPanel(opportunity.opportunityId);
			if (opportunityPanel == null)
			{			
				opportunityPanel = new OpportunityPanel();
				opportunityPanel.opportunity = opportunity;
				_tabNavigator.addChild(opportunityPanel);
			}
			_tabNavigator.selectedChild = opportunityPanel;
			return opportunityPanel;
		}

		public function openOpportunityById(opportunityId:int):void
		{
			var opportunityPanel:OpportunityPanel = findOpportunityPanel(opportunityId);
			if (opportunityPanel == null)
			{			
				opportunityPanel = new OpportunityPanel();
				var opportunityDAO:OpportunityDAO = new OpportunityDAO();
				opportunityPanel.opportunity = opportunityDAO.getItem(opportunityId);
				_tabNavigator.addChild(opportunityPanel);
			}
			_tabNavigator.selectedChild = opportunityPanel;
		}
		
		public function findOpportunityPanel(opportunityId:int):OpportunityPanel
		{
			var opportunityPanel:OpportunityPanel;
			var length:int = _tabNavigator.getChildren().length;
			if (length == 0) return null;
			for (var i:int=0; i < length; i++)
			{
				var tab:DisplayObject = _tabNavigator.getChildAt(i);
				if (tab is OpportunityPanel)
				{
					opportunityPanel = tab as OpportunityPanel;
					if (opportunityPanel.opportunity.opportunityId != 0 && opportunityPanel.opportunity.opportunityId == opportunityId)
					{
						return opportunityPanel;
					}		
				}
			}
			return null;
		}

		public function openTab(clazz:Class):void
		{
			var length:int = _tabNavigator.getChildren().length;
			for (var i:int=0; i < length; i++)
			{
				var tab:DisplayObject = _tabNavigator.getChildAt(i);
				if (tab is clazz)
				{
					_tabNavigator.selectedChild = tab as Container;
					return;
				}
			}
			_tabNavigator.selectedChild = _tabNavigator.addChild(new clazz()) as Container;
		}

	}
}