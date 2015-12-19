package com.adobe.empdir.controls
{
	import qs.controls.SuperImage;

	/**
	 * This class extends the Image component to invoke the 'complete' 
	 * event immediately when setting the source to an existing Bitmap object.
	 * 
	 * TODO: Re-evaluate whether or not this class is necessary.
	 */ 
	public class ExtendedImage extends SuperImage
	{
		
		public function ExtendedImage()
		{
		}
		
		override public function set source(value:*):void
		{
			super.source = value;
			/*if ( value != null && value is Bitmap && value != source )
			{
				dispatchEvent( new Event( "complete" ) );
			}*/
		}
		
		
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
		}
		
	}
}