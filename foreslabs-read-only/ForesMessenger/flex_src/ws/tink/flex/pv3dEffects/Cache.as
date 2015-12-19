package ws.tink.flex.pv3dEffects
{


	import ws.tink.flex.pv3dEffects.Effect;
	
	import mx.effects.IEffectInstance;
	import mx.core.UIComponent;
	import ws.tink.flex.pv3dEffects.effectClasses.CacheInstance;
	
	
	public class Cache extends Effect
	{
		
		
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
		public function Cache( target:UIComponent = null )
		{
			super( target );
	
			instanceClass = CacheInstance;
		}
	
	
		override public function getAffectedProperties():Array
		{
			return [];
		}
	
	
		override protected function initInstance( instance:IEffectInstance ):void
		{
			super.initInstance( instance );
	
			var cacheInstance:CacheInstance = CacheInstance( instance );
		}
	
	}



}

