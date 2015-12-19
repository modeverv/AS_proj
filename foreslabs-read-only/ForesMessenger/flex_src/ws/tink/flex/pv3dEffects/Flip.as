package ws.tink.flex.pv3dEffects
{


	import ws.tink.flex.pv3dEffects.Effect;
	
	import mx.effects.IEffectInstance;
	import mx.core.UIComponent;
	import ws.tink.flex.pv3dEffects.effectClasses.FlipInstance;
	
	
	public class Flip extends Effect
	{
	
		private static var AFFECTED_PROPERTIES:Array = [ "rotationX (PV3D)", "rotationY (PV3D)", "rotationZ (PV3D)" ];
		
		public static const SHOW				: String = "show";
		public static const HIDE				: String = "hide"; 
		
		public static const LEFT				: String = "left";
		public static const RIGHT				: String = "right"; 
		public static const UP					: String = "up"; 
		public static const DOWN				: String = "down";
		
		[Inspectable(category="General", enumeration="left,right,up,down", defaultValue="left")]
		public var direction 					: String = Flip.LEFT;
		
		[Inspectable(category="General", enumeration="show,hide", defaultValue="show")]
		public var type							: String = Flip.SHOW;
		
		[Inspectable(category="General", enumeration="false,true", defaultValue="true")]
		public var constrain 					: Boolean = false;
		
		
		
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
		public function Flip( target:UIComponent = null )
		{
			super( target );
	
			instanceClass = FlipInstance;
		}
	
	
		override public function getAffectedProperties():Array
		{
			return AFFECTED_PROPERTIES;
		}
	
	
		override protected function initInstance( instance:IEffectInstance ):void
		{
			super.initInstance( instance );
	
			var flipInstance:FlipInstance = FlipInstance( instance );
			flipInstance.type = type;
			flipInstance.direction = direction;
			flipInstance.constrain = constrain;
		}
	
	}



}

