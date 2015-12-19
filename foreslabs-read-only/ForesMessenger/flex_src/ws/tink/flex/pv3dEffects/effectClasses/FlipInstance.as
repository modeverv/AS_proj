package ws.tink.flex.pv3dEffects.effectClasses
{

	import flash.events.Event;
	
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import org.papervision3d.objects.Plane;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	
	import ws.tink.flex.pv3dEffects.Flip;


	public class FlipInstance extends EffectInstance
	{
		
		public var direction		: String;
		public var constrain		: Boolean;
		public var type				: String;
		
		public var _rotationYFrom	: Number;
		public var _rotationYTo		: Number;
		public var _rotationXFrom	: Number;
		public var _rotationXTo		: Number;
		public var _zFrom			: Number;
		public var _zTo				: Number;
		
		private var _plane			: Plane;


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
		public function FlipInstance( target:UIComponent )
		{
			super( target );
			
			
		}
		
	
		override public function initEffect( event:Event ):void
		{
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
			_plane.rotationX  = ( isNaN( value[ 0 ] ) ) ? 0 : value[ 0 ];
			_plane.rotationY  = ( isNaN( value[ 1 ] ) ) ? 0 : value[ 1 ];
			_plane.z  = ( isNaN( value[ 2 ] ) ) ? 0 : value[ 2 ];
			
			super.onTweenUpdate( value )
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
			switch( direction )
			{
				case Flip.LEFT :
				{
					_rotationXFrom = 0;
					_rotationXTo = 0;
					_rotationYFrom = ( type == Flip.SHOW ) ? -90 : 0;
					_rotationYTo = _rotationYFrom + 90;
	
					break;
				}
				case Flip.RIGHT :
				{
					_rotationXFrom = 0;
					_rotationXTo = 0;
					_rotationYFrom = ( type == Flip.SHOW ) ? 90 : 0;
					_rotationYTo = _rotationYFrom - 90;
	
					break;
				}
				case Flip.DOWN :
				{
					
					_rotationXFrom = ( type == Flip.SHOW ) ? -90 : 0;
					_rotationXTo = _rotationXFrom + 90;
					_rotationYFrom =  0;
					_rotationYTo =  0;

					break;
				}
				case Flip.UP :
				{
					_rotationXFrom = ( type == Flip.SHOW ) ? 90 : 0;
					_rotationXTo = _rotationXFrom - 90;
					_rotationYFrom =  0;
					_rotationYTo =  0;
					
					break;
				}
				default :
				{
					// Error
				}
			}

			_plane = new Plane( BitmapMaterial( _materials[ 0 ] ), target.width, target.height, 8, 8 );
			_plane.rotationX = _rotationXFrom;
			_plane.rotationY = _rotationYFrom;

			if( constrain )
			{
				if( type == Flip.SHOW )
				{
					_zFrom = target.width / 2;
					_zTo = 0;
				}
				else
				{
					_zFrom = 0
					_zTo = target.width / 2;
				}
			}
			else
			{
				_zFrom = 0
				_zTo = 0;
			}
			
			
			_root3D.addChild( _plane, "plane" );
		}
		
		
		override protected function createPropertiesToTween():void
		{
			_from = new Array( _rotationXFrom, _rotationYFrom, _zFrom );
			_to = new Array( _rotationXTo, _rotationYTo, _zTo );
		}
	
	}
}