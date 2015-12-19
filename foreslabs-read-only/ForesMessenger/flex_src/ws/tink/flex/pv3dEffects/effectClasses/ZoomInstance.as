package ws.tink.flex.pv3dEffects.effectClasses
{

	import flash.events.Event;
	
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import org.papervision3d.objects.Plane;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.objects.DisplayObject3D;


	public class ZoomInstance extends RotateInstance
	{
		
		public var alphaFrom		: Number;
		public var alphaTo			: Number;
		
		public var scaleFrom		: Number;
		public var scaleTo			: Number;



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
		public function ZoomInstance( target:UIComponent )
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
			super.onTweenUpdate( value );

			_display.alpha  = ( isNaN( value[ 3 ] ) ) ? 1 : value[ 3 ];
			_plane.scaleX = _plane.scaleY = ( isNaN( value[ 4 ] ) ) ? 1 : value[ 4 ];
			
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
			super.createPropertiesToTween();
			
			_to = _to.concat( new Array( alphaTo, scaleTo ) );
			_from = _from.concat( new Array( alphaFrom, scaleFrom ) );
		}
	
	}
}