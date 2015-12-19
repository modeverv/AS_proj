package com.salesbuilder.phone
{
	import com.ribbit.api.RibbitServices;
	import com.ribbit.api.events.AuthenticationEvent;
	import com.ribbit.api.events.CallEvent;
	import com.ribbit.api.events.FaultEvent;
	import com.ribbit.api.interfaces.ICallObject;
	import com.ribbit.api.objects.CallState;
	import com.salesbuilder.dao.ContactDAO;
	import com.salesbuilder.dao.IContactDAO;
	import com.salesbuilder.model.Contact;
	
	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	import mx.controls.Alert;

	
	[Bindable]
	public class PhoneService extends EventDispatcher
	{
		public var contactDAO:IContactDAO = new ContactDAO();

		[Embed(source="/assets/RingToneMarimba.mp3")]
		private var RingToneClass:Class;

		public static const TYPE_INCOMING:String = "Incoming"
		public static const TYPE_OUTGOING:String = "Outgoing"
		public static const TYPE_IDLE:String = "Idle"

		private var _type:String;

		[Bindable(event="typeChanged")]
		public function get type():String
		{
			return _type;
		}

		[Bindable(event="stateChanged")]
		public function get state():String
		{
			return "" + ribbit.callManager.currentState;
		}

		private	var dialog:PhoneDialog = new PhoneDialog();

		private var ringtoneSound:Sound;
		private var ringtoneChannel:SoundChannel = new SoundChannel();

		public var call:ICallObject;
		
		public var loggedIn:Boolean = false;
			
		private var ribbit:RibbitServices = new RibbitServices();
			
		public function PhoneService()
		{
			ringtoneSound = new RingToneClass();
			ribbit.authenticationManager.addEventListener(AuthenticationEvent.LOGGED_IN, loggedInHandler);
			ribbit.authenticationManager.addEventListener(AuthenticationEvent.LOGGED_OUT, loggedOutHandler);
			ribbit.authenticationManager.addEventListener(AuthenticationEvent.ERROR, loginErrorHandler);
			ribbit.addEventListener(FaultEvent.STATUS, faultHandler);
			ribbit.callManager.addEventListener(CallEvent.CONNECTED, connectedHandler);
			ribbit.callManager.addEventListener(CallEvent.DISCONNECTED, disconnectedHandler);
			ribbit.callManager.addEventListener(CallEvent.CALL_STATE_CHANGE, callStateChangeHandler);
			dialog.service = this;
		}

		private function loggedInHandler(event:AuthenticationEvent):void
		{
			loggedIn = true;
		}

		private function loggedOutHandler(event:AuthenticationEvent):void
		{
			loggedIn = false;
		}

		private function faultHandler(event:AuthenticationEvent):void
		{
			Alert.show(event.fault.faultMessage + " \n" + event.fault.faultDetailMessage);
		}

		private function loginErrorHandler(event:AuthenticationEvent):void
		{
			Alert.show("Error");
			loggedIn = false;
			Alert.show(event.fault.faultMessage + " \n" + event.fault.faultDetailMessage);
		}

		private function connectedHandler(event:CallEvent):void
		{
			trace("connectedHandler " + event.newState);
			call = event.getValue("callObject");
			dispatchEvent(new Event("stateChanged")); 
			switch (event.newState)
			{
				case CallState.INCOMING:
					_type = TYPE_INCOMING;
					dispatchEvent(new Event("typeChanged")); 
					if (ringtoneChannel.position==0)
					{
						var soundTransform:SoundTransform = new SoundTransform(0.5);
						ringtoneChannel = ringtoneSound.play(0, 5, soundTransform);	
					}							
					dialog.phoneNumber = call.callerId; 
					var contact:Contact = contactDAO.findByPhoneNumber(call.callerId);
					if (contact)
					{
						dialog.contact = contact;
					}
					dialog.notes = "";
					dialog.open();
					dialog.activate();
					break;

				case CallState.RINGING:
					dialog.currentState = _type==TYPE_INCOMING ? "incoming_ringing" : "outgoing_ringing";
					break;
			}
		}
			
		private function disconnectedHandler(event:CallEvent):void
		{
			call = null;
		}
			
		private function callStateChangeHandler(event:CallEvent):void
		{
			trace("callStateChangeHandler " + event.newState);
			dispatchEvent(new Event("stateChanged")); 
			switch(event.newState)
			{
				case CallState.RINGING:
					dialog.currentState = _type==TYPE_INCOMING ? "incoming_ringing" : "outgoing_ringing";
					break;

				case CallState.ANSWERED:
				{
                	break;
				}
				case CallState.ACTIVE:
				{
					dialog.currentState = "active";
					break;
				}
				case CallState.HUNGUP:
				{
					dialog.currentState = "";
					if (ringtoneChannel)
					{
						ringtoneChannel.stop();
					}			
					dialog.close();
                	break;
				}

			}
		}

		public function login(userName:String, password:String):void
		{
			ribbit.login(userName, password, "", "", null);				
		}

		public function logout():void
		{
			ribbit.logout();				
		}

		public function makeCall(contact:Contact, phoneNumber:String):void
		{
			dialog.notes = "";
			_type = TYPE_OUTGOING;
			dispatchEvent(new Event("typeChanged")); 
			dialog.service = this;
			dialog.phoneNumber = phoneNumber;
			dialog.contact = contact;
			dialog.open();
			dialog.activate();
			ribbit.callManager.dial(phoneNumber);				
		}
			
		public function hangup():void
		{
			ribbit.callManager.hangup();
		}
			
		public function answer():void
		{
			ribbit.callManager.answer(call);
			if (ringtoneChannel) 
			{
				ringtoneChannel.stop();
			}				
		}

		public function ignore():void
		{
			ribbit.callManager.ignore(call);
			if (ringtoneChannel)
			{
				ringtoneChannel.stop();
			}	
			dialog.close();				
		}

		public function changeVolume(value:Number):void
		{
			if (call)
			{
				call.callVolume = value;
			}
		}

		public function muteCall():void
		{
			if (call && call.callState == CallState.ACTIVE)
			{
				call.muted = !call.muted;
			}
		}
			
	}
}