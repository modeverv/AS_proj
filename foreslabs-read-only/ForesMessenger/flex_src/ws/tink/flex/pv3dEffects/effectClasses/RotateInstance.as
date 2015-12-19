package ws.tink.flex.pv3dEffects.effectClasses
{

	import flash.events.Event;
	
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import org.papervision3d.objects.Plane;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.objects.DisplayObject3D;


	public class RotateInstance extends EffectInstance
	{
		
		public var rotationXFrom	: Number;
		public var rotationXTo		: Number;
		
		public var rotationYFrom	: Number;
		public var rotationYTo		: Number;
		
		public var rotationZFrom	: Number;
		public var rotationZTo		: Number;
		
		protected var _plane			: Plane;


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
		public function RotateInstance( target:UIComponent )
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
			// Update DisplayObject3D.
			_plane.rotationX  = ( isNaN( value[ 0 ] ) ) ? 0 : value[ 0 ];
			_plane.rotationY  = ( isNaN( value[ 1 ] ) ) ? 0 : value[ 1 ];
			_plane.rotationZ  = ( isNaN( value[ 2 ] ) ) ? 0 : value[ 2 ];
			
			super.onTweenUpdate( value )
		}
		
		
		override protected function createDisplayObject3Ds():void
		{
			if( _plane ) _root3D.removeChild( _plane );
			
			var material:BitmapMaterial = BitmapMaterial( _materials[ 0 ] );
			material.oneSide = false;
			
			_plane = new Plane( material, target.width, target.height, 8, 8 );
			_plane.rotationX = rotationXFrom;
			_plane.rotationY = rotationYFrom;
			_plane.rotationZ = rotationZFrom;
			_root3D.addChild( _plane, "plane" );
		}
		
		
		override protected function createPropertiesToTween():void
		{
			_to = new Array( rotationXTo, rotationYTo, rotationZTo );
			_from = new Array( rotationXFrom, rotationYFrom, rotationZFrom );
		}
	
	}
}