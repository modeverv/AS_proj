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
	import com.adobe.apprise.events.AIMInitEvent;
	import com.adobe.apprise.model.ModelLocator;
	import com.adobe.apprise.util.AppriseUtils;
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.aol.api.openauth.events.AuthEvent;
	import com.aol.api.wim.Session;
	import com.aol.api.wim.data.BuddyList;
	import com.aol.api.wim.data.Group;
	import com.aol.api.wim.data.User;
	import com.aol.api.wim.events.AuthChallengeEvent;
	import com.aol.api.wim.events.BuddyListEvent;
	import com.aol.api.wim.events.IMEvent;
	import com.aol.api.wim.events.SessionEvent;
	import com.aol.api.wim.events.UserEvent;
	
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.display.Stage;
	
	import mx.collections.ArrayCollection;
	import mx.resources.ResourceManager;
	
	
	public class AIMInitCommand implements ICommand
	{
		
		public function execute(ce:CairngormEvent):void
		{
			var ml:ModelLocator = ModelLocator.getInstance();
			var aimInitEvent:AIMInitEvent = ce as AIMInitEvent;
			
			if ( !ml.aimSession ) 
			{
				if ( aimInitEvent.connect ) //only create if we want to connect
				{
					var stage:Stage = NativeWindow(NativeApplication.nativeApplication.openedWindows[0]).stage;
					ml.aimSession = new Session(stage,ml.AIM_DEV_KEY,"com.adobe.apprise","2.0");
				
					ml.aimSession.addEventListener(BuddyListEvent.LIST_RECEIVED,
						function(e:BuddyListEvent):void
						{
							var bl:BuddyList = new BuddyList(e.buddyList.owner,e.buddyList.groups);
							if ( !ml.aimBuddies ) 
							{
								ml.aimBuddies = new ArrayCollection(); 
							}
				
							for each ( var g:Group in bl.groups ) 
							{
								for each ( var u:User in g.users )
								{
									ml.aimBuddies.addItem(u);									
								}
							}
						}, false, 0, false);
						
					ml.aimSession.addEventListener(UserEvent.BUDDY_PRESENCE_UPDATED,
						function(e:UserEvent):void
						{
							//something is updated about this user, and unfortunately we have to go through each one to see
							for each ( var u:User in ml.aimBuddies )
							{
								if ( u.aimId == e.user.aimId ) 
								{
									//update the user. for some reason I can't just do
									//u = e.user;
									var itemIndex:Number = ml.aimBuddies.getItemIndex(u); 
									ml.aimBuddies.removeItemAt(itemIndex);
									ml.aimBuddies.addItemAt(e.user, itemIndex);
									break;
								}									
							}
						}, false, 0, false); 
									
					ml.aimSession.addEventListener(SessionEvent.STATE_CHANGED, onStateChange, false,0,false);
					
					ml.aimSession.addEventListener(AuthEvent.CHALLENGE,
						function(e:AuthEvent):void
						{
							trace("authentication challeneged. auth event.",e);
						}, false,0,false);
						
					ml.aimSession.addEventListener(AuthChallengeEvent.AUTHENTICATION_CHALLENGED,
						function(e:AuthChallengeEvent):void
						{
							NativeAlert.show(ResourceManager.getInstance().getString('resources', 'AIMINITCOMMAND_INCORRECT_CREDENTIALS'),
											 ResourceManager.getInstance().getString('resources', 'AIMINITCOMMAND_INCORRECT_CREDENTIALS_TITLE'),
											 NativeAlert.OK, true, NativeApplication.nativeApplication.openedWindows[0]);							
						}, false,0,false);
						
					
					ml.aimSession.addEventListener(IMEvent.IM_SEND_RESULT,
						function(e:IMEvent):void
						{
							if ( e.statusCode == "200" )
							{
								ml.aimMessageSent = true;
							}

						}, false,0,false);	
					
					//for notification windows when a buddy sends you a link. (working. Just decide what to do when you click the notification window)
					/*ml.aimSession.addEventListener(IMEvent.IM_RECEIVED,
						function(e:IMEvent):void
						{
							if ( !NativeApplication.nativeApplication.activeWindow ) { return; } //if app doesn't have focus, do not pop up notifications
							if ( !ml.preferences.getValue("aimNotificationsEnabled") ) { return; } //if the user doesn't want notifications
							//if the message contains a link, display it in a notification window.
							var containedLinks:Array = new RegExp("http(s?):\/\/\S*","i").exec(e.im.message);
							if ( containedLinks != null ) 
							{
								var windowText:String = ResourceManager.getInstance().getString('resources','AIMINITCOMMAND_IM_NOTIFICATION_TITLE').replace('$1',e.im.sender.displayId);
								var n:Notification = new Notification(windowText,e.im.message,AbstractNotification.BOTTOM_RIGHT);
								n.addEventListener(NotificationClickedEvent.NOTIFICATION_CLICKED_EVENT,
									function(nce:NotificationClickedEvent):void
									{
										
									});		
							}
							if ( !ml.notificationQueue ) { ml.notificationQueue = new NotificationQueue(); }
							ml.notificationQueue.addNotification(n); 
						}, false,0,false);*/
					
				}
				else //no session, don't want to connect...no reason to call.
				{
					return;
				}
			}
			//if we are connected, and want to disconnect
			if ( isAimOnline() && !aimInitEvent.connect ) 
			{	
				ml.aimSession.signOff();
				ml.aimBuddies = null;
			}
			else if ( !isAimOnline() && aimInitEvent.connect ) 
			{
				var AIMEnabled:Boolean = ml.preferences.getValue("aimEnabled"); //aim ALSO has to be enabled to connect
				if ( AIMEnabled ) 
				{
					AppriseUtils.aimSignOn();
				}				
			}	
		}
		
		private function isAimOnline():Boolean
		{
			var returnValue:Boolean;
			var ml:ModelLocator = ModelLocator.getInstance();
			if ( ml.aimState == "online" ) 
			{
				returnValue = true;
			}
			return returnValue;
		}
				
		private function onStateChange(e:SessionEvent):void
		{
			var ml:ModelLocator = ModelLocator.getInstance();
			ml.aimState = e.session.sessionState;
		}
	}
}
