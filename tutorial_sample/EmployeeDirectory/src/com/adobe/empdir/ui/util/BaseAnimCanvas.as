package com.adobe.empdir.ui.util
{
	import com.adobe.empdir.util.LogUtil;
	
	import mx.containers.Canvas;
	import mx.effects.Fade;
	import mx.events.EffectEvent;
	import mx.logging.ILogger;
	

	/**
	 * A simple extension that supports the close button and border that we have on all of our panels.
	 */ 
	public class BaseAnimCanvas extends Canvas
	{
		[Bindable]
		protected var hideEffect : Fade;
		
		[Bindable]
		protected var showEffect : Fade;

		private var logger : ILogger;
		
		private var _showAnimTime : int;
		private var _hideAnimTime : int;
		
		/**
		 * Constructor
		 */ 
		public function BaseAnimCanvas() 
		{
			hideEffect = new Fade();
			hideEffect.alphaTo = 0;
			hideEffect.duration = 300;
			
			showEffect = new Fade();
			showEffect.alphaTo = 1;
			showEffect.duration = 500;
			
			setStyle( "showEffect", showEffect );
			setStyle( "hideEffect", hideEffect );
			setStyle( "creationCompleteEffect", showEffect );
			addEventListener( EffectEvent.EFFECT_END, onEffectEnd );
			
			logger = LogUtil.getLogger( this );
			visible = false;
		}
		
		
		/**
		 * Hide the panel; fading the 
		 */ 
		public function hidePanel() : void
		{
			logDebug("hidePanel(): " + visible);
			if ( ! visible )
			{
				onHidePanel();
			}
			else
			{
				visible = false;
			}
		}
		
		public function showPanel() : void
		{
			logDebug("showPanel(): " + visible);
			if ( visible )
			{
				callLater( onShowPanel );
			}
			else
			{
				visible = true;
			}
		}
		
		
		/**
		 * Get the animation time for the show effect in milliseconds. 
		 */ 
		protected function get showAnimTime() : int
		{
			return showEffect.duration;
		}
		
		/**
		 * Set the animation time for the show effect in milliseconds. 
		 */ 
		protected function set showAnimTime( num:int ) : void
		{
			showEffect.duration = num;
		}
		
		/**
		 * Get the animation time for the hide effect in milliseconds. 
		 */ 
		protected function get hideAnimTime() : int
		{
			return hideEffect.duration;
		}
		
		/**
		 * Set the animation time for the hide effect in milliseconds
		 */ 
		protected function set hideAnimTime( num:int ) : void
		{
			hideEffect.duration = num;
		}
		
		
		/**
		 * Invoked when the panel has completely been hidden. 
		 */ 
		protected function onHidePanel() : void
		{	
		}
		
		
		/**
		 * Invoked when the panel has completely been shown.
		 */ 
		protected function onShowPanel() : void
		{
		}
		
		
		private function onFadeOut( evt:EffectEvent ) : void
		{
			onHidePanel();
		}
		

		
		private function onEffectEnd( evt:EffectEvent ) : void
		{	

			if ( evt.effectInstance.effect == showEffect )
			{
				//logDebug("onShowEffectEnd()");
				callLater( onShowPanel );
			}	
			else if ( evt.effectInstance.effect == hideEffect )
			{
				//logDebug("onHideEffectEnd()");
				callLater( onHidePanel );	
			}
		}
		
		
		protected function logDebug( msg:String ) : void
		{
			logger.debug( ": " + msg );
		}
		
		protected function logError( msg:String ) : void
		{
			logger.error( ": " + msg );
		}
		
	}
}