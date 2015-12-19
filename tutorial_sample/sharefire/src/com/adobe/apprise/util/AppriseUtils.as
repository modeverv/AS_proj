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

package com.adobe.apprise.util
{
	import com.adobe.apprise.model.ModelLocator;
	import com.adobe.apprise.views.SendAIMWindow;
	import com.aol.api.wim.data.User;
	
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.events.Event;
	import flash.html.HTMLLoader;
	
	import mx.collections.ArrayCollection;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	public class AppriseUtils
	{
		
		public function AppriseUtils()
		{
		}

		public static function getFeedUrls(html:HTMLLoader):Array
		{
			var feedRegExp:RegExp = new RegExp("(xml|rss|atom|rdf)","i");
			var linkArray:Object = html.window.document.getElementsByTagName("link");
			var o:Object;
			var feedUrls:Array = new Array();
			for ( var i:uint = 0; i < linkArray.length; i++)
			{
				o = linkArray[i];
				if ( o["rel"].toLowerCase() == "alternate" && feedRegExp.test(o["type"]) )
				{
					feedUrls.push({"href":o["href"],"type":o["type"],"title":o["title"]});
				}
			}
			return feedUrls;
		}
		
		public static function createFeedObject(name:String, custom_name:String = null, description:String = null, icon:Object = null, feed_url:String = null, site_url:String = null, 
											sort_order:int = -1, etag:String = null, last_updated:Date = null, parsable:Boolean = true, error_message:String = null, 
											is_folder:Boolean = false, parent:int = -1, is_open:Boolean = false):Object
		{
			var feed:Object = new Object();
			//default values for a feed
			feed.name = name;
			feed.custom_name = custom_name;
			feed.description = description;
			feed.icon = icon;
			feed.feed_url = feed_url;
			feed.site_url = site_url;
			feed.sort_order = sort_order;
			feed.etag = etag;
			feed.last_updated = last_updated;
			feed.parsable = parsable;
			feed.error_message = error_message;
			feed.is_folder = is_folder;
			feed.parent = parent;
			feed.is_open = is_open;
						
			return feed;
		}
		
		public static function createSmartFolder(name:String, smart_folder_terms:Array, unread:Number = 0):Object
		{
			var smartFolder:Object = new Object();
			smartFolder.name = name;
			smartFolder.unread = unread;
			smartFolder.smart_folder_terms = smart_folder_terms;
			return smartFolder;
		}
		
		public static function getFeedById(tree:ArrayCollection, feedId:uint, returnedFeed:Object = null):Object
		{
			for each ( var o:Object in tree ) 
			{
				if ( o.id == feedId )
				{
					returnedFeed = o;
					break;					
				}
				else if ( o.children ) 
				{
					returnedFeed = getFeedById(o.children, feedId, returnedFeed);
				}
			}			
			return returnedFeed;
		}
		
		public static function getChildFeedIds(tree:ArrayCollection, returnedIds:ArrayCollection = null):ArrayCollection
		{
			for each ( var o:Object in tree )
			{
				if ( o.children )
				{
					getChildFeedIds(o.children,returnedIds);
				}
				else
				{
					if ( !returnedIds ) returnedIds = new ArrayCollection();
					returnedIds.addItem(o.id);
				}
			}
			return returnedIds;
		}
		
		public static function aimSignOn():void
		{
			var ml:ModelLocator = ModelLocator.getInstance();
			var username:String = ml.preferences.getValue("aimUsername");
			var password:String = ml.preferences.getValue("aimPassword");	
			ml.aimSession.signOn(username,password);
		}
		
		public static function getAIMBuddyMenu():NativeMenu
		{
			var aimMenu:NativeMenu = new NativeMenu();
			aimMenu.addEventListener(Event.SELECT, 
				function (e:Event):void 
				{
					var ml:ModelLocator = ModelLocator.getInstance();
					var selectedPost:Object = ml.selectedPost;
					var selectedItem:NativeMenuItem = e.target as NativeMenuItem;
					if ( ml.preferences.getValue("aimCustomMessages")  || selectedItem.data == "arbitraryBuddy")
					{
						var message:String = selectedPost.title + " " + selectedPost.url;
						var aimWindow:SendAIMWindow = new SendAIMWindow();
						aimWindow.defaultMessage = message;
						if (selectedItem.data != "arbitraryBuddy")
						{
							aimWindow.aimId = selectedItem.label;
						}
						aimWindow.open(true);
					}
					else
					{
						var message2:String = resourceManager.getString('resources','SHARE_DEFAULT_MESSAGE').replace('$1',selectedPost.feed_name).replace('$2',selectedPost.title).replace('$3', selectedPost.url);
						ml.aimSession.sendIM(selectedItem.label, message2, false, false);
					}
				});	

			var ml:ModelLocator = ModelLocator.getInstance();
			var resourceManager:IResourceManager = ResourceManager.getInstance();

			if ( ml.aimSession && ml.aimSession.sessionState != "offline" ) 
			{
				for each ( var u:User in ml.aimBuddies ) 
				{
					if ( u.state != "offline" ) 
					{
						var newBuddyItem:NativeMenuItem = new NativeMenuItem(u.aimId);
						aimMenu.addItem(newBuddyItem);
					}
				}
				var arbitraryBuddy:NativeMenuItem = new NativeMenuItem(resourceManager.getString('resources','POSTGRID_AIM_OTHER_BUDDY_MENUITEM'));
				arbitraryBuddy.data = "arbitraryBuddy";
				aimMenu.addItem(arbitraryBuddy);
			}
			return aimMenu;
		}
		
		public static function getSearchString(searchTerm:String):String
		{
			searchTerm = searchTerm.replace(new RegExp("'","g"),"''");
			searchTerm = searchTerm.replace(new RegExp(" ","g"),",");
			var searchTermArray:Array = searchTerm.split(',');
			//searchTermArray may contain any number of whitespace elements, so we use a new array to hold only terms
			var justSearchTerms:Array = new Array(); 
			
			for ( var i:uint = 0; i < searchTermArray.length; i++ )
			{
				var currentTerm:String = searchTermArray[i];
				if ( currentTerm != '' && currentTerm != ' ' )
				{
					//create a query for this term, and store it in the final search term array
					justSearchTerms[i] = "(posts.content LIKE '%" + currentTerm + "%' OR posts.title LIKE '%" + currentTerm + "%')";
				}
			}
			
			var searchString:String = "";
			for ( i = 0; i < justSearchTerms.length; i++ )
			{
				currentTerm = justSearchTerms[i];
				var nextTerm:String = justSearchTerms[i+1];
				if ( currentTerm && currentTerm != '' )
				{
					searchString += currentTerm;
				}
				//if there's another term after this, add an 'AND' between the two
				if ( nextTerm != null )
				{
					searchString += " AND ";
				}				
			}
			
			//if searchCommand has been called and there's no resulting searchString, default to a match for everything
			if ( searchString == "" )
			{
				searchString = "(posts.content LIKE '%')";
			}			
			return searchString;
		}
		
		public static function getSmartFolderTermsArrayFromString(smartFolderTerms:String):Array
		{			
			smartFolderTerms = smartFolderTerms.replace(new RegExp(" ","g"),",");
			smartFolderTerms = smartFolderTerms.replace(new RegExp("\n","g"),","); 				
			var termsArrayCollection:ArrayCollection = new ArrayCollection(smartFolderTerms.split(","));
			var validTerms:Array = new Array();
			for each ( var term:Object in termsArrayCollection )
			{		
				if ( term != "" && term != " " )
				{
					validTerms.push(term);
				}
			}
			return validTerms;
		}
		
		public static function reorderLocaleChain():void		
		{
			var ml:ModelLocator = ModelLocator.getInstance();
			if ( ml.preferences.getValue("language") )
			{			
				// take the application-specific language and put it on the top of the locale chain.		
				var newArray:Array = new Array();
				newArray.push(ml.preferences.getValue("language"));
				for each ( var localeItem:String in ResourceManager.getInstance().localeChain )
				{
					if ( localeItem != ml.preferences.getValue("language") )
					{
						newArray.push(localeItem);
					}
				}
				ResourceManager.getInstance().localeChain = newArray;
			}			
		}
		 
		
		public static function getLanguages():ArrayCollection
		{
			var l:ArrayCollection = new ArrayCollection;

			var cs:Object = new Object();
			cs.value = "cs";
			cs.label = "čeština";
			l.addItem(cs);
			
			var de:Object = new Object();
			de.value = "de";
			de.label = "Deutsch";
			l.addItem(de);
			
			var en_US:Object = new Object();
			en_US.value = "en_US";
			en_US.label = "English";
			l.addItem(en_US);
			
			var es:Object = new Object();
			es.value = "es";
			es.label = "Español";
			l.addItem(es);
			
			var fr:Object = new Object();
			fr.value = "fr";
			fr.label = "Français";
			l.addItem(fr);
			
			var it:Object = new Object();
			it.value = "it";
			it.label = "Italiano";
			l.addItem(it);
			
			var ja_JP:Object = new Object();
			ja_JP.value = "ja_JP";
			ja_JP.label = "日本語";
			l.addItem(ja_JP);
			
			var ko:Object = new Object();
			ko.value = "ko";
			ko.label = "한국어";
			l.addItem(ko);

			var nl:Object = new Object();
			nl.value = "nl";
			nl.label = "Nederlands";
			l.addItem(nl);

			var pl:Object = new Object();
			pl.value = "pl";
			pl.label = "język polski";
			l.addItem(pl);
			
			var pt:Object = new Object();
			pt.value = "pt";
			pt.label = "Português";
			l.addItem(pt);
			
			var ru:Object = new Object();
			ru.value = "ru";
			ru.label = "Pусский";
			l.addItem(ru);

			var sv:Object = new Object();
			sv.value = "sv";
			sv.label = "svenska";
			l.addItem(sv);

			var tr:Object = new Object();
			tr.value = "tr";
			tr.label = "Türkçe";
			l.addItem(tr);
			
			var zh_Hans:Object = new Object();
			zh_Hans.value = "zh_Hans";
			zh_Hans.label = "简体中文";
			l.addItem(zh_Hans);
			
			var zh_Hant:Object = new Object();
			zh_Hant.value = "zh_Hant";
			zh_Hant.label = "繁體中文";
			l.addItem(zh_Hant);
						
			return l;
		}
	}
}
