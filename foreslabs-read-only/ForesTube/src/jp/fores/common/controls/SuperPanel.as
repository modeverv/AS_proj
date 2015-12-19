package jp.fores.common.controls {
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import jp.fores.common.assets.AssetsConstant;
	
	import mx.containers.Panel;
	import mx.controls.Button;
	import mx.core.Application;
	import mx.core.EdgeMetrics;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	import mx.managers.CursorManager;
	
	[Event(name="closeWindow", type="mx.events.FlexEvent")]

	public class SuperPanel extends Panel {
		[Bindable]
		public var showImage:Boolean = false;
				
		private var	pTitleBar:UIComponent;

		private var closeButton:Button = new Button();
				
		public function SuperPanel() {
		}

		override protected function createChildren():void {
			super.createChildren();

			this.pTitleBar = super.titleBar;
			this.setStyle("headerColors", [0xC3D1D9, 0xD2DCE2]);
			this.setStyle("borderColor", 0xD2DCE2);
			
			this.closeButton.width     		= 10;
			this.closeButton.height    		= 10;
			
			this.closeButton.setStyle("upSkin", AssetsConstant.PANEL_CLOSE_BUTTON);
			this.closeButton.setStyle("overSkin", AssetsConstant.PANEL_CLOSE_BUTTON);
			this.closeButton.setStyle("downSkin", AssetsConstant.PANEL_CLOSE_BUTTON);
			this.closeButton.setStyle("disabledSkin", AssetsConstant.PANEL_CLOSE_BUTTON);

			this.closeButton.styleName 		= "closeBtn";
			this.pTitleBar.addChild(this.closeButton);
			
			this.positionChildren();
			this.addListeners();
		}
		
		public function positionChildren():void {
			this.closeButton.buttonMode	   = true;
			this.closeButton.useHandCursor = true;
		}
		
		public function addListeners():void {
			this.closeButton.addEventListener(FlexEvent.CREATION_COMPLETE, initializeHandler);
			this.closeButton.addEventListener(Event.RENDER, initializeHandler);
			this.closeButton.addEventListener(MouseEvent.CLICK, closeClickHandler);
		}
		
		public function initializeHandler(event:Event):void {
			this.closeButton.x = this.width - this.closeButton.width - 8;
			this.closeButton.y = 9;

			this.closeButton.visible = showImage;
		}

		public function closeClickHandler(event:MouseEvent):void {
			dispatchEvent(new FlexEvent("closeWindow"));
		}
	}
}