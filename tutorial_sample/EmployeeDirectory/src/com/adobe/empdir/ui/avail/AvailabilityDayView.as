package com.adobe.empdir.ui.avail
{
	import com.adobe.empdir.avail.OWAFreeBusyConstants;
	
	import flash.display.Graphics;
	
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	import mx.core.UITextField;
	
	
	/**
	 * This is a component to display availability in a vertical column view.
	 * The look and feel of this component is fairly rigid. 
	 */ 
	public class AvailabilityDayView extends UIComponent
	{
		private static var LABEL_WIDTH : int = 40;
		private static var CELL_HEIGHT : int = 15;  // the height of a half-hour block
		
		//private var labelBG : Sprite;
		private var trackBG : UIComponent;
		
		//private var trackFreeFG : UIComponent;
		//private var trackBusyFG : UIComponent;
		
		/** An array of the text labels used in the view. **/
		private var hourLabels : Array;
		
		/** An array of Canvas objects representing the free cells. **/
		private var freeCells : Array;
		
		/** An array of Canvas objects representing the busy cells. **/
		private var busyCells : Array;
		
		private var scheduleVals : Array;
		
		
		/**
		 * Constructor
		 */ 
		public function AvailabilityDayView() 
		{
			scheduleVals = new Array();
			freeCells = new Array();
			busyCells = new Array();
			hourLabels = new Array();
		}
		
		override protected function createChildren():void
		{
			trackBG = new UIComponent();
			addChild( trackBG );
			// create the hour labels
			for ( var i:int = 0; i < 24; i++ ) 
			{
				var tf : UITextField =  UITextField(createInFontContext(UITextField));
	            tf.styleName = this;
            	addChild( tf );
            	hourLabels.push( tf );
            	
            	if ( i == 0 )
            	{
            		tf.text = "12 am";
            	}
            	else if ( i < 12 )
            	{
            		tf.text = String(i) + " am";
            	}
            	else if ( i == 12 )
            	{
            		tf.text = "Noon";
            	}
            	else
            	{
            		tf.text	= String(i - 12) + " pm";
            	}
            	
            	tf.width = LABEL_WIDTH - 7;
            	tf.height = tf.textHeight + 2;
			}
		
			// We have 50 half-hours. We create 100 cells. We use Canvas for animation purposes, but this is inefficient.
			var cell : Canvas;
			for ( i = 0; i < 50; i++ ) 
			{
				// free cell 
				cell = new Canvas();
				cell.toolTip = "Available";
				cell.styleName = "availabilityFreeCell";
				addChild( cell );
				freeCells.push( cell );
				
				// busy cell
				cell = new Canvas();
				cell.toolTip = "Busy";
				cell.styleName = "availabilityBusyCell";
				cell.setStyle( "showEffect", "Fade" );
				//cell.setStyle( "hideEffect", "Fade" );
				addChild( cell );
				busyCells.push( cell );
			}
		}
		
		
		public function get schedule() : Array
		{
			return scheduleVals;
		}
		
		/**
		 * An array of OWA schedule constants. Its assumed that each entry w
		 * @param scheduleVals An array of numbers, each one representing a OWAScheduleConstant value indicating availability.
		 */ 
		public function set schedule( scheduleVals:Array ) : void
		{
			if ( ! scheduleVals )
				scheduleVals = new Array();
			this.scheduleVals = scheduleVals;
		
			invalidateDisplayList();
		}
		
		override protected function measure() : void
		{
			super.measure();
			measuredMinWidth = LABEL_WIDTH + 40;
			measuredWidth = width;
			measuredMinHeight = measuredHeight = 25 * 2 * CELL_HEIGHT;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );

			
			var trackBGColor : int = getStyle( "trackBackgroundColor" );
			var hourDividerColor : int = getStyle( "hourDividerColor" );
			var verticalDividerColor : int = getStyle( "verticalDividerColor" );
		
			// we draw 25 cells, with the twenty four cells and a cell preceding it.
			var label : UITextField;
			var freeCell : Canvas, busyCell : Canvas;
			var yPos : int;
			var schedVal : Object
			
			var trackWidth : int = unscaledWidth - (LABEL_WIDTH + 1);
		
			// we have three levels of graphics. the background track, and then the overlay of the free and busy foregrounds
			var bg : Graphics = trackBG.graphics;
			bg.clear();
		
			// draw the background color
			bg.lineStyle( 0, 0, 0 );
			bg.beginFill( trackBGColor, 1 );
			bg.drawRect( LABEL_WIDTH + 1, 0, trackWidth, unscaledHeight );
			bg.endFill();
			
			// draw the one pixel verticalBorder
			bg.beginFill( verticalDividerColor, 1 );
			bg.drawRect( LABEL_WIDTH, 0, 1, unscaledHeight );
			bg.endFill();
			
			for ( var i:int = 0; i<25; i++ )
			{
				yPos = i * 2 * CELL_HEIGHT;
				
				if ( i < 24 )
				{
					label = hourLabels[ i ];
					label.y = 2 * CELL_HEIGHT * (i + 1) - label.height/2;
				}
				
				// draw the divider line for half-hour marks
				bg.beginFill( hourDividerColor, 1 );
				bg.drawRect( LABEL_WIDTH + 2, yPos + CELL_HEIGHT, trackWidth - 2, 1 ); 
				bg.endFill();
				
				// place the free/busy cells. we do this twice for each half hour  
				schedVal = null;
				if ( i > 0 )
					schedVal = scheduleVals[ 2*(i-1) ]; // first half-hour
				freeCell = freeCells[ 2*i ] as Canvas;
				busyCell = busyCells[ 2*i ] as Canvas;
				placeCells( freeCell, busyCell, yPos, trackWidth, schedVal );
				
				schedVal = null;
				if ( i > 0 )
					schedVal = scheduleVals[ 2*(i-1) + 1 ]; // second half-hour
				freeCell = freeCells[ 2*i + 1 ] as Canvas;
				busyCell = busyCells[ 2*i + 1 ] as Canvas;
				placeCells( freeCell, busyCell, yPos + CELL_HEIGHT, trackWidth, schedVal );
	
			}
		}
		
		private function placeCells( freeCell:Canvas, busyCell:Canvas, yPos:int, trackWidth:int, schedVal:Object ) : void
		{
			busyCell.x = freeCell.x = LABEL_WIDTH + 1;
			busyCell.y = freeCell.y = yPos + 1;
			busyCell.width = freeCell.width = trackWidth - 1;
			busyCell.height = freeCell.height = CELL_HEIGHT - 1;
			
			busyCell.visible = schedVal != null && schedVal != OWAFreeBusyConstants.FREE;
		}
		
	}
}