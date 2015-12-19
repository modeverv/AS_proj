package com.adobe.empdir.managers
{
	import com.adobe.empdir.ui.ApplicationUI;
	import com.adobe.empdir.util.LogUtil;
	
	import flash.display.NativeWindow;
	import flash.display.Screen;
	import flash.events.Event;
	import flash.events.NativeWindowBoundsEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import mx.binding.utils.BindingUtils;
	import mx.effects.AnimateProperty;
	import mx.events.EffectEvent;
	import mx.logging.ILogger;
	
	/**
	 * This singleton class is responsible for managing the window bounds 
	 * (syncing it to the ApplicationUI), as well as keeping the window 
	 * onscreen.
	 */ 
	public class WindowBoundsManager
	{
		private static var instance : WindowBoundsManager
	
		private static const BASE_STATE : String = "baseState";  // this is the base state, indicating that we are awaiting a move. 
		private static const TIMER_STATE : String = "timerState"; // this is the state indicating a resize happened, and we are waiting for a timeout to move
		private static const ANIM_STATE : String = "animState"; // this is the state indicating we are animating
		private static const DISABLED_STATE : String = "disabledState"; // disabled all bounds management functionality
		
		
		private var currentState : String;
		
		private var settingsManager : SettingsManager = SettingsManager.getInstance();
		private var window : NativeWindow;
		private var ui : ApplicationUI;
		
		private var inited : Boolean;
	
		private var origPos : Point;
		private var xAnimProperty : AnimateProperty;
		private var yAnimProperty : AnimateProperty;
		private var animTimer : Timer;
		private var logger : ILogger;
	
		
		// an absolute minimum window height (that can be modified to accomodate for the dropdown)
		private var _minWinHeight : Number;
		
		/**
		 * Private constructor.
		 */ 
		public function WindowBoundsManager() 
		{
			if ( instance != null )
			{
				throw new Error( "Private constructor. Use getInstance() instead." );	
			}
			inited = false;
			
			animTimer = new Timer( 600, 1 );
			animTimer.addEventListener( TimerEvent.TIMER, onResizeTimeout );
			
			_minWinHeight = 0;	
			logger = LogUtil.getLogger( this );
			currentState = BASE_STATE;
		}
		
		/**
		 * Get an instance of the location manager.
		 */ 
		public static function getInstance() : WindowBoundsManager
		{
			if ( instance == null )
			{
				instance = new WindowBoundsManager();
			}
			return instance;
		}
		
		/**
		 * Init the manager for the given window.
		 */ 
		public function init( window:NativeWindow, ui:ApplicationUI ) : void
		{
			if ( ! inited )
			{
				logDebug("init(): " + window + " : " + ui.name);
				inited = true;
				this.window = window;
				this.ui = ui;
				
				BindingUtils.bindSetter( setWinHeight, ui.bgBox, "height", true );
				BindingUtils.bindSetter( setWinWidth, ui.bgBox, "width", true );
				
				var lastPos : Object = settingsManager.getSetting( SettingsManager.WINDOW_POSITION );				
				var maxWinSize : Point = getMaxWinSize();
				
				if ( lastPos && lastPos.x >= 0 && lastPos.y >= 0 && lastPos.x < maxWinSize.x && lastPos.y < maxWinSize.y ) 
				{
					window.x = lastPos.x;
					window.y = lastPos.y;
				}
				
				xAnimProperty = new AnimateProperty( window );
				xAnimProperty.duration = 800;
				xAnimProperty.property = "x";
				
				yAnimProperty = new AnimateProperty( window );
				yAnimProperty.duration = 800;
				yAnimProperty.property = "y";
				
				window.addEventListener( NativeWindowBoundsEvent.RESIZE, onWindowResize );
				window.addEventListener( NativeWindowBoundsEvent.MOVE, onWindowMove );
				
			}
		}
		
	
		
		/**
		 * The minimum window height. This is settable in order to accomodate the search input dropdown.
		 */ 
		public function set minWinHeight( height:Number ) : void
		{
			logDebug("minWinHeight: " + height);
			_minWinHeight = height;
			setWinHeight( ui.contentBox.height ); 
		}
		
		public function get minWinHeight() : Number
		{
			return _minWinHeight;
		}
		
		/**
		 * Disable automatic positioning of the window to keep it onscreen. 
		 * This can be used to stop interference with manually moving the window.
		 */ 
		public function disablePositionManagement() : void
		{
			animTimer.stop();
			origPos = null;
			currentState = DISABLED_STATE;
		}
		
		public function enablePositionManagement() : void
		{
			currentState = BASE_STATE;
		}
		
		/**
		 * Return true if the window is resizing; false otherwise.
		 */ 
		/*public function isResizing() : Boolean
		{
			return currentState == ANIM_STATE || currentState == TIMER_STATE;
		}*/
		
		
		private function onWindowMove( evt:NativeWindowBoundsEvent ) : void
		{
			//logDebug( "onWindowMove: : " + currentState);
			switch ( currentState ) 
			{
				case BASE_STATE:
					//logDebug( "onWindowMove: : " + currentState);
					origPos = null;
					animTimer.stop();
					currentState = BASE_STATE;
					break;
				case TIMER_STATE:
				case ANIM_STATE:
				case DISABLED_STATE:
					break;  
			}
		}

		
		private function onWindowResize( evt:NativeWindowBoundsEvent = null ) : void
		{
			//logDebug( "onWindowResize: " + currentState );
			
			switch ( currentState )
			{
				case BASE_STATE:
					//logDebug("STARTING TIMER");
					animTimer.reset();
					animTimer.start();
					currentState = TIMER_STATE;
					break;
				case TIMER_STATE:
				case ANIM_STATE:
				case DISABLED_STATE:
					// ignore, we'll check where we're at when we timeout
					break;
			} 
		}
		
		private function onResizeTimeout( evt:TimerEvent ) : void
		{
			logDebug("onResizeTimeout()");
			
			ensureWindowOnscreen();
		}
		
		
		/** Check the position of the window, ensuring that its onscreen. **/
		public function ensureWindowOnscreen() : void
		{	
			var maxPt : Point = getMaxWinSize();
			
			// first, determine the difference between our current position and the screen.
			var delta : Point = maxPt.subtract( window.bounds.bottomRight );
			
			//logDebug("delta: " + delta);
			//logDebug("origPos: " + origPos);
			
			if ( origPos == null )
			{
				origPos = window.bounds.topLeft;
			}
			var xTo : Number = Math.min( window.x + delta.x, origPos.x )
			var yTo : Number = Math.min( window.y + delta.y, origPos.y );
			
			if ( xTo != window.x || yTo != window.y )
			{
				currentState = ANIM_STATE;
				animTo( xTo, yTo );
			}
			else
			{
				currentState = BASE_STATE;	
			}
							
		}
		
		
		/**
		 * Save the window position when the application closes.
		 */ 
		public function saveWindowPosition() : void
		{
			//logDebug( "saveWindowPosition()" );
			var winPos : Point = window.bounds.topLeft;
			if ( winPos.x >= 0 && winPos.y >= 0 ) // Tricky, if its minimized it could have a negative position 
			{
				settingsManager.setSetting( SettingsManager.WINDOW_POSITION, winPos );
			}
		}
		
		
		
		private function animTo( xPos:Number, yPos:Number ) : void
		{
			//logDebug("animTo: " + xPos + "," + yPos);
			xAnimProperty.removeEventListener( EffectEvent.EFFECT_END, onMoveEffectEnd );
			yAnimProperty.removeEventListener( EffectEvent.EFFECT_END, onMoveEffectEnd );
			
			if ( xPos != window.x )
			{
				xAnimProperty.addEventListener( EffectEvent.EFFECT_END, onMoveEffectEnd );
				xAnimProperty.toValue = xPos;
				xAnimProperty.play( [ window ] );
			}
			
			if ( yPos != window.y )
			{
				yAnimProperty.addEventListener( EffectEvent.EFFECT_END, onMoveEffectEnd );
				yAnimProperty.toValue = yPos;
				yAnimProperty.play( [ window ] );
			}
			
		}
		
		private function onMoveEffectEnd( evt:Event ) : void
		{
			//logDebug( "onMoveEffectEnd()" );
			xAnimProperty.removeEventListener( EffectEvent.EFFECT_END, onMoveEffectEnd );
			yAnimProperty.removeEventListener( EffectEvent.EFFECT_END, onMoveEffectEnd );
			
			currentState = BASE_STATE;
			
			ensureWindowOnscreen();
		}
		
		/** Bindable setter for the minimum window width/ **/
		private function setWinWidth( val:Number ) : void
		{
			window.width = ui.contentBox.width + ui.contentBox.x * 2;
		}
		
		
		/** Bindable setter for the minimum window width. **/
		private function setWinHeight( val:Number ) : void
		{
			window.height = Math.max( ui.contentBox.height + 20, minWinHeight ); // this amount compensates for the dropdown, 20 pixels for the drop-shadow
		}
		
		
		
		/**
		 * Helper function to get the maximum window position, as best we can.
		 */ 
		private function getMaxWinSize() : Point
		{
			var screen : Screen = Screen.getScreensForRectangle( window.bounds )[0] as Screen;
			return screen.visibleBounds.bottomRight;
		}
		
		private function onWindowClosing( evt:Event ) : void
		{
			logDebug("onWindowClosing()");	
		}
		
		private function logDebug( msg:String ) : void
		{
			logger.debug( msg );	
		}
	}
}