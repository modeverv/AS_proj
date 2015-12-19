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

package com.adobe.apprise.database
{
	
	import com.adobe.apprise.model.ModelLocator;
	import com.adobe.xml.syndication.generic.IFeed;
	import com.adobe.xml.syndication.generic.IItem;
	
	import flash.data.*;
	import flash.errors.SQLError;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.*;

	public class Database
	{
		private var sql:XML;
		private var dbFile:File;
		public var conn:SQLConnection;
		public var aConn:SQLConnection;
				
		public function Database(sql:XML)
		{
			this.sql = sql;
		}
		
		public function initialize(responder:DatabaseResponder):void
		{
			this.dbFile = File.applicationStorageDirectory.resolvePath("apprise_1-0.db");	
			this.aConn = new SQLConnection();
			this.aConn.addEventListener(SQLEvent.OPEN,
				function(e:SQLEvent):void
				{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					responder.dispatchEvent(dbe);
				});
				
			this.aConn.addEventListener(SQLErrorEvent.ERROR,
				function(sqle:SQLErrorEvent):void
				{
					trace("aConn SQLErrorEvent: ", sqle.error);
				});
				
			this.aConn.openAsync(dbFile, SQLMode.CREATE);
		}
		
		public function initSynchronousConnection():void
		{
			this.conn = new SQLConnection();
			this.conn.open(this.dbFile, SQLMode.CREATE);
		}		
		
		public function shutdown():void
		{
			if (this.aConn.inTransaction)
			{
				this.aConn.rollback();
			}
			if (this.aConn.connected)
			{
				// Let the runtime close the connection
				//this.aConn.close();
			}

			if (this.conn.inTransaction)
			{
				this.conn.rollback();
			}
			if (this.conn.connected)
			{
				// Let the runtime close the connection
				//this.conn.close();
			}
		}

		/* Feeds */

		public function createFeedsTable(responder:DatabaseResponder):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.feeds.create;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}

		public function insertFeed(responder:DatabaseResponder, feedUrl:String, feed:IFeed, parent:int = -1):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.feeds.insert;
            stmt.parameters[":name"] = (feed.metadata.title != null) ? feed.metadata.title : feedUrl;
            stmt.parameters[":description"] = feed.metadata.description;
            stmt.parameters[":icon"] = null;
            stmt.parameters[":feed_url"] = feedUrl;
            stmt.parameters[":site_url"] = feed.metadata.link;
            stmt.parameters[":sort_order"] = -1;
            stmt.parameters[":etag"] = null;
            stmt.parameters[":last_updated"] = new Date();
            stmt.parameters[":parsable"] = 1;
            stmt.parameters[":error_message"] = null;
            stmt.parameters[":is_folder"] = false;
            stmt.parameters[":parent"] = parent;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					dbe.data = stmt.getResult().lastInsertRowID;
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}

		public function insertFeedFromURL(responder:DatabaseResponder, feedUrl:String, feedName:String, parent:int = -1):void
		{
			if (!this.aConn.connected) return;
			var id:int = -1;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.feeds.insert;
            stmt.parameters[":name"] = feedName;
            stmt.parameters[":description"] = null;
            stmt.parameters[":icon"] = null;
            stmt.parameters[":feed_url"] = feedUrl;
            stmt.parameters[":site_url"] = null;
            stmt.parameters[":sort_order"] = -1;
            stmt.parameters[":etag"] = null;
            stmt.parameters[":last_updated"] = new Date();
            stmt.parameters[":parsable"] = 1;
            stmt.parameters[":error_message"] = null;
            stmt.parameters[":is_folder"] = false;
            stmt.parameters[":parent"] = parent;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					dbe.data = stmt.getResult().lastInsertRowID;
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}
		
		public function insertBadFeed(responder:DatabaseResponder, feedUrl:String, errorMessage:String):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.feeds.insert;
            stmt.parameters[":name"] = feedUrl;
            stmt.parameters[":description"] = null;
            stmt.parameters[":icon"] = null;
            stmt.parameters[":feed_url"] = feedUrl;
            stmt.parameters[":site_url"] = null;
            stmt.parameters[":sort_order"] = -1;
            stmt.parameters[":etag"] = null;
            stmt.parameters[":last_updated"] = new Date();
            stmt.parameters[":parsable"] = 0;
            stmt.parameters[":error_message"] = errorMessage;
            stmt.parameters[":is_folder"] = false;
            stmt.parameters[":parent"] = -1;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					dbe.data = stmt.getResult().lastInsertRowID;
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}

		public function updateFeed(responder:DatabaseResponder, feedId:Number, feedUrl:String, feed:IFeed):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.feeds.update;
            stmt.parameters[":name"] = (feed.metadata.title != null) ? feed.metadata.title : feedUrl;
            stmt.parameters[":description"] = feed.metadata.description;
            stmt.parameters[":icon"] = null;
            stmt.parameters[":feed_url"] = feedUrl;
            stmt.parameters[":site_url"] = feed.metadata.link;            
            stmt.parameters[":etag"] = null;
            stmt.parameters[":last_updated"] = new Date();
            stmt.parameters[":parsable"] = 1;
            stmt.parameters[":error_message"] = null;
            stmt.parameters[":feed_id"] = feedId;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}

		public function updateFeedName(responder:DatabaseResponder, feedId:Number, newName:String):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.feeds.updateName;
            stmt.parameters[":name"] = newName;
            stmt.parameters[":feed_id"] = feedId;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}
		
		public function updateFeedCustomName(responder:DatabaseResponder, feedId:Number, newCustomName:String):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.feeds.updateCustomName;
            stmt.parameters[":custom_name"] = newCustomName;
            stmt.parameters[":feed_id"] = feedId;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}
		
		public function updateFeedSortOrder(responder:DatabaseResponder, feedId:Number, sortOrder:Number):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
			stmt.text = this.sql.feeds.updateSortOrder;
			stmt.parameters[":sort_order"] = sortOrder;
			stmt.parameters[":feed_id"] = feedId;
			stmt.addEventListener(SQLEvent.RESULT,
				function (e:SQLEvent):void
				{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					responder.dispatchEvent(dbe);
				});
			stmt.execute();
		}

		public function updateBadFeed(responder:DatabaseResponder, feedId:Number, errorMessage:String):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.feeds.updateError;
            stmt.parameters[":feed_id"] = feedId;
            stmt.parameters[":parsable"] = 0;
            stmt.parameters[":last_updated"] = new Date();
            stmt.parameters[":error_message"] = errorMessage;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}

		public function deleteFeedById(responder:DatabaseResponder, feedId:Number):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.feeds.deleteByFeedId;
            stmt.parameters[":feed_id"] = feedId;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}
		
		public function deleteFeedSortOrder(responder:DatabaseResponder):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.feeds.deleteFeedSortOrder;            
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}

		public function getFeedInfoById(responder:DatabaseResponder, feedId:Number):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.feeds.selectInfoById;
            stmt.parameters[":feed_id"] = feedId;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
            		var results:SQLResult = stmt.getResult();
					dbe.data = results.data[0];
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}

		public function getFeedIdByFeedUrl(responder:DatabaseResponder, feedUrl:String):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.feeds.selectIdByFeedUrl;
            stmt.parameters[":feed_url"] = feedUrl;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
            		var results:SQLResult = stmt.getResult();
					dbe.data = (results.data == null) ? -1 : results.data[0].id;
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}
		
		public function getFeeds(responder:DatabaseResponder):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.feeds.selectAll;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					dbe.data = stmt.getResult().data;
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}

		public function getFeedUrls(responder:DatabaseResponder):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.feeds.selectUrls;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					dbe.data = stmt.getResult().data;
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}

		public function getUnreadFeeds(responder:DatabaseResponder):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.feeds.selectOnlyUnread;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					dbe.data = stmt.getResult().data;
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}
		
		public function getFeedErrorMessageById(responder:DatabaseResponder, feedId:Number):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.feeds.selectErrorMessageById;
            stmt.parameters[":feed_id"] = feedId;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
            		var results:SQLResult = stmt.getResult();
					dbe.data = results.data[0].error_message;
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}

		/* Folders */
		
		public function insertFeedAsFolder(responder:DatabaseResponder, name:String, parent:Number = -1):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.feeds.insert;
            stmt.parameters[":name"] = name;
            stmt.parameters[":description"] = null;
            stmt.parameters[":icon"] = null;
            stmt.parameters[":feed_url"] = null;
            stmt.parameters[":site_url"] = null;
            stmt.parameters[":sort_order"] = -1;
            stmt.parameters[":etag"] = null;
            stmt.parameters[":last_updated"] = new Date();
            stmt.parameters[":parsable"] = 1;
            stmt.parameters[":error_message"] = null;
            stmt.parameters[":is_folder"] = true;
            stmt.parameters[":parent"] = parent;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					dbe.data = stmt.getResult().lastInsertRowID;
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}

		public function selectByParent(responder:DatabaseResponder, parent:Number):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
			stmt.text = this.sql.feeds.selectByParent;
			stmt.parameters[":parent"] = parent;
			stmt.addEventListener(SQLEvent.RESULT,
				function(e:SQLEvent):void
				{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					var results:SQLResult = stmt.getResult();
					dbe.data = (results.data == null) ? null : results.data;
					responder.dispatchEvent(dbe);
				});
			stmt.execute();
		}

		public function updateFeedParent(responder:DatabaseResponder, feedId:Number, parent:Number):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.feeds.updateParent;
            stmt.parameters[":feed_id"] = feedId;
            stmt.parameters[":parent"] = parent;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}

		public function updateFolderOpen(responder:DatabaseResponder, feedId:Number, isOpen:Boolean):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
			stmt.text = this.sql.feeds.updateFolderOpen;
			stmt.parameters[":feed_id"] = feedId;
			stmt.parameters[":is_open"] = isOpen;
			stmt.addEventListener(SQLEvent.RESULT,
				function(e:SQLEvent):void
				{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					responder.dispatchEvent(dbe);
				});
			stmt.execute();
		}

		/* Smart folders */
		
		public function createSmartFoldersTable(responder:DatabaseResponder):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.smartFolders.create;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}

		public function insertSmartFolder(responder:DatabaseResponder, name:String, smartFolderTerms:Array, notifyOnUpdate:Boolean = false):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.smartFolders.insert;
            stmt.parameters[":name"] = name;
            stmt.parameters[":smart_folder_terms"] = smartFolderTerms.toString(); //comma delimited
            stmt.parameters[":notify_on_update"] = notifyOnUpdate;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					dbe.data = stmt.getResult().lastInsertRowID;
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}
		
		public function updateSmartFolderById(responder:DatabaseResponder, id:Number, name:String, smartFolderTerms:Array, notifyOnUpdate:Boolean = false):void
		{
			if (!this.aConn.connected) return;
			if (!smartFolderTerms || smartFolderTerms.length == 0) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.smartFolders.update;
            stmt.parameters[":id"] = id;
            stmt.parameters[":name"] = name;            
            stmt.parameters[":smart_folder_terms"] = smartFolderTerms.toString();
            stmt.parameters[":notify_on_update"] = notifyOnUpdate;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{            		
            		var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
            		responder.dispatchEvent(dbe);										
            	});
            stmt.execute();			
		}
		
		public function updateSmartFolderNotifyOnUpdateById(responder:DatabaseResponder, id:Number, notifyOnUpdate:Boolean):void
		{
			if (!this.aConn.connected) return;			
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.smartFolders.updateNotifyOnUpdate;
            stmt.parameters[":id"] = id;            
            stmt.parameters[":notify_on_update"] = notifyOnUpdate;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{            		
            		var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
            		responder.dispatchEvent(dbe);										
            	});
            stmt.execute();
		}
		
		public function getSmartFolderNotifyOnUpdateById(responder:DatabaseResponder, id:Number):void
		{
			if (!this.aConn.connected) return;			
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.smartFolders.selectNotifyOnUpdate;
            stmt.parameters[":id"] = id;                        
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{            		
            		var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);            		
            		dbe.data = stmt.getResult().data[0].notify_on_update;
            		responder.dispatchEvent(dbe);										
            	});
            stmt.execute();
		}
		
		public function getSmartFolderTermsFromId(responder:DatabaseResponder, id:Number):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.smartFolders.selectById;
            stmt.parameters[":id"] = id;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{            		
            		var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);            		
            		dbe.data = stmt.getResult().data[0].smart_folder_terms;            		
            		responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}
		
		public function getSmartFolderUnread(responder:DatabaseResponder, sqlQuery:String):void
		{
			if (!this.aConn.connected) return;
			if (!sqlQuery || sqlQuery == "") return;
			
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;                        		
            stmt.text = sqlQuery;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
            		var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
            		dbe.data = stmt.getResult().data[0].count;
            		responder.dispatchEvent(dbe);
            	});   			
            stmt.execute();
		}
		
		public function getSmartFolders(responder:DatabaseResponder):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.smartFolders.selectAll;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					dbe.data = stmt.getResult().data;
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}
		
		public function deleteSmartFolderById(responder:DatabaseResponder, smartFolderId:Number):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.smartFolders.deleteBySmartFolderId;
            stmt.parameters[":smart_folder_id"] = smartFolderId;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}

		/* Posts */

		public function createPostsTable(responder:DatabaseResponder):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.posts.create;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}

		public function getPostByUrl(responder:DatabaseResponder, postUrl:String):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.posts.selectByUrl;
            stmt.parameters[":post_url"] = postUrl;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
            		var results:SQLResult = stmt.getResult();
					dbe.data = (results.data == null) ? null : results.data[0];
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}
		
		public function getPostByTitle(responder:DatabaseResponder, postTitle:String):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.posts.selectByTitle;
            stmt.parameters[":post_title"] = postTitle;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
            		var results:SQLResult = stmt.getResult();
					dbe.data = (results.data == null) ? null : results.data[0];
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}

		public function getPostByGuid(responder:DatabaseResponder, id:String):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
			stmt.text = this.sql.posts.selectByGuid;
			stmt.parameters[":guid"] = id;
			stmt.addEventListener(SQLEvent.RESULT,
				function(e:SQLEvent):void
				{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					var results:SQLResult = stmt.getResult();
					dbe.data = (results.data == null) ? null : results.data[0];
					responder.dispatchEvent(dbe); 
				});
			stmt.execute();
		}

		public function insertPost(responder:DatabaseResponder, feedId:Number, item:IItem):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
    		stmt.text = this.sql.posts.insert;
    		stmt.parameters[":guid"] = item.id;
			stmt.parameters[":feed_id"] = feedId;
            stmt.parameters[":title"] = (item.title != null) ? item.title : "(No title)";
            if (item.content != null)
            {
	            stmt.parameters[":content"] = item.content;
            }
            else
            {
	            stmt.parameters[":content"] = item.excerpt.value;
            }
            stmt.parameters[":url"] = item.link;
            var postDate:Date;
            try
            {
            	postDate = item.date;
            }
            catch (e:Error)
            {
            	// TBD: The feed is invalid.  Default to today's date.
            	postDate = new Date();
            }
            stmt.parameters[":post_date"] = (postDate != null) ? postDate : new Date();
            stmt.parameters[":read"] = 0;
            stmt.parameters[":checked"] = 0;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					dbe.data = stmt.getResult().lastInsertRowID;
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}

		public function updatePost(responder:DatabaseResponder, oldItem:Object, item:IItem):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
    		stmt.text = this.sql.posts.update;
            stmt.parameters[":title"] = (item.title != null) ? item.title : "(No title)";
            if (item.content != null)
            {
	            stmt.parameters[":content"] = item.content;
            }
            else
            {
	            stmt.parameters[":content"] = item.excerpt.value;
            }           
            stmt.parameters[":url"] = item.link;
            stmt.parameters[":post_date"] = oldItem.post_date;
            stmt.parameters[":read"] = oldItem.read;
            stmt.parameters[":checked"] = oldItem.checked;
            stmt.parameters[":post_id"] = oldItem.id;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}
		
		public function searchPosts(responder:DatabaseResponder, searchString:String, executeInASync:Boolean = false):void
		{
			if (!this.conn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = (executeInASync) ? this.aConn : this.conn;
            stmt.text = "SELECT posts.id, feed_id, feeds.name AS feed_name, title, posts.url, post_date, read," + 
            		" checked FROM posts, feeds WHERE " + searchString + " AND posts.feed_id = feeds.id ORDER BY posts.post_date DESC LIMIT " + ModelLocator.getInstance().MAX_SEARCH_RESULTS + ";";
			
			if ( executeInASync )
			{
				stmt.addEventListener(SQLEvent.RESULT,
					function(e:SQLEvent):void
					{
						var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
						dbe.data = stmt.getResult().data;
						responder.dispatchEvent(dbe);
					});
				stmt.execute();
			}			
			else
			{
				try 
				{
	            	stmt.execute();
	            	var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					dbe.data = stmt.getResult().data;
					responder.dispatchEvent(dbe);
	   			}
	   			catch (sqle:SQLError)
	   			{
	   				//lock problem. not a big problem
	   				trace (sqle.errorID);
	   			}
	  		}   			           
		}

		public function getUnreadPosts(responder:DatabaseResponder):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.posts.selectUnread;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					dbe.data = stmt.getResult().data;
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}

		public function getCheckedPosts(responder:DatabaseResponder):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.posts.selectChecked;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					dbe.data = stmt.getResult().data;
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}

		public function getPostsByFeedId(responder:DatabaseResponder, feedId:Number):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.posts.selectByFeed;
            stmt.parameters[":feed_id"] = feedId;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					dbe.data = stmt.getResult().data;
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}

		public function getPostsByAuthor(responder:DatabaseResponder, author:String):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.posts.selectByAuthor;
            stmt.parameters[":author"] = author;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					dbe.data = stmt.getResult().data;
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}

		public function getPostsByTopic(responder:DatabaseResponder, topic:String):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.posts.selectByTopic;
            stmt.parameters[":topic"] = topic;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					dbe.data = stmt.getResult().data;
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}

		public function updatePostReadFlag(responder:DatabaseResponder, postId:Number, read:Boolean):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
    		stmt.text = this.sql.posts.updateRead;
            stmt.parameters[":post_id"] = postId;
            stmt.parameters[":read"] = read;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}

		public function updatePostCheckedFlag(responder:DatabaseResponder, postId:Number, checked:Boolean):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
    		stmt.text = this.sql.posts.updateChecked;
            stmt.parameters[":post_id"] = postId;
            stmt.parameters[":checked"] = checked;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}

		public function getPostContentById(responder:DatabaseResponder, postId:Number):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
			stmt.addEventListener(SQLEvent.RESULT,
				function(e:SQLEvent):void
				{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					var data:Array = stmt.getResult().data;
					dbe.data = (data == null || data.length == 0) ? null : data[0].content;
					responder.dispatchEvent(dbe);
				});
			stmt.text = sql.posts.selectContentById;
            stmt.parameters[":post_id"] = postId;
			stmt.execute();
		}

		public function deletePostsByFeedId(responder:DatabaseResponder, feedId:Number):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.posts.deleteByFeedId;
            stmt.parameters[":feed_id"] = feedId;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}

		public function deletePostsOlderThan(responder:DatabaseResponder, targetDate:Date):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.posts.deleteOlderThan;
            stmt.parameters[":older_than_date"] = targetDate;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}

		public function deletePostsLessThanPostId(responder:DatabaseResponder, postId:Number):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.posts.deleteLessThanPostId;
            stmt.parameters[":post_id"] = postId;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					responder.dispatchEvent(dbe);
            	});
			stmt.execute();
		}

		/* Authors */

		public function createAuthorsTable(responder:DatabaseResponder):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.authors.create;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}
		
		public function deleteAuthorsByPostId(responder:DatabaseResponder, postId:Number):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.authors.deleteByPostId;
            stmt.parameters[":post_id"] = postId;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					responder.dispatchEvent(dbe);
            	});
			stmt.execute();
		}

		public function deleteAuthorsByFeedId(responder:DatabaseResponder, feedId:Number):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.authors.deleteByFeedId;
            stmt.parameters[":feed_id"] = feedId;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}

		public function insertAuthor(responder:DatabaseResponder, postId:Number, author:String):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.authors.insert;
            stmt.parameters[":post_id"] = postId;
            stmt.parameters[":author"] = author;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					dbe.data = stmt.getResult().lastInsertRowID;
					responder.dispatchEvent(dbe);
            	});
			stmt.execute();
		}

		public function getAuthors(responder:DatabaseResponder):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.authors.selectDistinct;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					dbe.data = stmt.getResult().data;
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}

		public function getUnreadAuthors(responder:DatabaseResponder):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.authors.selectOnlyUnread;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					dbe.data = stmt.getResult().data;
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}

		public function deleteAuthorsOlderThan(responder:DatabaseResponder, targetDate:Date):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.authors.deleteOlderThan;
            stmt.parameters[":older_than_date"] = targetDate;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}
		
		public function deleteAuthorsLessThanPostId(responder:DatabaseResponder, postId:Number):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.authors.deleteLessThanPostId;
            stmt.parameters[":post_id"] = postId;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					responder.dispatchEvent(dbe);
            	});
			stmt.execute();
		}
		
		/* Topics */

		public function createTopicsTable(responder:DatabaseResponder):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.topics.create;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}

		public function deleteTopicsByPostId(responder:DatabaseResponder, postId:Number):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.topics.deleteByPostId;
            stmt.parameters[":post_id"] = postId;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					responder.dispatchEvent(dbe);
            	});
			stmt.execute();
		}
		
		public function deleteTopicsLessThanPostId(responder:DatabaseResponder, postId:Number):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.topics.deleteLessThanPostId;
            stmt.parameters[":post_id"] = postId;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					responder.dispatchEvent(dbe);
            	});
			stmt.execute();
		}

		public function deleteTopicsByFeedId(responder:DatabaseResponder, feedId:Number):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.topics.deleteByFeedId;
            stmt.parameters[":feed_id"] = feedId;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}

		public function insertTopic(responder:DatabaseResponder, postId:Number, topic:String):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.topics.insert;
            stmt.parameters[":post_id"] = postId;
            stmt.parameters[":topic"] = topic;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					dbe.data = stmt.getResult().lastInsertRowID;
					responder.dispatchEvent(dbe);
            	});
			stmt.execute();
		}

		public function getTopics(responder:DatabaseResponder):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.topics.selectDistinct;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					dbe.data = stmt.getResult().data;
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}

		public function getUnreadTopics(responder:DatabaseResponder):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.topics.selectOnlyUnread;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					dbe.data = stmt.getResult().data;
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}

		public function deleteTopicsOlderThan(responder:DatabaseResponder, targetDate:Date):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.topics.deleteOlderThan;
            stmt.parameters[":older_than_date"] = targetDate;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}
		
		/* Counts */

		public function getUnreadCount(responder:DatabaseResponder):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.posts.countUnread;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
            		var count:Number = stmt.getResult().data[0].unread as Number;
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					dbe.data = count;
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}

		public function getCheckedCount(responder:DatabaseResponder):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.posts.countChecked;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
            		var count:Number = stmt.getResult().data[0].checked as Number;
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					dbe.data = count;
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}
		
		/* Pruning */
		
		public function getPrunePostId(responder:DatabaseResponder):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.posts.selectPrunePostId;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
            		var result:Object = stmt.getResult();
            		var firstInvalidPostId:int = (result.data) ? result.data[0].id as int : -1;            	
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					dbe.data = firstInvalidPostId;
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}
		
		private function getStatement():SQLStatement
		{
			var stmt:SQLStatement = new SQLStatement();
			stmt.addEventListener(SQLErrorEvent.ERROR,
				function(e:SQLErrorEvent):void
				{
					trace("getStatement SQLError event: ", e);
				});
			return stmt;
		}
	}
}