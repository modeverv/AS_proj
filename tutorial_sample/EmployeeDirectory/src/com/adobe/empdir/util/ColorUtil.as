package com.adobe.empdir.util
{
	public class ColorUtil
	{
		/**
		 * Converts a hex color in the form of 0xRRGGBB to a string
		 * @param hex - in the form of 0xRRGGBB
		 * @return String - in the form of #RRGGBB
		 */
		public static function hexToString( hex : Number ) : String
		{
			var sHex : String = hex.toString( 16 );
			
			if( sHex.length == 1 ) sHex = "00000" + sHex;	
			else if( sHex.length == 2 ) sHex = "0000" + sHex;
			else if( sHex.length == 4 ) sHex = "00" + sHex;
			else if( sHex.length == 5 ) sHex = "0" + sHex;
			return "#" + sHex.toUpperCase();
		}
		
	}
}