package ws.tink.flex.pv3dEffects
{
	
	import mx.core.UIComponent;
	
	import mx.effects.TweenEffect;
	import mx.effects.IEffectInstance;
	
	import ws.tink.flex.pv3dEffects.effectClasses.EffectInstance;
	

	public class Effect extends TweenEffect
	{
		
		
		public static const HIDE_METHOD_BLEND_MODE	: String = "blendMode";
		public static const HIDE_METHOD_ALPHA		: String = "alpha";
		public static const HIDE_METHOD_NONE		: String = "none";
		
		[Inspectable(category="General", enumeration="alpha,blendMode,none", defaultValue="blendMode")]
		public var hideMethod 						: String = DEFAULT_HIDE_METHOD;
		
		[Inspectable(category="General", enumeration="false,true", defaultValue="true")]
		public var transparent 						: Boolean = DEFAULT_TRANSPARENT;
		
		
		private const DEFAULT_HIDE_METHOD	: String = Effect.HIDE_METHOD_BLEND_MODE;
		private const DEFAULT_TRANSPARENT	: Boolean = true;
		
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
	
		/**
		 *  Constructor.
		 *
		 *  @param target The UIComponent to animate with this effect.
		 */
		public function Effect( target:UIComponent )
		{
			super( target );
	
			instanceClass = EffectInstance;
		}
		
		
		override protected function initInstance( instance:IEffectInstance ):void
		{
			super.initInstance( instance );
	
			var effectPV3DInstance:EffectInstance = EffectInstance( instance );
			
			effectPV3DInstance.hideMethod = hideMethod;
			effectPV3DInstance.transparent = transparent;
		}
	}
}