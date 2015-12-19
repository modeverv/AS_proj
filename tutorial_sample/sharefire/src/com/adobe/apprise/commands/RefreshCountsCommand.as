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
	import com.adobe.apprise.database.*;
	import com.adobe.apprise.events.NotifyEvent;
	import com.adobe.apprise.events.RefreshCountsEvent;
	import com.adobe.apprise.events.UpdateIconsEvent;
	import com.adobe.apprise.model.ModelLocator;
	import com.adobe.apprise.util.AppriseUtils;
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import mx.resources.ResourceManager;
	
	public class RefreshCountsCommand implements ICommand
	{
		private var _currentSmartFolderIndex:int;
		private var _notifyAfterCountingSmartFolders:Boolean;
		
		private function tallyUnread(tree:Array, totals:Array, folderTotal:uint = 0):uint
		{
			var ml:ModelLocator = ModelLocator.getInstance();
			for each (var node:Object in tree)
			{
				if (node.children)
				{
					var oldTotal:uint = folderTotal;
					folderTotal = 0;
					node.unread = this.tallyUnread(node.children.source, totals, folderTotal);
					folderTotal = oldTotal + node.unread;
					ml.feeds.itemUpdated(node, "unread");
				}
				else
				{
					node.unread = 0;
					for each (var total:Object in totals)
					{
						if (node.id == total.id)
						{
							node.unread = total.unread;
							if ( node.parent != -1 ) //do not set folder total if you are not in a folder. 
							{
								folderTotal += total.unread;
							}
							ml.feeds.itemUpdated(node, "unread");
							break;
						}
					}
					ml.feeds.itemUpdated(node, "unread");
				}
			}
			return folderTotal;			
		}
		
		//not used at the moment
		private function tallyFeeds(node:Object, runningTotal:uint = 0):uint
		{
			for each ( var o:Object in node ) 
			{
				if ( o.children ) 
				{
					runningTotal += tallyFeeds(o.children);
				}
				else 
				{
					runningTotal += 1;
				}
			}
			return runningTotal;
		}
		
		public function execute(ce:CairngormEvent):void
		{
			this._notifyAfterCountingSmartFolders = RefreshCountsEvent(ce).notifyAfterCountingSmartFolders;
			var ml:ModelLocator = ModelLocator.getInstance();
			var db:Database = ml.db;

			// Total unread and total checked counts.

			var unreadResponder:DatabaseResponder = new DatabaseResponder();

			unreadResponder.addEventListener(DatabaseEvent.RESULT_EVENT,
				function(unreadEvent:DatabaseEvent):void
				{
					for each (var view:Object in ml.totals.source)
					{
						if (view.viewName == ResourceManager.getInstance().getString('resources', 'VIEWCONTROL_ALL_UNREAD'))
						{
							view.count = unreadEvent.data;
							ml.totals.itemUpdated(view, "count");
							break;
						}
					}
				});
			db.getUnreadCount(unreadResponder);

			var checkedResponder:DatabaseResponder = new DatabaseResponder();
			checkedResponder.addEventListener(DatabaseEvent.RESULT_EVENT,
				function(checkedEvent:DatabaseEvent):void
				{
					for each (var view:Object in ml.totals.source)
					{
						if (view.viewName == ResourceManager.getInstance().getString('resources', 'VIEWCONTROL_CHECKED'))
						{
							view.count = checkedEvent.data;
							ml.totals.itemUpdated(view, "count");
							break;
						}
					}
				});
			db.getCheckedCount(checkedResponder);


			// Feeds.

			var feedsResponder:DatabaseResponder = new DatabaseResponder();
			feedsResponder.addEventListener(DatabaseEvent.RESULT_EVENT,
				function(feedsEvent:DatabaseEvent):void
				{
					tallyUnread(ml.feeds.source, feedsEvent.data);
				});
			db.getUnreadFeeds(feedsResponder);

			// Authors.

			var authorsResponder:DatabaseResponder = new DatabaseResponder();
			authorsResponder.addEventListener(DatabaseEvent.RESULT_EVENT,
				function(authorEvent:DatabaseEvent):void
				{
					for each (var author:Object in ml.authors.source)
					{
						author.unread = 0;
						for each (var o:Object in authorEvent.data)
						{
							if (author.author == o.author)
							{
								author.unread = o.unread;
								break;
							}
						}
						ml.authors.itemUpdated(author, "unread");
					}
				});
			db.getUnreadAuthors(authorsResponder);


			// Topics.

			var topicsResponder:DatabaseResponder = new DatabaseResponder();
			topicsResponder.addEventListener(DatabaseEvent.RESULT_EVENT,
				function(topicsEvent:DatabaseEvent):void
				{
					for each (var topic:Object in ml.topics.source)
					{
						topic.unread = 0;
						for each (var o:Object in topicsEvent.data)
						{
							if (topic.topic == o.topic)
							{
								topic.unread = o.unread;
								break;
							}
						}
						ml.topics.itemUpdated(topic, "unread");
					}
				});
			db.getUnreadTopics(topicsResponder);
			
			// Smart Folders
			_currentSmartFolderIndex = 0;
			setSmartFolderCounts();
			
			// Update the application icon 
			new UpdateIconsEvent().dispatch();
		}
		
		private function setSmartFolderCounts():void
		{
			var ml:ModelLocator = ModelLocator.getInstance();
			if ( _currentSmartFolderIndex >= ml.smartFolders.length ) 
			{
				if ( _notifyAfterCountingSmartFolders )
				{
					var ne:NotifyEvent = new NotifyEvent();
					ne.dispatch();
				}
				return;						
			}
			
			var sqlQuery:String = "SELECT COUNT(DISTINCT(posts.id)) AS count FROM posts, smartFolders WHERE ";
			sqlQuery += AppriseUtils.getSearchString(ml.smartFolders.getItemAt(this._currentSmartFolderIndex).smart_folder_terms);
			sqlQuery += " AND posts.read = false";
			
			var responder:DatabaseResponder = new DatabaseResponder();
			responder.addEventListener(DatabaseEvent.RESULT_EVENT,
				function(e:DatabaseEvent):void
				{
					var currentFolder:Object = ml.smartFolders.getItemAt(_currentSmartFolderIndex);
					currentFolder.unread = e.data as int;
					ml.smartFolders.itemUpdated(currentFolder, "unread");
					_currentSmartFolderIndex++;
					setSmartFolderCounts();
				});
			ml.db.getSmartFolderUnread(responder, sqlQuery);			
		}
	}
}
