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
	import com.adobe.air.notification.AbstractNotification;
	import com.adobe.air.notification.Notification;
	import com.adobe.air.notification.NotificationClickedEvent;
	import com.adobe.apprise.events.NotifyEvent;
	import com.adobe.apprise.model.ModelLocator;
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.NativeWindow;
	
	import mx.resources.ResourceManager;	
			
	public class NotifyCommand implements ICommand
	{
		[Embed(source="assets/notify_icon.png")] [Bindable] public var notificationLogo:Class
		private var smartFoldersNewPosts:int;
		private var totalNewPosts:int;
		
		public function execute(ce:CairngormEvent):void
		{			
			this.smartFoldersNewPosts = NotifyEvent(ce).smartFoldersNewPosts;
			this.totalNewPosts = NotifyEvent(ce).totalNewPosts;
			var ml:ModelLocator = ModelLocator.getInstance();
			if ( ml.preferences.getValue("notifyFeedsEnabled") )
			{
				notifyFeeds();
			}
			if ( ml.preferences.getValue("notifySmartFoldersEnabled") )
			{
				notifySmartFolders();
			}
		}
		
		private function notifyFeeds():void
		{			
			var ml:ModelLocator = ModelLocator.getInstance();
			var message:String;
			if ( !this.totalNewPosts || this.totalNewPosts <= 0 )
			{
				return;
			}
			else if ( this.totalNewPosts == 1 )
			{
				message = ResourceManager.getInstance().getString('resources', 'NOTIFYCOMMAND_FEED_NOTIFICATION_MESSAGE_SINGULAR');
			}
			else
			{
				message = ResourceManager.getInstance().getString('resources', 'NOTIFYCOMMAND_FEED_NOTIFICATION_MESSAGE_PLURAL').replace("$1",this.totalNewPosts);
			}
			var title:String = ResourceManager.getInstance().getString('resources', 'NOTIFYCOMMAND_FEED_NOTIFICATION_TITLE');
			var position:String = ml.preferences.getValue("notifyWindowPosition", AbstractNotification.BOTTOM_RIGHT);										
			ml.notificationQueue.addNotification(createNotification(title, message, position, true));	
		}
			
		private function notifySmartFolders():void
		{
			var ml:ModelLocator = ModelLocator.getInstance();			
			var message:String;
			if ( !this.smartFoldersNewPosts || this.smartFoldersNewPosts <= 0 )
			{
				return;
			}
			else if ( this.smartFoldersNewPosts == 1 )
			{
				message = ResourceManager.getInstance().getString('resources', 'NOTIFYCOMMAND_SMART_FOLDER_NOTIFICATION_MESSAGE_SINGULAR');
			}
			else
			{
				message = ResourceManager.getInstance().getString('resources', 'NOTIFYCOMMAND_SMART_FOLDER_NOTIFICATION_MESSAGE_PLURAL').replace("$1",this.smartFoldersNewPosts);
			}
			var title:String = ResourceManager.getInstance().getString('resources', 'NOTIFYCOMMAND_SMART_FOLDER_NOTIFICATION_TITLE');			
			var position:String = ml.preferences.getValue("notifyWindowPosition", AbstractNotification.BOTTOM_RIGHT);										
			ml.notificationQueue.addNotification(createNotification(title, message, position, true));	
		}
		
		private function createNotification(title:String, message:String, position:String, useHTML:Boolean = false):Notification
		{			
			var notify:Notification = new Notification(title,message,position,5,new notificationLogo() as Bitmap);
			if ( useHTML )
			{								
				notify.htmlText = message;
			}
			notify.height = 70;
			notify.width = 250;
			notify.bitmap.y = (notify.height / 2 ) - (notify.bitmap.height / 2);
			notify.addEventListener(NotificationClickedEvent.NOTIFICATION_CLICKED_EVENT,
				function(e:NotificationClickedEvent):void
				{					
					var appriseWindow:NativeWindow = NativeApplication.nativeApplication.openedWindows[0]; 					
					if ( !appriseWindow.active )
					{
						appriseWindow.activate();
					}
				});
			return notify;	
		}
	}
}
