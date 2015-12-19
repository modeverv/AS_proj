package com.salesbuilder.charts
{
	import flash.display.Graphics;
	import flash.events.MouseEvent;
	import mx.charts.DateTimeAxis;
	import mx.charts.LinearAxis;
	import mx.charts.chartClasses.CartesianTransform;
	import mx.charts.series.BubbleSeries;
	import mx.core.IDataRenderer;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.graphics.IStroke;

	[Event(name="bubbleMoveStart", type="BubbleEvent")]
	[Event(name="bubbleMove", type="BubbleEvent")]
	[Event(name="bubbleMoveStop", type="BubbleEvent")]

	public class OpportunityBubbleRenderer extends UIComponent implements IDataRenderer
	{
		private var stageX:Number;
		private var stageY:Number;
		private var dataX:Number;
		private var dataY:Number;
		
		private var hAxis:DateTimeAxis;
		private var vAxis:LinearAxis;
		
		private var hMin:Number;
		private var hMax:Number;
		private var vMin:Number;
		private var vMax:Number;

		private var _over:Boolean = false;
		
		private var _data:Object;
	    
		public function OpportunityBubbleRenderer()
		{
			super();
			doubleClickEnabled = true;
			addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			addEventListener(MouseEvent.DOUBLE_CLICK, doubleClickHandler);
			addEventListener(MouseEvent.MOUSE_DOWN, startMoving);
		}
		
	    [Bindable("dataChange")]
	    public function get data():Object 
	    {
	        return _data;
	    }
	    
	    public function set data(value:Object):void 
	    {
	        _data = value;
	        dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
	    }
		
		private function rollOverHandler(e:MouseEvent):void
		{
			_over = true;
			invalidateDisplayList();						
		}
		
		private function rollOutHandler(e:MouseEvent):void
		{
			_over = false;
			invalidateDisplayList();
		}

		private function startMoving(event:MouseEvent):void
		{
			hAxis = DateTimeAxis(BubbleSeries(parent).getAxis(CartesianTransform.HORIZONTAL_AXIS));
			vAxis = LinearAxis(BubbleSeries(parent).getAxis(CartesianTransform.VERTICAL_AXIS));
			hMin = hAxis.minimum.time;
			hMax = hAxis.maximum.time;
			vMin = vAxis.minimum;
			vMax = vAxis.maximum;

			stageX = event.stageX;
			stageY = event.stageY;

			dataX = _data.item.expectedCloseDate.time;
			dataY = _data.item.probability;

			systemManager.addEventListener(MouseEvent.MOUSE_MOVE, moving, true);
			systemManager.addEventListener(MouseEvent.MOUSE_UP, stopMoving, true);

			dispatchEvent(new BubbleEvent(BubbleEvent.BUBBLE_MOVE_START, true, true));
		}

		private function moving(event:MouseEvent):void
		{
			var expectedCloseDate:Number = dataX + (event.stageX - stageX) * (hMax - hMin) / parent.width;
			if (expectedCloseDate >= hMin && expectedCloseDate <= hMax)
			{
				_data.item.expectedCloseDate = new Date(expectedCloseDate);
			}

			var probability:Number = Math.round(dataY + (stageY - event.stageY) * 100 / parent.height);
			if (probability >= vMin && probability <= vMax)
			{
				_data.item.probability = probability;
			}

			dispatchEvent(new BubbleEvent(BubbleEvent.BUBBLE_MOVE, true, true));
		}
		
		private function stopMoving(event:MouseEvent):void
		{
			systemManager.removeEventListener(MouseEvent.MOUSE_MOVE, moving, true);
			systemManager.removeEventListener(MouseEvent.MOUSE_UP, stopMoving, true);
			dispatchEvent(new BubbleEvent(BubbleEvent.BUBBLE_MOVE_STOP, true, true));
		}
		
		private function doubleClickHandler(event:MouseEvent):void
		{
			dispatchEvent(new BubbleEvent(BubbleEvent.BUBBLE_DOUBLE_CLICK, true, true));
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);

			var fill:Number;
			
			fill = 0xC19021;
			
			var stroke:IStroke = getStyle("stroke");
					
			var w:Number = stroke ? stroke.weight / 2 : 0;
	
			var g:Graphics = graphics;
			g.clear();		
			if (stroke)
			{
				stroke.apply(g);
			}
			g.beginFill(fill, _over ? 1 : 0.8);
			g.drawCircle(unscaledWidth / 2, unscaledHeight / 2, unscaledWidth / 2 - w);
			g.endFill();
		}

	}
}
