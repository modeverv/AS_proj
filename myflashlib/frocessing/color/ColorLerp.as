// --------------------------------------------------------------------------
// Project Frocessing
// ActionScript 3.0 drawing library like Processing.
// --------------------------------------------------------------------------
//
// This library is based on Processing. 
// Copyright (c) 2001-04 Massachusetts Institute of Technology
// Copyright (c) 2004-07 Ben Fry and Casey Reas
// http://processing.org
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
	* 2つの色の 中間色 を取得するメソッドを提供します.
	* 
	* @author nutsu
	* @version 0.1.1
	*/
	public class ColorLerp {
		
		
		/**
		 * 24bit Color (0xRRGGBB) を Lerp します．
		 * 
		 * @param	c1	from color 0xRRGGBB
		 * @param	c2	to color 0xRRGGBB
		 * @param	amt	[0.0,1.0]
		 * @return	0xRRGGBB
		 */
		public static function lerp( c1:uint, c2:uint, amt:Number ):uint
		{
			return lerpRGB( (c1 & 0xff0000) >>> 16, (c1 & 0x00ff00) >>> 8, c1 & 0x0000ff, (c2 & 0xff0000) >>> 16, (c2 & 0x00ff00) >>> 8, c2 & 0x0000ff, amt );	
		}
		
		/**
		 * 32bit Color (0xAARRGGBB) を Lerp します．
		 * 
		 * @param	c1	from color 0xAARRGGBB
		 * @param	c2	to color 0xAARRGGBB
		 * @param	amt	[0.0,1.0]
		 * @return	0xAARRGGBB
		 */
		public static function lerp32( c1:uint, c2:uint, amt:Number ):uint
		{
			return lerpRGBA( (c1 & 0x00ff0000) >>> 16, (c1 & 0x0000ff00) >>> 8, c1 & 0x000000ff, (c2 & 0x00ff0000) >>> 16, (c2 & 0x0000ff00) >>> 8, c2 & 0x000000ff, (c1 & 0xff000000) >>> 24, (c2 & 0xff000000) >>> 24, amt );	
		}
		
		/**
		 * RGB値を指定して Lerp します．
		 * @return 0xRRGGBB
		 */
		public static function lerpRGB( r1:uint, g1:uint, b1:uint, r2:uint, g2:uint, b2:uint, amt:Number ):uint
		{
			return uint(FMath.lerp( r1, r2, amt )) << 16 | uint(FMath.lerp( g1, g2, amt )) << 8 | uint(FMath.lerp( b1, b2, amt ));
		}
		
		/**
		 * RGBA値を指定して Lerp します．
		 * @return 0xAARRGGBB
		 */
		public static function lerpRGBA( r1:uint, g1:uint, b1:uint, r2:uint, g2:uint, b2:uint, a1:uint, a2:uint, amt:Number ):uint
		{
			return uint(FMath.lerp( a1, a2, amt )) << 24 | uint(FMath.lerp( r1, r2, amt )) << 16 | uint(FMath.lerp( g1, g2, amt )) << 8 | uint(FMath.lerp( b1, b2, amt ));
		}
		
		//--------------------------------------------------------------------------------------------------- HSV
		
		/**
		 * 24bit Color (0xRRGGBB) を HSV で Lerp します．
		 * 
		 * @param	c1	from color 0xRRGGBB
		 * @param	c2	to color 0xRRGGBB
		 * @param	amt	[0.0,1.0]
		 * @return	0xRRGGBB
		 */
		public static function lerpInHsv( c1:uint, c2:uint, amt:Number ):uint
		{
			var e1:Object = ColorConvert.UInt2HSV( c1 );
			var e2:Object = ColorConvert.UInt2HSV( c2 );
			return lerpHSV( e1.h, e1.s, e1.v, e2.h, e2.s, e2.v, amt );	
		}
		
		/**
		 * 32bit Color (0xAARRGGBB) を HSV で Lerp します．
		 * 
		 * @param	c1	from color 0xAARRGGBB
		 * @param	c2	to color 0xAARRGGBB
		 * @param	amt	[0.0,1.0]
		 * @return	0xAARRGGBB
		 */
		public static function lerpInHsv32( c1:uint, c2:uint, amt:Number ):uint
		{
			var e1:Object = ColorConvert.UInt2HSV( c1 );
			var e2:Object = ColorConvert.UInt2HSV( c2 );
			return lerpHSVA( e1.h, e1.s, e1.v, e2.h, e2.s, e2.v, (c1 & 0xff000000) >>> 24, (c2 & 0xff000000) >>> 24, amt );	
		}
		
		/**
		 * HSV値を指定して Lerp します．
		 * @return 0xRRGGBB
		 */
		public static function lerpHSV( h1:Number, s1:Number, v1:Number, h2:Number, s2:Number, v2:Number, amt:Number ):uint
		{
			return ColorConvert.HSV2UInt( FMath.lerp( h1, h2, amt ), FMath.lerp( s1, s2, amt ), FMath.lerp( v1, v2, amt ) );
		}
		
		/**
		 * HSVA値を指定して Lerp します．
		 * @return 0xAARRGGBB
		 */
		public static function lerpHSVA( h1:Number, s1:Number, v1:Number, h2:Number, s2:Number, v2:Number, a1:uint, a2:uint, amt:Number ):uint
		{
			return uint(FMath.lerp( a1, a2, amt )) << 24 | ColorConvert.HSV2UInt( FMath.lerp( h1, h2, amt ), FMath.lerp( s1, s2, amt ), FMath.lerp( v1, v2, amt ) );
		}
		
		//--------------------------------------------------------------------------------------------------- GRADIENT
		
		/**
		 * 2つの色のグラデーションの値を Array で取得します. 
		 * 
		 * @example 次のコードは、<code>0xCC6600</code> から <code>0xCC6600</code> の10段階のグラデーション値を取得し描画します.
		 * <listing>
		 * var g:Array = ColorLerp.gradient( 0xCC6600, 0x006699, 10 );
		 * for( var i:int=0; i&lt;g.length; i++ ){
		 * 	graphics.beginFill( g[i] );
		 * 	graphics.drawRect( i~~20, 0, 20, 20 );
		 * 	graphics.endFill(); 
		 * }</listing>
		 * 
		 * @param	c1	from color 0xRRGGBB
		 * @param	c2	to color 0xRRGGBB
		 * @param	step	グラデーションのステップ数
		 * @return	0xRRGGBB[]
		 */
		public static function gradient( c1:uint, c2:uint, step:uint ):Array
		{
			var r1:uint = (c1 & 0xff0000) >>> 16;
			var g1:uint = (c1 & 0x00ff00) >>> 8;
			var b1:uint = c1 & 0x0000ff;
			var r2:uint = (c2 & 0xff0000) >>> 16;
			var g2:uint = (c2 & 0x00ff00) >>> 8;
			var b2:uint = c2 & 0x0000ff;
			
			var grad:Array = [];
			var amt:Number = 1.0 / step;
			grad[0] = c1;
			for ( var i:int = 1; i < step; i++ )
				grad[i] = lerpRGB( r1, g1, b1, r2, g2, b2, i * amt );
			grad[step] = c2;
			
			return grad;
		}
		
		/**
		 * 2つの色の HSV値 のグラデーションの値を Array で取得します. 
		 * 
		 * @example 次のコードは、<code>0xCC6600</code> から <code>0xCC6600</code> の10段階のグラデーション値を取得し描画します.
		 * <listing>
		 * var g:Array = ColorLerp.gradientInHsv( 0xCC6600, 0x006699, 10 );
		 * for( var i:int=0; i&lt;g.length; i++ ){
		 * 	graphics.beginFill( g[i] );
		 * 	graphics.drawRect( i~~20, 0, 20, 20 );
		 * 	graphics.endFill(); 
		 * }</listing>
		 * 
		 * @param	c1	from color 0xRRGGBB
		 * @param	c2	to color 0xRRGGBB
		 * @param	step	グラデーションのステップ数
		 * @return	0xRRGGBB[]
		 */
		public static function gradientInHsv( c1:uint, c2:uint, step:uint ):Array
		{
			var e1:Object = ColorConvert.UInt2HSV( c1 );
			var e2:Object = ColorConvert.UInt2HSV( c2 );
			
			var grad:Array = [];
			var amt:Number = 1.0 / step;
			grad[0] = c1;
			for ( var i:int = 1; i < step; i++ )
				grad[i] = lerpHSV( e1.h, e1.s, e1.v, e2.h, e2.s, e2.v, i * amt );
			grad[step] = c2;
			
			return grad;
		}
	}
	
}