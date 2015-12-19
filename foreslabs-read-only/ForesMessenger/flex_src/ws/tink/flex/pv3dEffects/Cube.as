package ws.tink.flex.pv3dEffects
{


	import ws.tink.flex.pv3dEffects.Effect;
	
	import mx.effects.IEffectInstance;
	import mx.core.UIComponent;
	import ws.tink.flex.pv3dEffects.effectClasses.CubeInstance;


	public class Cube extends Effect
	{
	
		private static var AFFECTED_PROPERTIES	: Array = [ "rotationX (PV3D)", "rotationY (PV3D)" ];
		
		public static const LEFT				: String = "left";
		public static const RIGHT				: String = "right"; 
		public static const UP					: String = "up"; 
		public static const DOWN				: String = "down";
		
		
		[Inspectable(category="General", enumeration="left,right,up,down", defaultValue="left")]
		public var direction 					: String = Cube.LEFT;
		
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
		public function Cube( target:UIComponent = null )
		{
			super( target );
	
			instanceClass = CubeInstance;
		}
	
	
		override public function getAffectedProperties():Array
		{
			return AFFECTED_PROPERTIES;
		}
	
	
		override protected function initInstance( instance:IEffectInstance ):void
		{
			super.initInstance( instance );
	
			var cubeInstance:CubeInstance = CubeInstance( instance );
			cubeInstance.direction = direction;
			cubeInstance.constrain = constrain;
		}
	
	}



}

