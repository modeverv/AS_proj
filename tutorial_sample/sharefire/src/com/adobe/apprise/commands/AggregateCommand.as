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
	import com.adobe.apprise.aggregator.Aggregator;
	import com.adobe.apprise.aggregator.AggregatorEvent;
	import com.adobe.apprise.aggregator.AggregatorResponder;
	import com.adobe.apprise.database.DatabaseEvent;
	import com.adobe.apprise.database.DatabaseResponder;
	import com.adobe.apprise.events.AggregateEvent;
	import com.adobe.apprise.events.NotifyEvent;
	import com.adobe.apprise.events.PopulateViewControlEvent;
	import com.adobe.apprise.events.RefreshCountsEvent;
	import com.adobe.apprise.model.ModelLocator;
	import com.adobe.apprise.util.AppriseUtils;
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.xml.syndication.generic.Author;
	import com.adobe.xml.syndication.generic.IFeed;
	import com.adobe.xml.syndication.generic.IItem;
	
	import flash.events.IOErrorEvent;
	
	import mx.collections.ArrayCollection;
	import mx.formatters.DateFormatter;
	import mx.resources.ResourceManager;

	public class AggregateCommand implements ICommand
	{
		private var dateFormatter:DateFormatter;

		public function AggregateCommand()
		{
			this.dateFormatter = new DateFormatter();
			dateFormatter.formatString = ResourceManager.getInstance().getString('resources', 'AGGREGATECOMMAND_DATE_FORMATTER');
		}

		public function execute(ce:CairngormEvent):void
		{			
			ModelLocator.getInstance().currentlyAggregating = true;
			var state:Object = new Object();
			state.feeds = AggregateEvent(ce).feeds;
			state.totalNewPosts = 0; //for all posts
			state.countedOnce = false; //set to true when the first smart folder tally has been made
			state.beforeSmartFolderCount = 0; //for smart folder comparison
			state.afterSmartFolderCount = 0;
			state.smartFolderIndex = 0; 			
			
			this.tallySmartFolderCounts(state);			
		}
		
		private function notifyUserOfNewPosts(smartFolderPosts:uint, totalNewPosts:uint):void
		{
			var ne:NotifyEvent = new NotifyEvent();
			ne.smartFoldersNewPosts = smartFolderPosts;
			ne.totalNewPosts = totalNewPosts;
			ne.dispatch();
		}
		
		private function tallySmartFolderCounts(state:Object):void
		{
			var ml:ModelLocator = ModelLocator.getInstance();			
			if ( !ml.smartFolders || state.smartFolderIndex >= ml.smartFolders.length )
			{
				state.smartFolderIndex = 0;
				if ( state.countedOnce)
				{
					//second pass
					var newSmartFolderPosts:int = state.afterSmartFolderCount - state.beforeSmartFolderCount;
					this.notifyUserOfNewPosts(newSmartFolderPosts, state.totalNewPosts);
				}
				else
				{
					state.countedOnce = true;
					this.aggregate(state);
				}
				return;
			}
			var currentFolder:Object = ml.smartFolders.getItemAt(state.smartFolderIndex);
			// Only tally Smart Folders that participate in notifications!
			if ( !currentFolder.notify_on_update ) 
			{
				state.smartFolderIndex++;
				tallySmartFolderCounts(state);
			}
			
			var responder:DatabaseResponder = new DatabaseResponder();
			responder.addEventListener(DatabaseEvent.RESULT_EVENT,
				function(e:DatabaseEvent):void
				{					
					var smartFolderCount:int;					
					if ( state.countedOnce ) 
					{						
						state.afterSmartFolderCount += e.data as int;						
					}
					else
					{
						state.beforeSmartFolderCount += e.data as int;						
					}								
					state.smartFolderIndex++;
					tallySmartFolderCounts(state);
				});
			var sqlQuery:String = "SELECT COUNT(DISTINCT(posts.id)) AS count FROM posts, smartFolders WHERE ";
			sqlQuery += AppriseUtils.getSearchString(ml.smartFolders.getItemAt(state.smartFolderIndex).smart_folder_terms);
			ml.db.getSmartFolderUnread(responder, sqlQuery);						
		}
		
		private function aggregate(state:Object):void
		{
			var feeds:Array = state.feeds as Array;
			var ml:ModelLocator = ModelLocator.getInstance();
			if (ml.db.aConn.inTransaction && ml.db.aConn.connected)
			{
				ml.db.aConn.commit();
			}
			
			if (feeds == null || feeds.length == 0 || ModelLocator.getInstance().stopAggregating)
			{
				ml.statusMessage = ResourceManager.getInstance().getString('resources', 'AGGREGATECOMMAND_LAST_UPDATED_STATUS').replace("$1", this.dateFormatter.format(new Date()));
				ml.currentlyAggregating = false;
				ml.stopAggregating = false;
				ml.deletedFeedUrls = null;
				
				var pvce:PopulateViewControlEvent = new PopulateViewControlEvent();
				pvce.skipFeeds = true;				
				pvce.dispatch();
				
				this.tallySmartFolderCounts(state);				
				return;
			}
						
			var feedUrl:String = feeds.shift();
			if ( ml.deletedFeedUrls && ml.deletedFeedUrls.contains(feedUrl) )
			{				
				var index:int = ml.deletedFeedUrls.getItemIndex(feedUrl);
				ml.deletedFeedUrls.removeItemAt(index);
				if ( ml.deletedFeedUrls.length == 0 ) 
				{
					ml.deletedFeedUrls = null; //remove it from memory
				}
				
				feeds.shift();
				state.feeds = feeds;
				aggregate(state);
				return;
			}
			
			var aggregator:Aggregator = new Aggregator();
			var aggregatorResponder:AggregatorResponder = new AggregatorResponder();

			ml.currentAggregatorResponder = aggregatorResponder;

			aggregatorResponder.addEventListener(AggregatorEvent.ERROR_EVENT,
				function(aggErrorEvent:AggregatorEvent):void
				{
					trace("AGGREGATOR ERROR", aggErrorEvent.data, feedUrl);
					state.feedUrl = feedUrl;
					state.errorMessage = "Unable to aggregate: " + aggErrorEvent.data;
					handleFeedError(state);
				});

			aggregatorResponder.addEventListener(IOErrorEvent.IO_ERROR,
				function(ioErrorEvent:IOErrorEvent):void
				{
					trace("IOError", ioErrorEvent, feedUrl);
					// I think I'd rather not record an error for an IOError.  You might just be offline.
					//state.feedUrl = feedUrl;
					//state.errorMessage = "Network error: " + ioErrorEvent.text;
					//handleFeedError(state);
					aggregate(state);
				});

			aggregatorResponder.addEventListener(AggregatorEvent.FEED_EVENT,
				function(feedEvent:AggregatorEvent):void
				{
					var feed:IFeed = feedEvent.data as IFeed;					
					var responder:DatabaseResponder = new DatabaseResponder();
					responder.addEventListener(DatabaseEvent.RESULT_EVENT,
						function(e:DatabaseEvent):void
						{
							var feedId:Number = e.data as Number;
							if (!ModelLocator.getInstance().db.aConn.inTransaction)
							{
								ModelLocator.getInstance().db.aConn.begin();
							}
							state.newPostCount = 0;
							if (feedId == -1) // New feed.
							{
								try
								{
									var responder2:DatabaseResponder = new DatabaseResponder();
									responder2.addEventListener(DatabaseEvent.RESULT_EVENT,
										function(ee:DatabaseEvent):void
										{
											state.feedId = ee.data as Number;
											state.posts = feed.items;
											insertPost(state);
											
											var o:Object = AppriseUtils.createFeedObject(feed.metadata.title,null,null,null,feedUrl,null,-1,null,null,true,null,false,-1,false);
											o.feedId = state.feedId;
											o.id = state.feedId;
											o.unread = feed.items.length;
											ModelLocator.getInstance().feeds.addItem(o);
											new RefreshCountsEvent().dispatch();
										});
									ModelLocator.getInstance().db.insertFeed(responder2, feedUrl, feed);
								}
								catch (e:Error)
								{
									// Nothing we can do at this point.  Silently skip it.
									trace("ERROR INSERTING FEED.", e.message, feedUrl);
								}
							}
							else // Existing feed.
							{
								try
								{
									var responder3:DatabaseResponder = new DatabaseResponder();
									responder3.addEventListener(DatabaseEvent.RESULT_EVENT,
										function(ee:DatabaseEvent):void
										{
											state.feedId = feedId;
											state.posts = feed.items;
											insertPost(state);
											new RefreshCountsEvent().dispatch();
										});
									ModelLocator.getInstance().db.updateFeed(responder3, feedId, feedUrl, feed);
									
									//this item is parsable, and it's possible that it wasn't before. We need to update the tree data structure, then.
									var goodFeed:Object = AppriseUtils.getFeedById(ModelLocator.getInstance().feeds,feedId);
									goodFeed.parsable = true;					
								}
								catch (e:Error)
								{
									// Nothing we can do at this point.  Silently skip it.
									trace("ERROR UPDATING FEED.", e.message, feedUrl);
								}
							}
						});
					ModelLocator.getInstance().db.getFeedIdByFeedUrl(responder, feedUrl);
				});

			ModelLocator.getInstance().statusMessage = ResourceManager.getInstance().getString('resources', 'AGGREGATECOMMAND_AGGREGATING_STATUS').replace("$1", feedUrl);
			aggregator.getFeed(aggregatorResponder, feedUrl);
		}

		private function refreshCounts(state:Object):void 
		{
			var ml:ModelLocator = ModelLocator.getInstance();
			var feeds:ArrayCollection = ml.feeds;
			var totals:ArrayCollection = ml.totals;

			this.aggregate(state);		
		}
		
		private function insertPost(state:Object):void
		{
			var posts:Array = state.posts;
			if (posts == null || posts.length == 0)
			{
				this.refreshCounts(state);
				return;
			}
			var post:IItem = state.posts.shift() as IItem;
			if (post.title == null || post.link == null || (post.excerpt == null && post.content == null))
			{
				insertPost(state);
				return;
			}
			var responder:DatabaseResponder = new DatabaseResponder();
			responder.addEventListener(DatabaseEvent.RESULT_EVENT,
				function(e:DatabaseEvent):void
				{
					var existingPost:Object = e.data;
					if (existingPost == null)
					{
						var responder2:DatabaseResponder = new DatabaseResponder();
						responder2.addEventListener(DatabaseEvent.RESULT_EVENT,
							function(e:DatabaseEvent):void
							{
								state.post = post;
								state.postId = e.data as Number;
								state.authors = post.authors;
								insertAuthors(state);
								state.newPostCount += 1; //reset after every feed
								state.totalNewPosts += 1; //entire aggregation 
								var thisFeed:Object = AppriseUtils.getFeedById(ModelLocator.getInstance().feeds, state.feedId);
								if ( thisFeed )
								{
									thisFeed.highlight = 1; 
								}								
							});
						ModelLocator.getInstance().db.insertPost(responder2, state.feedId, post);
					}
					else
					{						
						insertPost(state);											
					}
				});
			//Use <guid>, if available
			if ( post.id != null ) 
			{
				ModelLocator.getInstance().db.getPostByGuid(responder, post.id);
			}
			else 
			{
				ModelLocator.getInstance().db.getPostByTitle(responder, post.title);
			}
		}
					
		private function insertAuthors(state:Object):void
		{
			if (state.authors == null || state.authors.length == 0)
			{
				state.topics = state.post.topics;
				insertTopics(state);
				return;
			}

			var author:Author = state.authors.shift() as Author;
			if (author.name == null)
			{
				insertAuthors(state);
				return;
			}

			var responder:DatabaseResponder = new DatabaseResponder();
			responder.addEventListener(DatabaseEvent.RESULT_EVENT,
				function(e:DatabaseEvent):void
				{
					insertAuthors(state);
				});
			ModelLocator.getInstance().db.insertAuthor(responder, state.postId, author.name);
		}
		
		private function insertTopics(state:Object):void
		{
			if (state.topics == null || state.topics.length == 0)
			{
				insertPost(state);
				return;
			}

			var topic:String = state.topics.shift();
			if (topic == null)
			{
				insertTopics(state);
				return;
			}

			var responder:DatabaseResponder = new DatabaseResponder();
			responder.addEventListener(DatabaseEvent.RESULT_EVENT,
				function(e:DatabaseEvent):void
				{
					insertTopics(state);
				});
			ModelLocator.getInstance().db.insertTopic(responder, state.postId, topic);
		}
		
		private function handleFeedError(state:Object):void
		{
			var responder:DatabaseResponder = new DatabaseResponder();
			responder.addEventListener(DatabaseEvent.RESULT_EVENT,
				function(e:DatabaseEvent):void
				{
					var feedId:Number = e.data as Number;
					state.feedId = feedId;
					if (feedId == -1) // New broken feed.
					{
						insertBadFeed(state);
					}
					else  // Existing broken feed.
					{						
						updateBadFeed(state);
						var badFeed:Object = AppriseUtils.getFeedById(ModelLocator.getInstance().feeds,feedId);
						badFeed.parsable = false;						
					}
				});
			ModelLocator.getInstance().db.getFeedIdByFeedUrl(responder, state.feedUrl);
		}
		
		private function insertBadFeed(state:Object):void
		{
			var responder:DatabaseResponder = new DatabaseResponder();
			responder.addEventListener(DatabaseEvent.RESULT_EVENT,
				function(e:DatabaseEvent):void
				{
					aggregate(state);
				});
			ModelLocator.getInstance().db.insertBadFeed(responder, state.feedUrl, state.errorMessage);
		}

		private function updateBadFeed(state:Object):void
		{		
			var responder:DatabaseResponder = new DatabaseResponder();
			responder.addEventListener(DatabaseEvent.RESULT_EVENT,
				function(e:DatabaseEvent):void
				{
					aggregate(state);
				});
			ModelLocator.getInstance().db.updateBadFeed(responder, state.feedId, state.errorMessage);
		}
	}
}
