package ws.tink.flex.pv3dEffects
{


	import ws.tink.flex.pv3dEffects.effectClasses.ZoomInstance;
	import ws.tink.flex.pv3dEffects.Effect;
	
	import mx.effects.IEffectInstance;
	import mx.core.UIComponent;
	
	
	public class Zoom extends Rotate
	{
	
		
		[Inspectable(category="General", defaultValue="1")]
		public var alphaFrom:Number;
		
		[Inspectable(category="General", defaultValue="1")]
		public var alphaTo:Number;
	
		[Inspectable(category="General", defaultValue="1")]
		public var scaleFrom:Number;
	
		[Inspectable(category="General", defaultValue="1")]
		public var scaleTo:Number;

		
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
	
		/**
		 *  Constructor.
		 *
		 *  @param target The Object to animate with this effect.
		 */
		public function Zoom( target:UIComponent = null )
		{
			super( target );
	
			instanceClass = ZoomInstance;
		}
	
	
		override public function getAffectedProperties():Array
		{
			return super.getAffectedProperties().concat( [ "alpha", "scaleX", "scaleY" ] );
		}
	
	
		override protected function initInstance( instance:IEffectInstance ):void
		{
			super.initInstance( instance );
	
			var zoomInstance:ZoomInstance = ZoomInstance( instance );
			
			zoomInstance.alphaFrom = ( !isNaN( alphaFrom ) ) ? alphaFrom : 1;
			zoomInstance.alphaTo = ( !isNaN( alphaTo ) ) ? alphaTo : 1;
			
			zoomInstance.scaleFrom = ( !isNaN( scaleFrom ) ) ? scaleFrom : 1;
			zoomInstance.scaleTo = ( !isNaN( scaleTo ) ) ? scaleTo : 1;
		}
	
	}



}

