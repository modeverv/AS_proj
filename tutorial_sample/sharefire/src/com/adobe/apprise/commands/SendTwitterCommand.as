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
	import com.adobe.apprise.events.SendTwitterEvent;
	import com.adobe.apprise.model.ModelLocator;
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLStream;
	
	import mx.utils.Base64Encoder;
	import mx.resources.ResourceManager;
	
	public class SendTwitterCommand implements ICommand
	{
		
		private var twitterError:Boolean = false;
		
		public function execute(ce:CairngormEvent):void
		{
			var ml:ModelLocator = ModelLocator.getInstance();
			var sendTwitterEvent:SendTwitterEvent = ce as SendTwitterEvent;
			var message:String = sendTwitterEvent.message;
			var twitterUsername:String = ml.preferences.getValue("twitterUsername");
			var twitterPassword:String = ml.preferences.getValue("twitterPassword");
			var encoder:Base64Encoder = new Base64Encoder();
			encoder.encode(twitterUsername + ":" + twitterPassword);
			var credentials:String = "Basic " + encoder.drain();
			
			if (twitterUsername == null || twitterPassword == null) return;
			
			var req:URLRequest = new URLRequest("http://twitter.com/statuses/update.xml");
			req.method = URLRequestMethod.POST;
			req.data = ("status=" + escape(message) + "&source=ShareFire");
			req.authenticate = true;
			req.requestHeaders.push(new URLRequestHeader("Authorization", credentials));
			var stream:URLStream = new URLStream();

			stream.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS,
				function(e:HTTPStatusEvent):void
				{
					if (e.status != 200)
					{
						twitterError = true;
					}
				});

			stream.addEventListener(Event.COMPLETE,
				function(e:Event):void
				{
					ModelLocator.getInstance().statusMessage = ResourceManager.getInstance().getString('resources', 'SENDTWITTERCOMMAND_STATUS_DONE');
					var errorMessage:String = stream.readUTFBytes(stream.bytesAvailable) as String;
					if (twitterError)
					{
						NativeAlert.show(errorMessage, ResourceManager.getInstance().getString('resources', 'SENDTWITTERCOMMAND_STATUS_ERROR'), NativeAlert.OK, true, NativeApplication.nativeApplication.openedWindows[0]);
					}
				});

			ModelLocator.getInstance().statusMessage = ResourceManager.getInstance().getString('resources', 'SENDTWITTERCOMMAND_STATUS_POSTING');
			stream.load(req);
		}
	}
}
