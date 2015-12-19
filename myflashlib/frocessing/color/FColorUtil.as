// --------------------------------------------------------------------------
// Project Frocessing
// ActionScript 3.0 drawing library like Processing.
// --------------------------------------------------------------------------
//
// Frocessing drawing library
// Copyright (C) 2008  TAKANAWA Tomoaki (http://nutsu.com) and
//					   Spark project (www.libspark.org)
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
// 
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//
// contact : face(at)nutsu.com
//

package frocessing.color {
	
	import frocessing.math.FMath;
	
	/**
	 * FColorUtil クラスは、色関連のユーティリティを提供します.
	 * 
	 * @author nutsu
	 * @version 0.1.1
	 * 
	 * @see frocessing.color.FColor
	 * @see frocessing.color.ColorRGB
	 * @see frocessing.color.ColorHSV
	 * @see frocessing.color.ColorBlend
	 * @see frocessing.color.ColorLerp
	 * @see frocessing.color.ColorConvert
	 */
	public class FColorUtil {
		
		/*
		public function FColorUtil() {
			throw new Error("インスタンスはつくっても意味ないです");
		}
		*/
		
		public static function invert( col:uint ):uint
		{
			return col ^ 0xffffff;
		}
		
		//--------------------------------------------------------------------------------------------------- MAKE FCOLOR
		
		/**
		 * 24bit Color (0xRRGGBB) から FColor クラスのインスタンスを生成します.
		 * @param	value 0xRRGGBB
		 */
		public static function color( value:uint ):FColor
		{
			return new FColor( value & 0xffffff );
		}
		
		/**
		 * 32bit Color (0xAARRGGBB) から FColor クラスのインスタンスを生成します.
		 * @param	value	0xAARRGGBB
		 */
		public static function color32( value:uint ):FColor
		{
			return new FColor( value & 0x00ffffff, (value>>>24)/0xff );
		}
		
		/**
		 * RGB値 から FColor クラスのインスタンスを生成します.
		 * @param	r	red [0,255]
		 * @param	g	green [0,255]
		 * @param	b	blue [0,255]
		 * @param	a	alpha [0.0,1.0]
		 */
		public static function rgb( r:uint, g:uint, b:uint, a:Number=1.0 ):FColor
		{
			return new FColor( valueOfRGB(r,g,b), a );
		}
		
		/**
		 * HSV値 から FColor クラスのインスタンスを生成します.
		 * @param	h	hue degree 360
		 * @param	s	saturation [0.0,1.0]
		 * @param	v	brightness [0.0,1.0]
		 * @param	a	alpha [0.0,1.0]
		 */
		public static function hsv( h:Number, s:Number=1.0, v:Number=1.0, a:Number=1.0 ):FColor
		{
			var c:FColor = new FColor();
			c.hsv( h, s, v, a );
			return c;
		}
		
		/**
		 * グレイ値 から FColor クラスのインスタンスを生成します.
		 * @param	gray_	gray [0,255]
		 * @param	a	alpha [0.0,1.0]
		 */
		public static function gray( gray_:uint, a:Number=1.0):FColor
		{
			return new FColor( gray_<<16 | gray_<<8 | gray_, a );
		}
		
		//--------------------------------------------------------------------------------------------------- MAKE COLOR_RGB
		
		/**
		 * 24bit Color (0xRRGGBB) から ColorRGB クラスのインスタンスを生成します.
		 * @param	value 0xRRGGBB
		 */
		public static function valueToRGB( value:uint ):ColorRGB
		{
			return new ColorRGB( value >>> 16, ( value & 0x00ff00 ) >>> 8, value & 0x0000ff );
		}
		
		/**
		 * 32bit Color (0xAARRGGBB) から ColorRGB クラスのインスタンスを生成します.
		 * @param	value	0xAARRGGBB
		 */
		public static function value32ToRGB( value:uint ):ColorRGB
		{
			return new ColorRGB( ( value & 0x00ff0000 ) >>> 16, ( value & 0x0000ff00 ) >>> 8, value & 0x000000ff, ( value >>> 24 ) / 0xff );
		}
		
		/**
		 * グレイ値 から ColorRGB クラスのインスタンスを生成します.
		 * @param	gray_	gray [0,255]
		 * @param	a	alpha [0.0,1.0]
		 */
		public static function grayToRGB( gray_:uint, a:Number=1.0):ColorRGB
		{
			return new ColorRGB( gray_, gray_, gray_, a );
		}
		
		/**
		 * HSV値 から ColorRGB クラスのインスタンスを生成します.
		 * @param	h	hue degree 360
		 * @param	s	saturation [0.0,1.0]
		 * @param	v	brightness [0.0,1.0]
		 * @param	a	alpha [0.0,1.0]
		 */
		public static function hsvToRGB( h:Number, s:Number=1.0, v:Number=1.0, a:Number=1.0 ):ColorRGB
		{
			return new ColorHSV( h, s, v, a ).toRGB();
		}
		
		//--------------------------------------------------------------------------------------------------- MAKE COLOR_HSV
		
		/**
		 * 24bit Color (0xRRGGBB) から ColorHSV クラスのインスタンスを生成します.
		 * @param	value 0xRRGGBB
		 */
		public static function valueToHSV( value:uint ):ColorHSV
		{
			return ColorHSV.fromRGB( value >>> 16, ( value & 0x00ff00 ) >>> 8, value & 0x0000ff );
		}
		
		/**
		 * 32bit Color (0xAARRGGBB) から ColorHSV クラスのインスタンスを生成します.
		 * @param	value	0xAARRGGBB
		 */
		public static function value32ToHSV( value:uint ):ColorHSV
		{
			return ColorHSV.fromRGB( ( value & 0x00ff0000 ) >>> 16, ( value & 0x0000ff00 ) >>> 8, value & 0x000000ff, ( value >>> 24 ) / 0xff );
		}
		
		/**
		 * グレイ値 から ColorHSV クラスのインスタンスを生成します.
		 * @param	gray_	gray [0,255]
		 * @param	a	alpha [0.0,1.0]
		 */
		public static function grayToHSV( gray_:uint, a:Number=1.0):ColorHSV
		{
			return new ColorHSV( 0, 0, gray_/0xff, a );
		}
		
		/**
		 * RGB値 から ColorHSV クラスのインスタンスを生成します.
		 * @param	r	red [0,255]
		 * @param	g	green [0,255]
		 * @param	b	blue [0,255]
		 * @param	a	alpha [0.0,1.0]
		 */
		public static function rgbToHSV( r:uint, g:uint, b:uint, a:Number=1.0 ):ColorHSV
		{
			return ColorHSV.fromRGB( r, g, b, a );
		}
		
		//--------------------------------------------------------------------------------------------------- UINT
		
		/**
		 * RGB値 を 24bit Color (uint) に変換します.
		 * @param	r	red [0,255]
		 * @param	g	green [0,255]
		 * @param	b	blue [0,255]
		 * @return	0xRRGGBB
		 */
		public static function valueOfRGB( r:uint, g:uint, b:uint ):uint
		{
			return ( r & 0xff ) << 16 | ( g & 0xff ) << 8 | ( b & 0xff );
		}
		
		/**
		 * RGB値,アルファ値 を 32bit Color (uint) に変換します.
		 * @param	r	red [0,255]
		 * @param	g	green [0,255]
		 * @param	b	blue [0,255]
		 * @param	a	alpha [0.0,1.0]
		 * @return	0xAARRGGBB
		 */
		public static function valueOfARGB( r:uint, g:uint, b:uint, a:Number=1.0 ):uint
		{
			return ( Math.round( a*0xff ) & 0xff )<<24 | ( r & 0xff ) << 16 | ( g & 0xff ) << 8 | b & 0xff;
		}
		
		/**
		 * グレイ値 を 24bit Color (uint) または、32bit Color (uint) に変換します.
		 * @param	gray_	gray [0,255]
		 * @param	a	alpha [0.0,1.0]
		 * @return	0xRRGGBB or 0xAARRGGBB
		 */
		public static function valueOfGray( gray:uint, a:Number=NaN ):uint
		{
			if( isNaN(a) )
				return valueOfRGB( gray, gray, gray );
			else
				return valueOfARGB( gray, gray, gray, a );
		}
		
		/**
		 * HSV値 を 24bit Color (uint) または、32bit Color (uint) に変換します.
		　* @param	h	hue degree 360
		 * @param	s	saturation [0.0,1.0]
		 * @param	v	brightness [0.0,1.0]
		 * @param	a	alpha [0.0,1.0]
		 * @return	0xRRGGBB or 0xAARRGGBB
		 */
		public static function valueOfHSV( h:Number, s:Number=1.0, v:Number=1.0, a:Number=NaN ):uint
		{
			var cc:Object = ColorConvert.HSV2RGB( h, s, v );
			if( isNaN(a) )
				return valueOfRGB( cc.r, cc.g, cc.b );
			else
				return valueOfARGB( cc.r, cc.g, cc.b, a );
		}
		
		//--------------------------------------------------------------------------------------------------- CONVERT
		
		/**
		 * RGB値　を HSV値 に変換します.
		 * @param	r	red [0,255]
		 * @param	g	green [0,255]
		 * @param	b	blue [0,255]
		 * @return	{ h:Number, s:Number, v:Number }
		 * @see frocessing.color.ColorConvert
		 */
		public static function RGB2HSV( r:uint, g:uint, b:uint ):Object
		{
			return ColorConvert.RGB2HSV( r, g, b );
		}
		
		/**
		 * HSV値 を RGB値 に変換します.
		 * @param	h	hue degree 360
		 * @param	s	saturation [0.0,1.0]
		 * @param	v	brightness [0.0,1.0]
		 * @return	{ r:uint, g:uint ,b:uint }
		 * @see frocessing.color.ColorConvert
		 */
		public static function HSV2RGB( h:Number, s:Number=1.0, v:Number=1.0 ):Object
		{
			return ColorConvert.HSV2RGB( h, s, v );
		}
		
		//--------------------------------------------------------------------------------------------------- Blend
		
		/**
		 * 2つの色をブレンドした FColor クラスのインスタンスを生成します.
		 * 
		 * <p>
		 * ブレンドモードについては、ColorBlend　を参照してください.
		 * </p>
		 * 
		 * @param	color1	back color
		 * @param	color2	fore color
		 * @param	blend_mode
		 * @see frocessing.color.ColorBlend
		 */
		public static function blendColor( color1:IColor, color2:IColor, blend_mode:String ):FColor
		{
			return color32( ColorBlend.blendTo32( blend_mode, color1.value, color2.value, color1.alpha, color2.alpha ) );
		}
		
		//--------------------------------------------------------------------------------------------------- Lerp
		
		/**
		 * 2つの色の 中間色 の FColor クラスのインスタンスを生成します.
		 * 
		 * @param	color1	from color
		 * @param	color2	to color
		 * @param	amt		[0.0,1.0]
		 * @see frocessing.color.ColorLerp
		 */
		public static function lerpColorRGB( color1:IFColor, color2:IFColor, amt:Number ):FColor
		{
			return rgb( uint(FMath.lerp( color1.r, color2.r, amt )),
						uint(FMath.lerp( color1.g, color2.g, amt )),
						uint(FMath.lerp( color1.b, color2.b, amt )),
						FMath.lerp( color1.alpha, color2.alpha, amt ) );
		}
		
		/**
		 * 2つの色の 中間色(HSV) の FColor クラスのインスタンスを生成します.
		 * 
		 * @param	color1	from color
		 * @param	color2	to color
		 * @param	amt		[0.0,1.0]
		 * @see frocessing.color.ColorLerp
		 */
		public static function lerpColorHSV( color1:IFColor, color2:IFColor, amt:Number ):FColor
		{
			return hsv( FMath.lerp( color1.h, color2.h, amt ),
						FMath.lerp( color1.s, color2.s, amt ),
						FMath.lerp( color1.v, color2.v, amt ),
						FMath.lerp( color1.alpha, color2.alpha, amt ) );
		}
	}
	
}