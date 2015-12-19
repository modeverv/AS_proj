package com.salesbuilder.charts
{
	import flash.events.Event;
	
	public class BubbleEvent extends Event
	{
		public static const BUBBLE_MOVE_START:String = "bubbleMove";
		public static const BUBBLE_MOVE:String = "bubbleMoveStart";
		public static const BUBBLE_MOVE_STOP:String = "bubbleMoveStop";
		public static const BUBBLE_DOUBLE_CLICK:String = "bubbleDoubleClick";
		
	    public function BubbleEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
	    {
    	    super(type, bubbles, cancelable);
    	}
	}
}