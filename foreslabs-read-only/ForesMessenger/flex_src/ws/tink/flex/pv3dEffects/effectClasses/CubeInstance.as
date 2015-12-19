package ws.tink.flex.pv3dEffects.effectClasses
{

	import flash.events.Event;
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.geom.Matrix;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import org.papervision3d.objects.Plane;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.Cube;
	import org.papervision3d.materials.MaterialsList;
	import org.papervision3d.materials.MovieAssetMaterial;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.materials.ColorMaterial;
	
	import ws.tink.flex.pv3dEffects.Cube;
	import ws.tink.flex.managers.EffectManager;
	
	


	public class CubeInstance extends EffectInstance
	{
		
		public var direction		: String;
		public var constrain		: Boolean;
		
		private var _rotationYFrom	: Number;
		private var _rotationYTo	: Number;
		private var _rotationXFrom	: Number;
		private var _rotationXTo	: Number;

		
		
		private var _cube				: org.papervision3d.objects.Cube;
		private var _defaultCubeZ		: Number;
		private var _changeCubeZ		: Number;
		private var _cubeMaterialList	: MaterialsList;


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
		public function CubeInstance( target:UIComponent )
		{
			super( target );
		}
		
	
		override public function initEffect( event:Event ):void
		{
			//trace( event.type + "     " + UIComponent( event.target ).cr );
			switch( event.type )
			{	
				case Event.ADDED:
				case Event.REMOVED:
				case "childrenCreationComplete":
				case FlexEvent.CREATION_COMPLETE:
				case FlexEvent.SHOW :
				case FlexEvent.HIDE :
				{
					super.initEffect(event);
					break;
				}
				
				case "resizeStart":
				case "resizeEnd":
			}
		}
	

		override public function onTweenUpdate( value:Object ):void
		{
			 if( !isNaN( value[ 0 ] ) && !isNaN( value[ 1 ] ) )
			 {
			 	if( constrain )
			 	{
				 	var percent:Number;
				 	
				 	switch( direction )
				 	{
				 		case ws.tink.flex.pv3dEffects.Cube.LEFT :
				 		case ws.tink.flex.pv3dEffects.Cube.RIGHT :
				 		{
				 			percent = Math.abs( value[ 1 ] ) / 90;
				 			break;
				 		}
				 		case ws.tink.flex.pv3dEffects.Cube.UP :
				 		case ws.tink.flex.pv3dEffects.Cube.DOWN :
				 		{
				 			percent = Math.abs( value[ 0 ] ) / 90;
				 			break;
				 		}
				 		default :
				 		{
				 			// Error
				 		}
				 		
				 	}

					var normalizePercent:Number = ( percent >= 0.5 ) ? Math.abs( percent - 1 ) : percent;
					_cube.z = _defaultCubeZ + ( _changeCubeZ * ( normalizePercent * 2 ) );
				 }
			 	
			 	_cube.rotationX  = ( isNaN( value[ 0 ] ) ) ? 0 : value[ 0 ];
			 	_cube.rotationY  = ( isNaN( value[ 1 ] ) ) ? 0 : value[ 1 ];
			 }


			super.onTweenUpdate( value )
		}

		
		override protected function createBitmapDatas():void
		{
			super.createBitmapDatas();

			var color:uint = ( transparent ) ? 0x00000000 : 0x000000;

			var matrix:Matrix = new Matrix();
			matrix.scale( -1, -1 );
			matrix.translate( target.width, target.height );
			
			var bitmapData:BitmapData;
			bitmapData = new BitmapData( target.width, target.height, transparent, color );
			bitmapData.draw( IBitmapDrawable( _bitmapDatas[ 0 ] ), matrix );
			
			_bitmapDatas.push( bitmapData );
		}

		override protected function createMaterials():void
		{
			super.createMaterials();
			
			var cache:CacheInstance = EffectManager.effectManager.getPrevEffect( this );
			if( !cache ) throw new Error( "Cube/CubeInstance requires the previous effect to be or extend Cache/CacheInstance" );
			
			var material0:BitmapMaterial = BitmapMaterial( cache.materials[ 0 ] );
			var material1:BitmapMaterial = BitmapMaterial( _materials[ 0 ] );
			var material2:BitmapMaterial = new BitmapMaterial( BitmapData( _bitmapDatas[ 1 ] ) );
			
			_materials = new Array( material0, material1, material2 );
		
			_cubeMaterialList = new MaterialsList(
			{
				front:  new ColorMaterial( 0xFFFF00, 1  ),
				back:   material0,
				right:  material1,
				left:   material1,
				top:    material1,
				bottom: material2
			} );
		}
		
		override protected function createDisplayObject3Ds():void
		{
			if( _cube ) _root3D.removeChild( _cube );

			switch( direction )
			{
				case ws.tink.flex.pv3dEffects.Cube.LEFT :
				case ws.tink.flex.pv3dEffects.Cube.RIGHT :
				{
					_rotationXTo = 0;
					_rotationYTo = ( direction == ws.tink.flex.pv3dEffects.Cube.LEFT ) ? 90 : -90;
	
					_cube = new org.papervision3d.objects.Cube( _cubeMaterialList, target.width, target.width, target.height, 8, 8, 8 );
					_defaultCubeZ = target.width / 2;
					
					break;
				}
				case ws.tink.flex.pv3dEffects.Cube.UP :
				case ws.tink.flex.pv3dEffects.Cube.DOWN :
				{
					
					_rotationXTo = ( direction == ws.tink.flex.pv3dEffects.Cube.UP ) ? -90 : 90;
					_rotationYTo =  0;
					
					_cube = new org.papervision3d.objects.Cube( _cubeMaterialList, target.width, target.height, target.height, 8, 8, 8 );
					_defaultCubeZ = target.height / 2;
					
					break;
				}
				default :
				{
					// Error
				}
				
			}
		
			_changeCubeZ = Math.sqrt( ( _defaultCubeZ * _defaultCubeZ ) * 2 ) - _defaultCubeZ;
			
			_rotationYFrom =  0;
			_rotationXFrom = 0;

			_cube.z = _defaultCubeZ;

			_root3D.addChild( _cube, "cube" );
		}
		
		
		override protected function createPropertiesToTween():void
		{
			_to = new Array( _rotationXTo, _rotationYTo );
			_from = new Array( _rotationXFrom, _rotationYFrom );
		}
		

		
	}
}