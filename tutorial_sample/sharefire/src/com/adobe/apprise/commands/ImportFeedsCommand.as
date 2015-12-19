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
	import com.adobe.air.alert.NativeAlert;
	import com.adobe.apprise.database.DatabaseEvent;
	import com.adobe.apprise.database.DatabaseResponder;
	import com.adobe.apprise.events.ImportFeedsEvent;
	import com.adobe.apprise.events.PopulateViewControlEvent;
	import com.adobe.apprise.events.RefreshAllEvent;
	import com.adobe.apprise.model.ModelLocator;
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.resources.ResourceManager;
	
	public class ImportFeedsCommand implements ICommand
	{
		private var foundFeedUrl:Boolean = false;
		public function execute(ce:CairngormEvent):void
		{
			var fs:FileStream = new FileStream();
            fs.open(ImportFeedsEvent(ce).feedFile, FileMode.READ);
            var opmlStr:String = fs.readUTFBytes(fs.bytesAvailable);
            fs.close();

			var opml:XML;
            try
            {
                opml = new XML(opmlStr);
            }
            catch (e:Error)
            {
				NativeAlert.show(ResourceManager.getInstance().getString('resources', 'IMPORTFEEDSCOMMAND_INVALID_XML_MESSAGE'),
								 ResourceManager.getInstance().getString('resources', 'IMPORTFEEDSCOMMAND_PARSE_ERROR_TITLE'),
								 NativeAlert.OK,
								 true);
                return;
            }
            
            var body:XMLList = opml.body.*;

            ModelLocator.getInstance().statusMessage = ResourceManager.getInstance().getString('resources','IMPORTFEEDSCOMMAND_STATUS_MESSAGE');

            var feedArray:Array = new Array();
            this.xmlToArray(body, feedArray);

            if (!this.foundFeedUrl)
            {
				NativeAlert.show(ResourceManager.getInstance().getString('resources', 'IMPORTFEEDSCOMMAND_INVALID_OPML_MESSAGE'),
								 ResourceManager.getInstance().getString('resources', 'IMPORTFEEDSCOMMAND_PARSE_ERROR_TITLE'),
								 NativeAlert.OK,
								 true);
                return;
            }
                      
            this.insertFeeds([-1], [feedArray]);
            
		}
		
		private function xmlToArray(xmlList:XMLList, target:Array):void
		{
			for each (var x:XML in xmlList)
			{
				var o:Object = new Object();
				if (x.@title[0] == undefined)
				{
					if (x.@text[0] == undefined) 
					{
						continue;
					}
					else
					{
						o.name = x.@text[0].toString();
					}
				}
				else
				{
					o.name = x.@title[0].toString();
				}
				target.push(o);
				if (x.children().length() > 0 || (x.children().length() == 0 && x.@xmlUrl[0] == undefined) )				
				{
					var children:Array = new Array();
					o.children = children;
					xmlToArray(x.children(), children);
				}
				else
				{
					if (x.@xmlUrl[0] != undefined)
					{
						o.feed_url = x.@xmlUrl[0].toString();
						this.foundFeedUrl = true;
					}
				}
			}
		}
		
		private function insertFeeds(parentIds:Array, args:Array):void
		{
			if (args.length == 0)
			{
				this.aggregate();
				return;
			}
			
			var feedArray:Array = args[args.length - 1];
			var feed:Object = feedArray.pop();
			var parentId:int = parentIds[parentIds.length - 1] as int;
			
			if (feedArray.length == 0)
			{
				args.pop();
				parentIds.pop();
			}
			
			if (!feed) //empty folder 
			{
				insertFeeds(parentIds, args);
				return;
			}
			
			feed.parent = parentId;
			
			if (feed.children) // Folder
			{
				var folderResponder:DatabaseResponder = new DatabaseResponder();
				folderResponder.addEventListener(DatabaseEvent.RESULT_EVENT,
					function(e:DatabaseEvent):void
					{
						var newParentId:int = e.data as int;
						args.push(feed.children);
						parentIds.push(newParentId);
						feed.id = e.data as int;
						insertFeeds(parentIds, args);
					});
				ModelLocator.getInstance().db.insertFeedAsFolder(folderResponder, feed.name, parentId);
			}
			else // Feed
			{
				var feedResponder:DatabaseResponder = new DatabaseResponder();
				feedResponder.addEventListener(DatabaseEvent.RESULT_EVENT,
					function(e:DatabaseEvent):void
					{
						feed.id = e.data as int;
						insertFeeds(parentIds, args);
					});
				ModelLocator.getInstance().db.insertFeedFromURL(feedResponder, feed.feed_url, feed.name, parentId);	
			}
		}

		private function aggregate():void
		{			
			new PopulateViewControlEvent().dispatch();
			new RefreshAllEvent().dispatch();
		}

	}
}
