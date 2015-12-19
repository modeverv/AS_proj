/*
	Adobe Systems Incorporated(r) Source Code License Agreement
	Copyright(c) 2008 Adobe Systems Incorporated. All rights reserved.
	
	Please read this Source Code License Agreement carefully before using
	the source code.
	
	Adobe Systems Incorporated grants to you a perpetual, worldwide, non-exclusive, 
	no-charge, royalty-free, irrevocable copyright license, to reproduce,
	prepare derivative works of, publicly display, publicly perform, and
	distribute this source code and such derivative works in source or 
	object code form without any attribution requirements.  
	
	The name "Adobe Systems Incorporated" must not be used to endorse or promote products
	derived from the source code without prior written permission.
	
	You agree to indemnify, hold harmless and defend Adobe Systems Incorporated from and
	against any loss, damage, claims or lawsuits, including attorney's 
	fees that arise or result from your use or distribution of the source 
	code.
	
	THIS SOURCE CODE IS PROVIDED "AS IS" AND "WITH ALL FAULTS", WITHOUT 
	ANY TECHNICAL SUPPORT OR ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING,
	BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
	FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  ALSO, THERE IS NO WARRANTY OF 
	NON-INFRINGEMENT, TITLE OR QUIET ENJOYMENT.  IN NO EVENT SHALL MACROMEDIA
	OR ITS SUPPLIERS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
	EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
	PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
	OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
	WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
	OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOURCE CODE, EVEN IF
	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package com.adobe.apprise.commands
{
	import air.update.ApplicationUpdaterUI;
	
	import com.adobe.air.notification.NotificationQueue;
	import com.adobe.apprise.database.Database;
	import com.adobe.apprise.database.DatabaseEvent;
	import com.adobe.apprise.database.DatabaseResponder;
	import com.adobe.apprise.events.AIMInitEvent;
	import com.adobe.apprise.events.PopulateViewControlEvent;
	import com.adobe.apprise.events.PrunePostsEvent;
	import com.adobe.apprise.events.RefreshAllEvent;
	import com.adobe.apprise.events.UpdateIconsEvent;
	import com.adobe.apprise.model.ModelLocator;
	import com.adobe.apprise.util.AppriseUtils;
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.InvokeEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.*;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.resources.ResourceManager;
	
	public class InitCommand implements ICommand
	{
		public function execute(e:CairngormEvent):void
		{
			var ml:ModelLocator = ModelLocator.getInstance();

			// Set up the database
			var sqlFile:File = File.applicationDirectory.resolvePath("sql.xml");
			var sqlFileStream:FileStream = new FileStream();
			sqlFileStream.open(sqlFile, FileMode.READ);
			var sql:XML = new XML(sqlFileStream.readUTFBytes(sqlFileStream.bytesAvailable));
			sqlFileStream.close();
			var db:Database = new Database(sql);
			var responder:DatabaseResponder = new DatabaseResponder();
			responder.addEventListener(DatabaseEvent.RESULT_EVENT,
				function(e:DatabaseEvent):void
				{
					ml.db = db;
					createFeedsTable();
				});
			db.initialize(responder);
		}
		
		private function createFeedsTable():void
		{
			var responder:DatabaseResponder = new DatabaseResponder();
			responder.addEventListener(DatabaseEvent.RESULT_EVENT, createPostsTable);
			ModelLocator.getInstance().db.createFeedsTable(responder);			
		}

		private function createPostsTable(e:Event):void
		{
			var responder:DatabaseResponder = new DatabaseResponder();
			responder.addEventListener(DatabaseEvent.RESULT_EVENT, createAuthorsTable);
			ModelLocator.getInstance().db.createPostsTable(responder);			
		}

		private function createAuthorsTable(e:Event):void
		{
			var responder:DatabaseResponder = new DatabaseResponder();
			responder.addEventListener(DatabaseEvent.RESULT_EVENT, createTopicsTable);
			ModelLocator.getInstance().db.createAuthorsTable(responder);			
		}

		private function createTopicsTable(e:Event):void
		{
			var responder:DatabaseResponder = new DatabaseResponder();
			responder.addEventListener(DatabaseEvent.RESULT_EVENT, createSmartFoldersTable);
			ModelLocator.getInstance().db.createTopicsTable(responder);			
		}
		
		private function createSmartFoldersTable(e:Event):void
		{
			var responder:DatabaseResponder = new DatabaseResponder();
			responder.addEventListener(DatabaseEvent.RESULT_EVENT, start)
			ModelLocator.getInstance().db.createSmartFoldersTable(responder);					
		}
		
		private function start(e:Event):void
		{
			var ml:ModelLocator = ModelLocator.getInstance();
			ml.db.initSynchronousConnection();
			// Initialize data.
			ml.statusMessage = ResourceManager.getInstance().getString('resources', 'INIT_WELCOME_MSG');
			ml.posts = new ArrayCollection();

			// Listen for InvokeEvents
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE,
				function(e:InvokeEvent):void
				{
					if ( e.arguments.length > 0 && new RegExp("^(http(s?)|feed):\/\/.+$","i").exec(e.arguments[0]) )
					{						
						ml.feedDrawerDefaultURL = e.arguments[0];
						ml.isFeedDrawerOpen = true; 
					}
				});

			// Set up preferences, assign defaults if necessary			
			if (ml.preferences.getValue("feedUpdateInterval") == null)
			{
				ml.preferences.setValue("feedUpdateInterval", 0.5, false);
			}
			if (ml.preferences.getValue("appUpdateEnabled") == null)
			{
				ml.preferences.setValue("appUpdateEnabled", 1, false);
			}
			if (ml.preferences.getValue("appUpdateInterval") == null)
			{				
				ml.preferences.setValue("appUpdateInterval", 7, false); //7 days				
			}			
			ml.preferences.save();			
						
			// Set application language, based on preferences.			
			AppriseUtils.reorderLocaleChain();

			// Set up the application updater
			ml.appUpdater = new ApplicationUpdaterUI();
			ml.appUpdater.configurationFile = File.applicationDirectory.resolvePath("updaterSettings.xml");			
			ml.appUpdater.delay = ml.preferences.getValue("appUpdateInterval");			
			if ( ml.preferences.getValue("appUpdateEnabled") )
			{
				ml.appUpdater.initialize();
			}		
			
			// Set up the feed update timer			
			ml.updateTimer = new Timer(ml.preferences.getValue("feedUpdateInterval") * 60 * 60 * 1000);
			ml.updateTimer.addEventListener(TimerEvent.TIMER,
				function(e:TimerEvent):void
				{
					new RefreshAllEvent().dispatch();
				});
			ml.updateTimer.start();

			// Set post pruning timer
			ml.prunePostsTimer = new Timer(24 * 60 * 60 * 1000); // 24 hours
			ml.prunePostsTimer.addEventListener(TimerEvent.TIMER,
				function(e:TimerEvent):void
				{
					new PrunePostsEvent().dispatch();
				});
			ml.prunePostsTimer.start();
			
			// Populate the view control
			var pvce:PopulateViewControlEvent = new PopulateViewControlEvent;
			var populateResponder:CommandResponder = new CommandResponder();
			populateResponder.addEventListener(Event.COMPLETE,
				function(e:Event):void
				{
					// Go ahead and do the first prune
					var ppeResponder:CommandResponder = new CommandResponder();
					ppeResponder.addEventListener(Event.COMPLETE,
						function(e:Event):void
						{
							// Do the initial aggregation.					
							new RefreshAllEvent().dispatch();
						});
					var ppe:PrunePostsEvent = new PrunePostsEvent();
					ppe.responder = ppeResponder;
					ppe.dispatch();
				});
			pvce.responder = populateResponder;
			pvce.dispatch();
			
			// Update the application icon.
			new UpdateIconsEvent().dispatch();
			
			// Show the application window.
			NativeApplication.nativeApplication.openedWindows[0].visible = true;
			
			// Sign on to AIM, based on user preferences
			var aimInitEvent:AIMInitEvent = new AIMInitEvent;
			aimInitEvent.connect = true;
			aimInitEvent.dispatch();		
			
			// Setup notification queue
			ml.notificationQueue = new NotificationQueue();	
		}
	}
}
