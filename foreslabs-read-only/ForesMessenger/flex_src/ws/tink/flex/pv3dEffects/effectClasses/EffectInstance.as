package ws.tink.flex.pv3dEffects.effectClasses
{
	
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.IBitmapDrawable;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.effects.EffectManager;
	import mx.effects.effectClasses.TweenEffectInstance;
	import mx.events.FlexEvent;
	
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.scenes.Scene3D;
	
	import ws.tink.flex.managers.EffectManager;
	import ws.tink.flex.pv3dEffects.Effect;
	
	
	
	public class EffectInstance extends TweenEffectInstance
	{

		public var hideMethod 				: String;
		public var transparent 				: Boolean;
		
		protected var _display				: UIComponent;
		protected var _bitmapDatas			: Array;
		protected var _materials			: Array;
		
		protected var _scene				: Scene3D;
		protected var _camera				: Camera3D;
		protected var _root3D				: DisplayObject3D;
		
		protected var _from					: Array;
		protected var _to					: Array;
		
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
		public function EffectInstance( target:UIComponent )
		{
			super( target );
			
			initialize();
		}
		
		
		public function get display():UIComponent
		{
			return _display;
		}
		
		
		public function destroy():void
		{
			var i:int;
			
			/*var numChildren3D:int = _root3D.children;
			for( i = 0; i < numBitmapDatas; i++ )
			{
				_root3D.removeChild( _root3D.ge
			}*/
			
			_scene.removeChild( _root3D );
			
			
			
			if( _bitmapDatas.length )
			{
				var bitmapData:BitmapData;
				var numBitmapDatas:int = _bitmapDatas.length;
				for( i = 0; i < numBitmapDatas; i++ )
				{
					bitmapData = BitmapData( _bitmapDatas.shift() );
					bitmapData.dispose();
				}
			}
			
			_root3D = null;
			_scene = null;
			_camera = null;
			_display = null;
			
			_bitmapDatas = null;
			_materials = null;
		}


		override public function play():void
		{
			// Try to cache the target as a bitmap.
			mx.effects.EffectManager.mx_internal::startBitmapEffect( UIComponent(target) );
			
			createBitmapDatas();
			createMaterials();
			createDisplayObject3Ds();
			
			_scene.renderCamera( _camera );
			
			super.play();

			setTargetVisible( false );
			
			createPropertiesToTween();
			
			createTween( this, _from, _to, duration );
		}
		
		
		override public function onTweenUpdate( value:Object ):void
		{
			// Tell the EffectManager not to listen to the "move" event.
			// Otherwise, moveEffect="Move" would cause a new Move effect
			// to be create with each onTweenUpdate.
			mx.effects.EffectManager.suspendEventHandling();
			
			_scene.renderCamera( _camera );
			
			mx.effects.EffectManager.resumeEventHandling();
		}
		
		
		override public function onTweenEnd(value:Object):void
		{
			super.onTweenEnd( value );

			setTargetVisible( true );
			
			mx.effects.EffectManager.mx_internal::endBitmapEffect(UIComponent(target));
		}
		
		
		protected function initialize():void
		{
			var global:Point = target.parent.localToGlobal( new Point( target.x, target.y ) );
			
			_display = new UIComponent();
			(target as UIComponent).systemManager.addChild(_display);
			
			_display.addEventListener( FlexEvent.CREATION_COMPLETE, onDisplayCreationComplete );
			_display.x = global.x + ( target.width / 2 );
			_display.y = global.y + ( target.height / 2 );
			_display.mouseEnabled = false;
			_display.mouseChildren = false;

			_scene = new Scene3D( _display );
			
			_camera = new Camera3D();
			_camera.zoom = 3;
			_camera.focus = 500;
			
			_root3D = _scene.addChild( new DisplayObject3D( "_root3D" ) );
			
			ws.tink.flex.managers.EffectManager.effectManager.addEffect( this );
		}

		
		
		/**
		 * Create BitmapData objects for use with materials.
		 * 
		 * Override this method if you want more complex BitmapData objects.
		 * 
		 * The default creates a single BitmapData that is a snapshot of the target UIComponent.
		 */
		protected function createBitmapDatas():void
		{
			_bitmapDatas = new Array();
			
			var color:uint = ( transparent ) ? 0x00000000 : 0x000000;
						
			var bitmapData:BitmapData;
			bitmapData = new BitmapData( target.width, target.height, transparent, color );
			bitmapData.draw( IBitmapDrawable( target ) );
			
			_bitmapDatas.push( bitmapData );
		}
		
		
		/**
		 * Create materials for DisplayObject3D objects using BitmapData objects.
		 * 
		 * Override this method if you want complex materials.
		 * The default creates a single BitmapMaterial that is a snapshot of the target UIComponent.
		 */
		protected function createMaterials():void
		{
			_materials = new Array();
			
			var material:BitmapMaterial = new BitmapMaterial( BitmapData( _bitmapDatas[ 0 ] ) );
			material.doubleSided = false;
			
			_materials.push( material );
		}
		
		/**
		 * Create DisplayObject3D objects.
		 * 
		 * Create the DisplayObject3D objects using the array of materials,
		 * then add the DisplayObject3D objects to _root3D.
		 */
		protected function createDisplayObject3Ds():void
		{
			// Must be overridden.
		}
		
		protected function createPropertiesToTween():void
		{
			// Must be overridden.
		}
		
		protected function disposeBitmapDatas():void
		{
			if( !_bitmapDatas ) _bitmapDatas = new Array();
			
			var bitmapData:BitmapData;
			var numBitmapDatas:int = _bitmapDatas.length;
			for( var i:int = 0; i < numBitmapDatas; i++ )
			{
				bitmapData = BitmapData( _bitmapDatas.shift() );
				bitmapData.dispose();
			}
		}
		
		private function setTargetVisible( value:Boolean ):void
		{
			switch( hideMethod )
			{
				case Effect.HIDE_METHOD_BLEND_MODE :
				{
					target.blendMode = ( value ) ? BlendMode.NORMAL : BlendMode.ERASE;
					break;
				}
				case Effect.HIDE_METHOD_ALPHA :
				{
					target.alpha = ( value ) ? 1 : 0;
					break;
				}
				case Effect.HIDE_METHOD_NONE :
				{
					
					break;
				}
				default : throw new Error( "EffectInstance: hideMethod '" + hideMethod + "' not supported" );
			}
		}
		
		
		private function onDisplayCreationComplete( event:FlexEvent ):void
		{
			dispatchEvent( event );
		}
		
	}
}