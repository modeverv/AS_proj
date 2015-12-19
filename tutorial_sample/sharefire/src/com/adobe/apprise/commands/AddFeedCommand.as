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
	import com.adobe.apprise.events.AddFeedEvent;
	import com.adobe.apprise.events.AggregateEvent;
	import com.adobe.apprise.events.BusyEvent;
	import com.adobe.apprise.model.ModelLocator;
	import com.adobe.apprise.util.AppriseUtils;
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.html.HTMLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLStream;
	import flash.utils.Timer;
	
	import mx.resources.ResourceManager;
	
	public class AddFeedCommand implements ICommand
	{
		public function execute(ce:CairngormEvent):void
		{
			var addFeedEvent:AddFeedEvent = ce as AddFeedEvent;		
			var feedUrl:String = addFeedEvent.feedUrl;			
			var stream:URLStream = new URLStream();

			stream.addEventListener(IOErrorEvent.IO_ERROR,
				function(e:IOErrorEvent):void
				{
					var errorMessage:String = ResourceManager.getInstance().getString('resources','ADDFEED_IO_ERROR').replace("$1",feedUrl);
					var errorTitle:String = ResourceManager.getInstance().getString('resources','ADDFEED_ERROR_TITLE');
					NativeAlert.show(errorMessage,errorTitle,NativeAlert.OK,true,NativeApplication.nativeApplication.activeWindow);
				});			
			
			stream.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS,
				function(e:HTTPStatusEvent):void
				{
					for each ( var tag:URLRequestHeader in e.responseHeaders )
					{
						if ( new RegExp("content.type","i").exec(tag.name) )
						{
							if ( new RegExp("text\/html","i").exec(tag.value) ) 
							{
								extractAlternateURL(feedUrl);
								break;
							}
							else if ( new RegExp("(application|text)\/(rss|xml|atom|rdf)","i").exec(tag.value) )
							{
								var aggregateEvent:AggregateEvent = new AggregateEvent();
								aggregateEvent.feeds = [feedUrl]; //dispatch with original URL
								aggregateEvent.dispatch();
								break;
							}					
						}
					}
				});

			//Feeds come in from Firefox as feed://url
			var feedFormat:RegExp = new RegExp("^feed:\/\/");
			if ( feedFormat.exec(feedUrl) )
			{
				feedUrl = feedUrl.replace(feedFormat,"http:\/\/");
			}
	
			//Feeds sometimes come in as [http|feed]://example.com/feed.xml/ , and the trailing "/" would cause a 404,
			//resulting in the error "Cannot find feed for $1." Firefox seems to do this when invoking Apprise. Safer to always trim. 
			var extraneousSlash:RegExp = new RegExp("\/$");
			if ( extraneousSlash.exec(feedUrl) )
			{
				feedUrl = feedUrl.substr(0,feedUrl.length - 1);
			}

			stream.load(new URLRequest(feedUrl));
		}
		
		private function extractAlternateURL(feedUrl:String):void
		{
			var htmlLoader:HTMLLoader = new HTMLLoader();
			
			htmlLoader.addEventListener(Event.COMPLETE,
				function(e:Event):void
				{	
					timeout.stop();

					var be:BusyEvent = new BusyEvent();
					be.busy = false;
					be.dispatch();
		
					var feedLinks:Array = AppriseUtils.getFeedUrls(htmlLoader);
					if (feedLinks.length != 0)
					{
						var aggregateEvent:AggregateEvent = new AggregateEvent();
						aggregateEvent.feeds = [feedLinks[0].href]; //dispatch with updated URL
						aggregateEvent.dispatch();		
						return;
					}
					
					var errorMessage:String = ResourceManager.getInstance().getString("resources","ADDFEED_FEED_NO_ALTERNATE").replace("$1",feedUrl);
					var errorTitle:String = ResourceManager.getInstance().getString("resources","ADDFEED_ERROR_TITLE");
					NativeAlert.show(errorMessage,errorTitle,NativeAlert.OK,true,NativeApplication.nativeApplication.activeWindow);

					//change status bar to "Done."
					ModelLocator.getInstance().statusMessage = ResourceManager.getInstance().getString("resources","POSTDISPLAY_STATUS_DONE");
				});

			htmlLoader.load(new URLRequest(feedUrl));
			
			var timeout:Timer = new Timer(50000); 
			timeout.addEventListener(TimerEvent.TIMER,
				function(e:TimerEvent):void
				{
					var busyEvent:BusyEvent = new BusyEvent();
					busyEvent.busy = false;
					busyEvent.dispatch();
					htmlLoader.cancelLoad();
					timeout.stop();
					
					//display error ("couldn't resolve url")
					var errorMessage:String = ResourceManager.getInstance().getString("resources","ADDFEED_FEED_SEARCH_FAIL").replace("$1",feedUrl);
					var errorTitle:String = ResourceManager.getInstance().getString("resources","ADDFEED_ERROR_TITLE");
					NativeAlert.show(errorMessage,errorTitle,NativeAlert.OK,true,NativeApplication.nativeApplication.activeWindow);
					
					//change status bar to "Done."
					ModelLocator.getInstance().statusMessage = ResourceManager.getInstance().getString("resources","POSTDISPLAY_STATUS_DONE");
				});
				
			timeout.start();
			
			var busyEvent:BusyEvent = new BusyEvent();
			busyEvent.busy = true;
			busyEvent.dispatch();
			ModelLocator.getInstance().statusMessage = ResourceManager.getInstance().getString("resources","ADDFEED_FEED_SEARCH").replace("$1",feedUrl);
		}
	}
}
