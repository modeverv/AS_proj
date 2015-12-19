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

package com.adobe.apprise.aggregator
{
	import com.adobe.xml.syndication.generic.*;
	
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;

	public class Aggregator
	{
		public function getFeed(responder:AggregatorResponder, url:String):void
		{
			var req:URLRequest = getURLRequest(url);						
			var stream:URLStream = getURLStream(responder);
			stream.addEventListener(Event.COMPLETE,
				function():void
				{
					var feedXml:XML;
					try
					{
						var xmlBytes:ByteArray = getDataFromStream(stream);
						feedXml = new XML(xmlBytes);
					}								
					catch (xmlError:Error)
					{
						var xmlErrorEvent:AggregatorEvent = new AggregatorEvent(AggregatorEvent.ERROR_EVENT);
						xmlErrorEvent.data = xmlError.message;
						responder.dispatchEvent(xmlErrorEvent);
						return;						
					}
					var feed:IFeed;
					try
					{
						feed = FeedFactory.getFeedByXML(feedXml);
					}
					catch (feedError:Error)
					{
						var feedErrorEvent:AggregatorEvent = new AggregatorEvent(AggregatorEvent.ERROR_EVENT);
						feedErrorEvent.data = feedError.message;
						responder.dispatchEvent(feedErrorEvent);
						return;						
					}
					var ae:AggregatorEvent = new AggregatorEvent(AggregatorEvent.FEED_EVENT);
					ae.data = feed;
					responder.dispatchEvent(ae);
				});
			stream.load(req);
		}
		
		// Private functions //
		
		private function getURLRequest(url:String):URLRequest
		{
			var req:URLRequest = new URLRequest(url);
			return req;
		}

		private function getURLStream(responder:AggregatorResponder):URLStream
		{
			var stream:URLStream = new URLStream();
			stream.addEventListener(IOErrorEvent.IO_ERROR,
				function(e:IOErrorEvent):void
				{
					responder.dispatchEvent(e);
				});
			stream.addEventListener(ProgressEvent.PROGRESS,
				function(e:ProgressEvent):void
				{
					responder.dispatchEvent(e);
				});
			stream.addEventListener(Event.COMPLETE,
				function(e:Event):void
				{
					responder.dispatchEvent(e);
				});
			stream.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS,
				function(e:HTTPStatusEvent):void
				{
					responder.dispatchEvent(e);
				});
			return stream;
		}

		private function getDataFromStream(stream:URLStream):ByteArray
		{
			var bytes:ByteArray = new ByteArray();
			stream.readBytes(bytes);
			return bytes;
		}
	}
}