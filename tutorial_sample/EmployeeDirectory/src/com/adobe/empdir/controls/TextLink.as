package com.adobe.empdir.controls
{
	import mx.controls.Text;
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;


	/**
	 *  The style to use when the link is in the over state. 
	 * 
	 *  @default null (same as the current textStyle)
	 */
	[Style(name="rollOverStyleName", type="String", inherit="yes")]

	/**
	 * This is a very simple extension of the Label class that makes it 
	 * interact more like a hyperlink with a mouse state. 
	 * 
 	 *  <p>The <code>&lt;mx:TextLink&gt;</code> tag inherits all the tag attributes
 	 *  of its superclass, and adds the following tag attributes:</p>
	 *
 	 *  <pre>
 	 *  &lt;mx:TextLink
 	 *    rollOverStyleName=""
 	 *   &gt;
 	 *  </pre>
 	 * 
	 */ 
	public class TextLink extends Text
	{	
		
		private var origStyleName : Object;
		
		/**
		 * Constructor
		 */ 
		public function TextLink()
		{
			super();
			mouseChildren = false;
			buttonMode = true;
			
			addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
       	    addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
		}
		
		protected function rollOverHandler( evt:MouseEvent ) : void
		{
			if ( getStyle("rollOverStyleName") != null )
			{
				 origStyleName = styleName;
			     styleName = getStyle("rollOverStyleName");
			}
		}
		
		protected function rollOutHandler( evt:MouseEvent ) : void
		{
			styleName = origStyleName;
		}
		
	}
}