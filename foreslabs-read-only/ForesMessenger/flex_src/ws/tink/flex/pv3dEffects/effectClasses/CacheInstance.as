package ws.tink.flex.pv3dEffects.effectClasses
{

	import flash.events.Event;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.events.EffectEvent;
	import mx.core.IUIComponent;
	import mx.effects.EffectManager;
	
	import org.papervision3d.objects.Plane;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.Cube;


	public class CacheInstance extends EffectInstance
	{
		

		protected var _cache				: Boolean;
		
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
		public function CacheInstance( target:UIComponent )
		{
			super( target );			
		}

		
		public function get cache():Boolean
		{
			return _cache;
		}
		
		public function get materials():Array
		{
			return _materials;
		}
		
		override public function play():void
		{	
			super.play();

			if( toString() == "[object CacheInstance]" ) _display.callLater( onTweenEnd, [ 0 ] );
		}
		
		/**
		 * Update DisplayObject3D objects.
		 * 
		 * Create the DisplayObject3D objects using the array of materials,
		 * then add the DisplayObject3D objects to _root3D
		 * 
		 * You will also need to invoked createBitmapDatas(), to create your BitmapData's for the materials.
		 */
		override protected function createDisplayObject3Ds():void
		{
			var bitmap:Bitmap = new Bitmap( BitmapData( _bitmapDatas[ 0 ] ) );
			bitmap.x = -( bitmap.width / 2 );
			bitmap.y = -( bitmap.height / 2 );
			_display.addChild( bitmap );
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_cache = true;
		}
		
	}
}