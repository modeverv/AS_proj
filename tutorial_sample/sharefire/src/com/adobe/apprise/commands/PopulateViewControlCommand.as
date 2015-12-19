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
	import com.adobe.apprise.events.PopulateViewControlEvent;
	import com.adobe.apprise.events.RefreshCountsEvent;
	import com.adobe.apprise.events.SaveSortOrderEvent;
	import com.adobe.apprise.model.ModelLocator;
	import com.adobe.apprise.util.AppriseUtils;
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	public class PopulateViewControlCommand implements ICommand
	{			
		private var _skipFeeds:Boolean;		
		private var _responder:CommandResponder;				
		
		public function execute(ce:CairngormEvent):void
		{
			this._skipFeeds = PopulateViewControlEvent(ce).skipFeeds;
			this._responder = PopulateViewControlEvent(ce).responder;			
			this.getFeeds( (ce as PopulateViewControlEvent).saveSortOrder );
		}

		private function getFeeds(saveSortOrder:Boolean):void
		{
			if ( this._skipFeeds ) 
			{
				getAuthors();
				return;
			}			
			var ml:ModelLocator = ModelLocator.getInstance();
			ml.feeds = new ArrayCollection();
			var feedsResponder:DatabaseResponder = new DatabaseResponder();
			feedsResponder.addEventListener(DatabaseEvent.RESULT_EVENT,
				function(feedsEvent:DatabaseEvent):void
				{
					var fa:Array = feedsEvent.data as Array;
					var lineup:Object = new Object();
					
					var rootArray:Array = new Array();
					
					for each (var feed:Object in fa)
					{
						lineup[feed.id] = feed;
						if (feed.is_folder) feed.children = new Array();
					}

					for each (var feed2:Object in fa)
					{
						if (feed2.parent != -1)
						{
							var parent:Object = lineup[feed2.parent];
							parent.children.push(feed2);
						}
					}
					
					for each (var feed3:Object in fa)
					{
						if (feed3.parent == -1)
						{
							rootArray.push(feed3);
						}
					}
					
					for each (var feed4:Object in fa) 
					{
						if (feed4.children)
						{
							feed4.children = new ArrayCollection(feed4.children);
						}
					}
					ml.feeds = new ArrayCollection(rootArray);
					if ( saveSortOrder ) 
					{						
						var sso:SaveSortOrderEvent = new SaveSortOrderEvent();
						sso.feedStructure = ml.feeds;
						sso.dispatch();						
					}					
					getAuthors();
				});
			ml.db.getFeeds(feedsResponder);
		}

		private function getAuthors():void
		{
			var ml:ModelLocator = ModelLocator.getInstance();
			ml.authors = new ArrayCollection();
			var authorsResponder:DatabaseResponder = new DatabaseResponder();
			authorsResponder.addEventListener(DatabaseEvent.RESULT_EVENT,
				function(authorEvent:DatabaseEvent):void
				{
					ml.authors.source = authorEvent.data;
					getTopics();
				});
			ml.db.getAuthors(authorsResponder);
		}

		private function getTopics():void
		{
			var ml:ModelLocator = ModelLocator.getInstance();
			ml.topics = new ArrayCollection();
			var topicsResponder:DatabaseResponder = new DatabaseResponder();
			topicsResponder.addEventListener(DatabaseEvent.RESULT_EVENT,
				function(topicsEvent:DatabaseEvent):void
				{
					ml.topics.source = topicsEvent.data;
					getSmartFolders();
					ml.autoOpenFolders = true; //all the data is in. have the tree auto open to where the user left it
				});
			ml.db.getTopics(topicsResponder);
		}
		
		private function getSmartFolders():void
		{
			var ml:ModelLocator = ModelLocator.getInstance();
			ml.smartFolders = new ArrayCollection();
			var smartFoldersResponder:DatabaseResponder = new DatabaseResponder();
			smartFoldersResponder.addEventListener(DatabaseEvent.RESULT_EVENT,
				function(smartFoldersEvent:DatabaseEvent):void
				{
					ml.smartFolders.source = smartFoldersEvent.data;
					//need to convert the smart_folder_terms from strings to a real array
					for each ( var smartFolder:Object in ml.smartFolders )
					{						
						smartFolder.smart_folder_terms = AppriseUtils.getSmartFolderTermsArrayFromString(smartFolder.smart_folder_terms);
					}
					if ( _responder ) 
					{
						_responder.dispatchEvent(new Event(Event.COMPLETE));
					}  					
					var rce:RefreshCountsEvent = new RefreshCountsEvent();					
					rce.dispatch();
				});
			ml.db.getSmartFolders(smartFoldersResponder);
		}
	}
}
