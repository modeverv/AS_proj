package ws.tink.flex.pv3dEffects
{


	import ws.tink.flex.pv3dEffects.effectClasses.RotateInstance;
	import ws.tink.flex.pv3dEffects.Effect;
	
	import mx.effects.IEffectInstance;
	import mx.core.UIComponent;
	
	
	public class Rotate extends Effect
	{
	
		private static var AFFECTED_PROPERTIES:Array = [ "rotationX (PV3D)", "rotationY (PV3D)", "rotationZ (PV3D)" ];
		
		[Inspectable(category="General", defaultValue="NaN")]
		public var rotationXFrom:Number;
		
		[Inspectable(category="General", defaultValue="NaN")]
		public var rotationXTo:Number;
	
		[Inspectable(category="General", defaultValue="NaN")]
		public var rotationYFrom:Number;
	
		[Inspectable(category="General", defaultValue="NaN")]
		public var rotationYTo:Number;
		
		[Inspectable(category="General", defaultValue="NaN")]
		public var rotationZFrom:Number;
	
		[Inspectable(category="General", defaultValue="NaN")]
		public var rotationZTo:Number;
		
		
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
		public function Rotate( target:UIComponent = null )
		{
			super( target );
	
			instanceClass = RotateInstance;
		}
	
	
		override public function getAffectedProperties():Array
		{
			return AFFECTED_PROPERTIES;
		}
	
	
		override protected function initInstance( instance:IEffectInstance ):void
		{
			super.initInstance( instance );
	
			var rotateInstance:RotateInstance = RotateInstance( instance );
			
			rotateInstance.rotationXFrom = ( rotationXFrom ) ? rotationXFrom : 0;
			rotateInstance.rotationXTo = ( rotationXTo ) ? rotationXTo : 0;
			
			rotateInstance.rotationYFrom = ( rotationYFrom ) ? rotationYFrom : 0;
			rotateInstance.rotationYTo = ( rotationYTo ) ? rotationYTo : 0;
			
			rotateInstance.rotationZFrom = ( rotationZFrom ) ? rotationZFrom : 0;
			rotateInstance.rotationZTo = ( rotationZTo ) ? rotationZTo : 0;
		}
	
	}



}

