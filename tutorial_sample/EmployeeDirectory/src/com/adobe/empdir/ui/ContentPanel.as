package com.adobe.empdir.ui
{
	import com.adobe.empdir.ui.util.BaseAnimCanvas;
	
	import flash.events.Event;
	
	import mx.controls.Button;
	
	/**
	 * This event is closed when the user clicks on the close button (not when the panel closes). 
	 */ 
    [Event(name="close", type="flash.events.Event")]
   

	/**
	 * This is the basic panel for a content pane. It provides simple show/hide functionality, 
	 * and also includes a close button.
	 */ 
	public class ContentPanel extends BaseAnimCanvas
	{
		/**
		 * Constructor
		 */ 
		public function ContentPanel() 
		{
			horizontalScrollPolicy = "off";
			verticalScrollPolicy = "off";
		}
	
		override protected function createChildren():void
		{
			super.createChildren();
			
			var closeBtn : Button = new Button();
			closeBtn.styleName = "closePanelButton";
			closeBtn.setStyle( "right", 2 );
			closeBtn.setStyle( "top", 4 );
			closeBtn.addEventListener( "click", dispatchCloseEvent ); 
			closeBtn.toolTip = "Close Panel";
			addChild( closeBtn );
		}
		
		protected function dispatchCloseEvent( evt:Event = null ) : void
		{
			dispatchEvent( new Event( Event.CLOSE, true ) );
		}
		
	}
}