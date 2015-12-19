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
	
	/**
	 * 2つの色をブレンドするメソッドを提供します.
	 * 
	 * <p>ColorBlend クラスにはブレンドを行ういくつかのメソッドを提供しています.</p>
	 * 
	 * <p>オーソドックスなブレンドメソッドは以下のようなものです.</p>
	 * <listing>
	 * import frocessing.color.ColorBlend;
	 * 	
	 * var backcolor  :uint = 0x66CC00;
	 * var forecolor  :uint = 0x33FFCC;
	 * 
	 * var blendcol :Object = ColorBlend.blend( ColorBlend.ADD, backcolor, forecolor );
	 * trace( blendcol.value.toString(16), blendcol.alpha );
	 * //[ 99ffcc 1 ]が出力されます
	 * </listing>
	 * 
	 * <p>24bit Color、またはアルファチャンネルを含む 32bit Color のブレンドを行うメソッドは以下のようになります.</p>
	 * <listing>
	 * import frocessing.color.ColorBlend;
	 * 
	 * var blendcololr :uint;
	 * 
	 * //24bit Color (0xRRGGBB) blend 
	 * blendcololr = ColorBlend.blend24( ColorBlend.ADD, 0x66CC00, 0x33FFCC );
	 * trace( blendcololr.toString(16) );
	 * //[ 99ffcc ]が出力されます
	 * 
	 * //32bit Color (0xAARRGGBB) blend
	 * blendcololr = ColorBlend.blend32( ColorBlend.ADD, 0x3366CC00, 0x6633FFCC );
	 * trace( blendcololr.toString(16) );
	 * //[ 997aff51 ]が出力されます
	 * </listing>
	 * 
	 * <p>各ブレンドメソッドを直接実行する場合は以下のようになります.</p>
	 * <listing>
	 * import frocessing.color.ColorBlend;
	 * 
	 * var blendcololr :uint;
	 * 
	 * //24bit Color (0xRRGGBB) blend 
	 * blendcololr = ColorBlend.add( 0x66CC00, 0x33FFCC );
	 * trace( blendcololr.toString(16) );
	 * //[ 99ffcc ]が出力されます
	 * 
	 * //32bit Color (0xAARRGGBB) blend
	 * blendcololr = ColorBlend.add32( 0x3366CC00, 0x6633FFCC );
	 * trace( blendcololr.toString(16) );
	 * //[ 997aff51 ]が出力されます
	 * </listing>
	 * 
	 * <p>各ブレンドメソッドには、RGB値、アルファ値を個別に指定するメソッドもあります.</p>
	 * <listing>
	 * import frocessing.color.ColorBlend;
	 * 
	 * var blendcololr :uint;
	 * 
	 * blendcololr = ColorBlend.addRGB( 0x66, 0xCC, 0x00, 0x33, 0xFF, 0xCC );
	 * trace( blendcololr.toString(16) );
	 * //[ 99ffcc ]が出力されます
	 * 
	 * //アルファチャンネル有り.アルファ値は 0～255で指定します
	 * blendcololr = ColorBlend.addRGBA( 0x66, 0xCC, 0x00, 0x33, 0xFF, 0xCC, 0x33, 0x66 );
	 * trace( blendcololr.toString(16) );
	 * //[ 997aff51 ]が出力されます
	 * </listing>
	 * 
	 * @author nutsu
	 * @version 0.1
	 */
	public class ColorBlend {
		
		//加算
		public static const ADD         :String	= "add";
		//除算
		public static const SUBTRACT    :String = "subtract";
		//比較(暗）
		public static const DARKEN      :String = "darken";
		//比較(明)
		public static const LIGHTEN     :String = "lighten";
		//差の絶対値
		public static const DIFFERENCE  :String = "difference"
		//乗算
		public static const MULTIPLY    :String = "multiply";
		//スクリーン
		public static const SCREEN      :String = "screen";
		//オーバーレイ
		public static const OVERLAY     :String = "overlay";
		//ハードライト
		public static const HARDLIGHT   :String = "hardlight";
		//ソフトライト
		public static const SOFTLIGHT   :String = "softlight";
		//覆い焼き
		public static const DODGE       :String = "dodge";
		//焼き込み
		public static const BURN        :String	= "burn";
		//除外
		public static const EXCLUSION   :String = "exclusion";
		
		/*
		public function ColorBlend() {
			throw new Error("インスタンスはつくっても意味ないです");
		}
		*/
		
		/**
		 * 2つの色を指定されたブレンドモードでブレンドし、結果を Object で返します.
		 * 
		 * <p>ブレンドモードは以下のモードから指定します．</p>
		 * <ul>
		 * <li>ColorBlend.Add : 加算</li>
		 * <li>ColorBlend.SUBTRACT : 除算</li>
		 * <li>ColorBlend.DARKEN : 比較(暗）</li>
		 * <li>ColorBlend.LIGHTEN : 比較(明)</li>
		 * <li>ColorBlend.DIFFERENCE : 差の絶対値</li>
		 * <li>ColorBlend.MULTIPLY : 乗算</li>
		 * <li>ColorBlend.SCREEN : スクリーン</li>
		 * <li>ColorBlend.OVERLAY : オーバーレイ</li>
		 * <li>ColorBlend.HARDLIGHT : ハードライト</li>
		 * <li>ColorBlend.SOFTLIGHT : ソフトライト</li>
		 * <li>ColorBlend.DODGE : 覆い焼き</li>
		 * <li>ColorBlend.BURN : 焼き込み</li>
		 * <li>ColorBlend.EXCLUSION : 除外</li>
		 * </ul>
		 * 
		 * @param	blendkind	blend mode
		 * @param	c1	backcolor 0xRRGGBB
		 * @param	c2	forecolor 0xRRGGBB
		 * @param	a1	alpha of backcolor [0,1]
		 * @param	a2	alpha of forecolor [0,1]
		 * @return	{ value:0xRRGGBB, alpha:Number }
		 */
		public static function blend( blendkind:String, c1:uint, c2:uint, a1:Number=NaN, a2:Number=NaN ):Object
		{
			if ( (isNaN(a1) && isNaN(a2)) || ( a1==1.0 && a2==1.0 ) )
			{
				return { value:blend24( blendkind, c1, c2 ), alpha:1.0 };
			}
			else
			{
				var c:uint = blend32( blendkind, _to32(c1, a1), _to32(c2, a2) );
				return { value: c & 0x00ffffff , alpha: ( c >>> 24 ) / 0xff };
			}
		}
		
		/**
		 * 2つの色を指定されたブレンドモードでブレンドし、結果を 32bit Color (0xAARRGGBB) で返します.
		 * 
		 * <p>ブレンドモードは以下のモードから指定します．</p>
		 * <ul>
		 * <li>ColorBlend.Add : 加算</li>
		 * <li>ColorBlend.SUBTRACT : 除算</li>
		 * <li>ColorBlend.DARKEN : 比較(暗）</li>
		 * <li>ColorBlend.LIGHTEN : 比較(明)</li>
		 * <li>ColorBlend.DIFFERENCE : 差の絶対値</li>
		 * <li>ColorBlend.MULTIPLY : 乗算</li>
		 * <li>ColorBlend.SCREEN : スクリーン</li>
		 * <li>ColorBlend.OVERLAY : オーバーレイ</li>
		 * <li>ColorBlend.HARDLIGHT : ハードライト</li>
		 * <li>ColorBlend.SOFTLIGHT : ソフトライト</li>
		 * <li>ColorBlend.DODGE : 覆い焼き</li>
		 * <li>ColorBlend.BURN : 焼き込み</li>
		 * <li>ColorBlend.EXCLUSION : 除外</li>
		 * </ul>
		 * 
		 * @param	blendkind	blend mode
		 * @param	c1	backcolor 0xRRGGBB
		 * @param	c2	forecolor 0xRRGGBB
		 * @param	a1	alpha of backcolor [0,1]
		 * @param	a2	alpha of forecolor [0,1]
		 * @return	0xAARRGGBB
		 */
		public static function blendTo32( blendkind:String, c1:uint, c2:uint, a1:Number=NaN, a2:Number=NaN ):uint
		{
			if ( isNaN(a1) && isNaN(a2 ) || ( a1==1.0 && a2==1.0 )  )
				return 0xff000000 | blend24( blendkind, c1, c2 );
			else
				return blend32( blendkind, _to32(c1, a1), _to32(c2, a2) );
		}
		
		/**
		 * 2つの 24bit Color(0xRRGGBB) を指定されたブレンドモードでブレンドします.
		 * 
		 * <p>ブレンドモードは以下のモードから指定します．</p>
		 * <ul>
		 * <li>ColorBlend.Add : 加算</li>
		 * <li>ColorBlend.SUBTRACT : 除算</li>
		 * <li>ColorBlend.DARKEN : 比較(暗）</li>
		 * <li>ColorBlend.LIGHTEN : 比較(明)</li>
		 * <li>ColorBlend.DIFFERENCE : 差の絶対値</li>
		 * <li>ColorBlend.MULTIPLY : 乗算</li>
		 * <li>ColorBlend.SCREEN : スクリーン</li>
		 * <li>ColorBlend.OVERLAY : オーバーレイ</li>
		 * <li>ColorBlend.HARDLIGHT : ハードライト</li>
		 * <li>ColorBlend.SOFTLIGHT : ソフトライト</li>
		 * <li>ColorBlend.DODGE : 覆い焼き</li>
		 * <li>ColorBlend.BURN : 焼き込み</li>
		 * <li>ColorBlend.EXCLUSION : 除外</li>
		 * </ul>
		 * 
		 * @param	blendkind	blend mode
		 * @param	c1	backcolor 0xRRGGBB
		 * @param	c2	forecolor 0xRRGGBB
		 * @return	0xRRGGBB
		 */
		public static function blend24( blendkind:String, c1:uint, c2:uint ):uint
		{
			switch( blendkind )
			{
				case ADD: 			return add( c1, c2 );
				case SUBTRACT: 		return sub( c1, c2 );
				case DARKEN: 		return dark( c1, c2 );
				case LIGHTEN: 		return light( c1, c2 );
				case DIFFERENCE: 	return diff( c1, c2 );
				case MULTIPLY: 		return multi( c1, c2 );
				case SCREEN: 		return screen( c1, c2 );
				case OVERLAY: 		return overlay( c1, c2 );
				case HARDLIGHT: 	return hard( c1, c2 );
				case SOFTLIGHT: 	return soft( c1, c2 );
				case DODGE: 		return dodge( c1, c2 );
				case BURN: 			return burn( c1, c2 );
				case EXCLUSION:		return excl( c1, c2 );
				default:			return c2;
			}
		}
		
		/**
		 * 2つの 32bit Color(0xAARRGGBB) を指定されたブレンドモードでブレンドします.
		 * 
		 * <p>ブレンドモードは以下のモードから指定します．</p>
		 * <ul>
		 * <li>ColorBlend.Add : 加算</li>
		 * <li>ColorBlend.SUBTRACT : 除算</li>
		 * <li>ColorBlend.DARKEN : 比較(暗）</li>
		 * <li>ColorBlend.LIGHTEN : 比較(明)</li>
		 * <li>ColorBlend.DIFFERENCE : 差の絶対値</li>
		 * <li>ColorBlend.MULTIPLY : 乗算</li>
		 * <li>ColorBlend.SCREEN : スクリーン</li>
		 * <li>ColorBlend.OVERLAY : オーバーレイ</li>
		 * <li>ColorBlend.HARDLIGHT : ハードライト</li>
		 * <li>ColorBlend.SOFTLIGHT : ソフトライト</li>
		 * <li>ColorBlend.DODGE : 覆い焼き</li>
		 * <li>ColorBlend.BURN : 焼き込み</li>
		 * <li>ColorBlend.EXCLUSION : 除外</li>
		 * </ul>
		 * 
		 * @param	blendkind	blend mode
		 * @param	c1	backcolor 0xAARRGGBB
		 * @param	c2	forecolor 0xAARRGGBB
		 * @return	0xAARRGGBB
		 */
		public static function blend32( blendkind:String, c1:uint, c2:uint ):uint
		{
			switch( blendkind )
			{
				case ADD: 			return add32( c1, c2 );
				case SUBTRACT: 		return sub32( c1, c2 );
				case DARKEN: 		return dark32( c1, c2 );
				case LIGHTEN: 		return light32( c1, c2 );
				case DIFFERENCE: 	return diff32( c1, c2 );
				case MULTIPLY: 		return multi32( c1, c2 );
				case SCREEN: 		return screen32( c1, c2 );
				case OVERLAY: 		return overlay32( c1, c2 );
				case HARDLIGHT: 	return hard32( c1, c2 );
				case SOFTLIGHT: 	return soft32( c1, c2 );
				case DODGE: 		return dodge32( c1, c2 );
				case BURN: 			return burn32( c1, c2 );
				case EXCLUSION:		return excl32( c1, c2 );
				default:			return c2;
			}
		}
		
		//---------------------------------------------------------------------------------------------------BLEND PRC
		/**
		 * 24bit Color (0xRRGGBB) を 加算(ADD) でブレンドします．
		 * @param	c1	backcolor 0xRRGGBB
		 * @param	c2	forecolor 0xRRGGBB
		 * @return	0xRRGGBB
		 */
		public static function add( c1:uint, c2:uint ):uint
		{
			return addRGB( (c1 & 0xff0000) >>> 16, (c1 & 0x00ff00) >>> 8, c1 & 0x0000ff, (c2 & 0xff0000) >>> 16, (c2 & 0x00ff00) >>> 8, c2 & 0x0000ff );	
		}
		/**
		 * RGB値を指定して 加算(ADD) でブレンドします．
		 * @return 0xRRGGBB
		 */
		public static function addRGB( r1:uint, g1:uint, b1:uint, r2:uint, g2:uint, b2:uint ):uint
		{
			return Math.min( r1 + r2, 0xff ) << 16 | Math.min( g1 + g2, 0xff ) << 8 | Math.min( b1 + b2, 0xff );
		}
		/**
		 * 32bit Color (0xAARRGGBB) を 加算(ADD) でブレンドします．
		 * @param	c1	backcolor 0xAARRGGBB
		 * @param	c2	forecolor 0xAARRGGBB
		 * @return	0xAARRGGBB
		 */
		public static function add32( c1:uint, c2:uint ):uint
		{
			return addRGBA( (c1 & 0x00ff0000) >>> 16, (c1 & 0x0000ff00) >>> 8, c1 & 0x000000ff, (c2 & 0x00ff0000) >>> 16, (c2 & 0x0000ff00) >>> 8, c2 & 0x000000ff, (c1 & 0xff000000) >>> 24, (c2 & 0xff000000) >>> 24 );
		}
		/**
		 * RGBA値を指定して 加算(ADD) でブレンドします．
		 * @return 0xAARRGGBB
		 */
		public static function addRGBA( r1:uint, g1:uint, b1:uint, r2:uint, g2:uint, b2:uint, a1:uint=0xff, a2:uint=0xff ):uint
		{
			return Math.min( a1 + a2, 0xff ) << 24 | Math.min( r1 + (r2*a2>>8) , 0xff ) << 16 | Math.min( g1 + (g2*a2>>8), 0xff ) << 8 | Math.min( b1 + (b2*a2>>8), 0xff );
		}
		
		//-------------------------------
		/**
		 * 24bit Color (0xRRGGBB) を 減算(SUBTRACT) でブレンドします．
		 * @param	c1	backcolor 0xRRGGBB
		 * @param	c2	forecolor 0xRRGGBB
		 * @return	0xRRGGBB
		 */
		public static function sub( c1:uint, c2:uint ):uint
		{
			return subRGB( (c1 & 0xff0000)>>>16, (c1 & 0x00ff00)>>>8, c1 & 0x0000ff, (c2 & 0xff0000)>>>16, (c2 & 0x00ff00)>>>8, c2 & 0x0000ff );
		}
		/**
		 * RGB値を指定して 減算(SUBTRACT) でブレンドします．
		 * @return 0xRRGGBB
		 */
		public static function subRGB( r1:uint, g1:uint, b1:uint, r2:uint, g2:uint, b2:uint ):uint
		{
			return Math.max( r1 - r2, 0 ) << 16 | Math.max( g1 - g2, 0 ) << 8 | Math.max( b1 - b2, 0 );
		}
		/**
		 * 32bit Color (0xAARRGGBB) を 減算(SUBTRACT) でブレンドします．
		 * @param	c1	backcolor 0xAARRGGBB
		 * @param	c2	forecolor 0xAARRGGBB
		 * @return	0xAARRGGBB
		 */
		public static function sub32( c1:uint, c2:uint ):uint
		{
			return subRGBA( (c1 & 0x00ff0000) >>> 16, (c1 & 0x0000ff00) >>> 8, c1 & 0x000000ff, (c2 & 0x00ff0000) >>> 16, (c2 & 0x0000ff00) >>> 8, c2 & 0x000000ff, (c1 & 0xff000000) >>> 24, (c2 & 0xff000000) >>> 24 );
		}
		/**
		 * RGBA値を指定して 減算(SUBTRACT) でブレンドします．
		 * @return 0xAARRGGBB
		 */
		public static function subRGBA( r1:uint, g1:uint, b1:uint, r2:uint, g2:uint, b2:uint, a1:uint=0xff, a2:uint=0xff ):uint
		{
			return Math.min( a1 + a2, 0xff ) << 24 | Math.max( r1 - (r2*a2>>8) , 0 ) << 16 | Math.max( g1 - (g2*a2>>8), 0 ) << 8 | Math.max( b1 - (b2*a2>>8), 0 );
		}
		
		//-------------------------------
		/**
		 * 24bit Color (0xRRGGBB) を 比較暗(DARKEN) でブレンドします．
		 * @param	c1	backcolor 0xRRGGBB
		 * @param	c2	forecolor 0xRRGGBB
		 * @return	0xRRGGBB
		 */
		public static function dark( c1:uint, c2:uint ):uint
		{
			return darkRGB( (c1 & 0xff0000)>>>16, (c1 & 0x00ff00)>>>8, c1 & 0x0000ff, (c2 & 0xff0000)>>>16, (c2 & 0x00ff00)>>>8, c2 & 0x0000ff );
		}
		/**
		 * RGB値を指定して 比較暗(DARKEN) でブレンドします．
		 * @return 0xRRGGBB
		 */
		public static function darkRGB( r1:uint, g1:uint, b1:uint, r2:uint, g2:uint, b2:uint ):uint
		{
			return Math.min( r1, r2 ) << 16 | Math.min( g1, g2 ) << 8 | Math.min( b1, b2 );
		}
		/**
		 * 32bit Color (0xAARRGGBB) を 比較暗(DARKEN) でブレンドします．
		 * @param	c1	backcolor 0xAARRGGBB
		 * @param	c2	forecolor 0xAARRGGBB
		 * @return	0xAARRGGBB
		 */
		public static function dark32( c1:uint, c2:uint ):uint
		{
			return darkRGBA( (c1 & 0x00ff0000) >>> 16, (c1 & 0x0000ff00) >>> 8, c1 & 0x000000ff, (c2 & 0x00ff0000) >>> 16, (c2 & 0x0000ff00) >>> 8, c2 & 0x000000ff, (c1 & 0xff000000) >>> 24, (c2 & 0xff000000) >>> 24 );
		}
		/**
		 * RGBA値を指定して 比較暗(DARKEN) でブレンドします．
		 * @return 0xAARRGGBB
		 */
		public static function darkRGBA( r1:uint, g1:uint, b1:uint, r2:uint, g2:uint, b2:uint, a1:uint=0xff, a2:uint=0xff ):uint
		{
			return Math.min( a1 + a2, 0xff ) << 24 | _dark32(r1,r2,a2) << 16 | _dark32(g1,g2,a2) << 8 | _dark32(b1,b2,a2);
		}
		/**
		 * @private
		 */
		private static function _dark32( e1:uint, e2:uint, a2:uint ):uint
		{
			return (e1*(a2^0xff)>>8) + (Math.min(e1,(e2*a2>>8))*a2>>8);
		}
		
		//-------------------------------
		/**
		 * 24bit Color (0xRRGGBB) を 比較明(LIGHTEN) でブレンドします．
		 * @param	c1	backcolor 0xRRGGBB
		 * @param	c2	forecolor 0xRRGGBB
		 * @return	0xRRGGBB
		 */
		public static function light( c1:uint, c2:uint ):uint
		{
			return lightRGB( (c1 & 0xff0000)>>>16, (c1 & 0x00ff00)>>>8, c1 & 0x0000ff, (c2 & 0xff0000)>>>16, (c2 & 0x00ff00)>>>8, c2 & 0x0000ff );
		}
		/**
		 * RGB値を指定して 比較明(LIGHTEN) でブレンドします．
		 * @return 0xRRGGBB
		 */
		public static function lightRGB( r1:uint, g1:uint, b1:uint, r2:uint, g2:uint, b2:uint ):uint
		{
			return Math.max( r1, r2 ) << 16 | Math.max( g1, g2 ) << 8 | Math.max( b1, b2 );
		}
		/**
		 * 32bit Color (0xAARRGGBB) を 比較明(LIGHTEN) でブレンドします．
		 * @param	c1	backcolor 0xAARRGGBB
		 * @param	c2	forecolor 0xAARRGGBB
		 * @return	0xAARRGGBB
		 */
		public static function light32( c1:uint, c2:uint ):uint
		{
			return lightRGBA( (c1 & 0x00ff0000) >>> 16, (c1 & 0x0000ff00) >>> 8, c1 & 0x000000ff, (c2 & 0x00ff0000) >>> 16, (c2 & 0x0000ff00) >>> 8, c2 & 0x000000ff, (c1 & 0xff000000) >>> 24, (c2 & 0xff000000) >>> 24 );
		}
		/**
		 * RGBA値を指定して 比較明(LIGHTEN) でブレンドします．
		 * @return 0xAARRGGBB
		 */
		public static function lightRGBA( r1:uint, g1:uint, b1:uint, r2:uint, g2:uint, b2:uint, a1:uint=0xff, a2:uint=0xff ):uint
		{
			return Math.min( a1 + a2, 0xff ) << 24 | _light32(r1,r2,a2) << 16 | _light32(g1,g2,a2) << 8 | _light32(b1,b2,a2);
		}
		/**
		 * @private
		 */
		private static function _light32( e1:uint, e2:uint, a2:uint ):uint
		{
			return  Math.max( e1, (e2*a2>>8) );
		}
		//-------------------------------
		/**
		 * 24bit Color (0xRRGGBB) を 差の絶対値(DIFFERENCE) でブレンドします．
		 * @param	c1	backcolor 0xRRGGBB
		 * @param	c2	forecolor 0xRRGGBB
		 * @return	0xRRGGBB
		 */
		public static function diff( c1:uint, c2:uint ):uint
		{
			return diffRGB( (c1 & 0xff0000)>>>16, (c1 & 0x00ff00)>>>8, c1 & 0x0000ff, (c2 & 0xff0000)>>>16, (c2 & 0x00ff00)>>>8, c2 & 0x0000ff );
		}
		/**
		 * RGB値を指定して 差の絶対値(DIFFERENCE) でブレンドします．
		 * @return 0xRRGGBB
		 */
		public static function diffRGB( r1:uint, g1:uint, b1:uint, r2:uint, g2:uint, b2:uint ):uint
		{
			return Math.abs( r1-r2 ) << 16 | Math.abs( g1-g2 ) << 8 | Math.abs( b1-b2 );
		}
		/**
		 * 32bit Color (0xAARRGGBB) を 差の絶対値(DIFFERENCE) でブレンドします．
		 * @param	c1	backcolor 0xAARRGGBB
		 * @param	c2	forecolor 0xAARRGGBB
		 * @return	0xAARRGGBB
		 */
		public static function diff32( c1:uint, c2:uint ):uint
		{
			return diffRGBA( (c1 & 0x00ff0000) >>> 16, (c1 & 0x0000ff00) >>> 8, c1 & 0x000000ff, (c2 & 0x00ff0000) >>> 16, (c2 & 0x0000ff00) >>> 8, c2 & 0x000000ff, (c1 & 0xff000000) >>> 24, (c2 & 0xff000000) >>> 24 );
		}
		/**
		 * RGBA値を指定して 差の絶対値(DIFFERENCE) でブレンドします．
		 * @return 0xAARRGGBB
		 */
		public static function diffRGBA( r1:uint, g1:uint, b1:uint, r2:uint, g2:uint, b2:uint, a1:uint=0xff, a2:uint=0xff ):uint
		{
			return Math.min( a1 + a2, 0xff ) << 24 | _diff32(r1,r2,a2) << 16 | _diff32(g1,g2,a2) << 8 | _diff32(b1,b2,a2);
		}
		/**
		 * @private
		 */
		private static function _diff32( e1:uint, e2:uint, a2:uint ):uint
		{
			return (e1*(a2^0xff)>>8) + (Math.abs(e1 - e2)*a2>>8);
		}
		
		//-------------------------------
		/**
		 * 24bit Color (0xRRGGBB) を 乗算(MULTIPLY) でブレンドします．
		 * @param	c1	backcolor 0xRRGGBB
		 * @param	c2	forecolor 0xRRGGBB
		 * @return	0xRRGGBB
		 */
		public static function multi( c1:uint, c2:uint ):uint
		{
			return multiRGB( (c1 & 0xff0000)>>>16, (c1 & 0x00ff00)>>>8, c1 & 0x0000ff, (c2 & 0xff0000)>>>16, (c2 & 0x00ff00)>>>8, c2 & 0x0000ff );
		}
		/**
		 * RGB値を指定して 乗算(MULTIPLY) でブレンドします．
		 * @return 0xRRGGBB
		 */
		public static function multiRGB( r1:uint, g1:uint, b1:uint, r2:uint, g2:uint, b2:uint ):uint
		{
			return ( r1*r2>>8 ) << 16 | ( g1*g2>>8 ) << 8 | b1*b2>>8;
		}
		/**
		 * 32bit Color (0xAARRGGBB) を 乗算(MULTIPLY) でブレンドします．
		 * @param	c1	backcolor 0xAARRGGBB
		 * @param	c2	forecolor 0xAARRGGBB
		 * @return	0xAARRGGBB
		 */
		public static function multi32( c1:uint, c2:uint ):uint
		{
			return multiRGBA( (c1 & 0x00ff0000) >>> 16, (c1 & 0x0000ff00) >>> 8, c1 & 0x000000ff, (c2 & 0x00ff0000) >>> 16, (c2 & 0x0000ff00) >>> 8, c2 & 0x000000ff, (c1 & 0xff000000) >>> 24, (c2 & 0xff000000) >>> 24 );
		}
		/**
		 * RGBA値を指定して 乗算(MULTIPLY) でブレンドします．
		 * @return 0xAARRGGBB
		 */
		public static function multiRGBA( r1:uint, g1:uint, b1:uint, r2:uint, g2:uint, b2:uint, a1:uint=0xff, a2:uint=0xff ):uint
		{
			return Math.min( a1 + a2, 0xff ) << 24 | _multi32(r1,r2,a2) << 16 | _multi32(g1,g2,a2) << 8 | _multi32(b1,b2,a2);
		}
		/**
		 * @private
		 */
		private static function _multi32( e1:uint, e2:uint, a2:uint ):uint
		{
			return (e1*(a2^0xff)>>8) + (e1*e2*a2>>16);
		}
		
		//-------------------------------
		/**
		 * 24bit Color (0xRRGGBB) を スクリーン(SCREEN) でブレンドします．
		 * @param	c1	backcolor 0xRRGGBB
		 * @param	c2	forecolor 0xRRGGBB
		 * @return	0xRRGGBB
		 */
		public static function screen( c1:uint, c2:uint ):uint
		{
			return multi( c1 ^ 0xffffff, c2 ^ 0xffffff ) ^ 0xffffff;
		}
		/**
		 * RGB値を指定して スクリーン(SCREEN) でブレンドします．
		 * @return 0xRRGGBB
		 */
		public static function screenRGB( r1:uint, g1:uint, b1:uint, r2:uint, g2:uint, b2:uint ):uint
		{
			return multiRGB( r1^0xff, g1^0xff, b1^0xff, r2^0xff, g2^0xff, b2^0xff )^0xffffff;
		}
		/**
		 * 32bit Color (0xAARRGGBB) を スクリーン(SCREEN) でブレンドします．
		 * @param	c1	backcolor 0xAARRGGBB
		 * @param	c2	forecolor 0xAARRGGBB
		 * @return	0xAARRGGBB
		 */
		public static function screen32( c1:uint, c2:uint ):uint
		{
			return screenRGBA( (c1 & 0x00ff0000) >>> 16, (c1 & 0x0000ff00) >>> 8, c1 & 0x000000ff, (c2 & 0x00ff0000) >>> 16, (c2 & 0x0000ff00) >>> 8, c2 & 0x000000ff, (c1 & 0xff000000) >>> 24, (c2 & 0xff000000) >>> 24 );
		}
		/**
		 * RGBA値を指定して スクリーン(SCREEN) でブレンドします．
		 * @return 0xAARRGGBB
		 */
		public static function screenRGBA( r1:uint, g1:uint, b1:uint, r2:uint, g2:uint, b2:uint, a1:uint=0xff, a2:uint=0xff ):uint
		{
			return Math.min( a1 + a2, 0xff ) << 24 | multiRGB( r1^0xff, g1^0xff, b1^0xff, (r2*a2>>8)^0xff, (g2*a2>>8)^0xff, (b2*a2>>8)^0xff )^0xffffff;
		}
		
		//-------------------------------
		/**
		 * 24bit Color (0xRRGGBB) を オーバーレイ(OVERLAY) でブレンドします．
		 * @param	c1	backcolor 0xRRGGBB
		 * @param	c2	forecolor 0xRRGGBB
		 * @return	0xRRGGBB
		 */
		public static function overlay( c1:uint, c2:uint ):uint
		{
			return overlayRGB( (c1 & 0xff0000)>>>16, (c1 & 0x00ff00)>>>8, c1 & 0x0000ff, (c2 & 0xff0000)>>>16, (c2 & 0x00ff00)>>>8, c2 & 0x0000ff );
		}
		/**
		 * RGB値を指定して オーバーレイ(OVERLAY) でブレンドします．
		 * @return 0xRRGGBB
		 */
		public static function overlayRGB( r1:uint, g1:uint, b1:uint, r2:uint, g2:uint, b2:uint ):uint
		{
			return _overlay(r1,r2)<<16 | _overlay(g1,g2)<<8 | _overlay(b1,b2);
		}
		/**
		 * @private
		 */
		private static function _overlay( e1:uint, e2:uint ):uint
		{
			return ( e1 < 0x80 ) ? e1*e2>>7 : ((e1^0xff)*(e2^0xff)>>7)^0xff;
		}
		/**
		 * 32bit Color (0xAARRGGBB) を オーバーレイ(OVERLAY) でブレンドします．
		 * @param	c1	backcolor 0xAARRGGBB
		 * @param	c2	forecolor 0xAARRGGBB
		 * @return	0xAARRGGBB
		 */
		public static function overlay32( c1:uint, c2:uint ):uint
		{
			return overlayRGBA( (c1 & 0x00ff0000) >>> 16, (c1 & 0x0000ff00) >>> 8, c1 & 0x000000ff, (c2 & 0x00ff0000) >>> 16, (c2 & 0x0000ff00) >>> 8, c2 & 0x000000ff, (c1 & 0xff000000) >>> 24, (c2 & 0xff000000) >>> 24 );
		}
		/**
		 * RGBA値を指定して オーバーレイ(OVERLAY) でブレンドします．
		 * @return 0xAARRGGBB
		 */
		public static function overlayRGBA( r1:uint, g1:uint, b1:uint, r2:uint, g2:uint, b2:uint, a1:uint=0xff, a2:uint=0xff ):uint
		{
			return Math.min( a1 + a2, 0xff ) << 24 | _overlay32(r1,r2,a2) << 16 | _overlay32(g1,g2,a2) << 8 | _overlay32(b1,b2,a2);
		}
		/**
		 * @private
		 */
		private static function _overlay32( e1:uint, e2:uint, a2:uint ):uint
		{
			return (e1*(a2^0xff)>>8) + ( ( e1 < 0x80 ) ? e1*e2*a2>>15 : (((e1^0xff)*(e2^0xff)>>7)^0xff)*a2>>8 );
		}
		
		//-------------------------------
		/**
		 * 24bit Color (0xRRGGBB) を ハードライト(HARDLIGHT) でブレンドします．
		 * @param	c1	backcolor 0xRRGGBB
		 * @param	c2	forecolor 0xRRGGBB
		 * @return	0xRRGGBB
		 */
		public static function hard( c1:uint, c2:uint ):uint
		{
			return hardRGB( (c1 & 0xff0000)>>>16, (c1 & 0x00ff00)>>>8, c1 & 0x0000ff, (c2 & 0xff0000)>>>16, (c2 & 0x00ff00)>>>8, c2 & 0x0000ff );
		}
		/**
		 * RGB値を指定して ハードライト(HARDLIGHT) でブレンドします．
		 * @return 0xRRGGBB
		 */
		public static function hardRGB( r1:uint, g1:uint, b1:uint, r2:uint, g2:uint, b2:uint ):uint
		{
			return _hard(r1,r2)<<16 | _hard(g1,g2)<<8 | _hard(b1,b2);
		}
		/**
		 * @private
		 */
		private static function _hard( e1:uint, e2:uint ):uint
		{
			return ( e2 < 0x80 ) ? e1*e2>>7 : ((e1^0xff)*(e2^0xff)>>7)^0xff;
		}
		/**
		 * 32bit Color (0xAARRGGBB) を ハードライト(HARDLIGHT) でブレンドします．
		 * @param	c1	backcolor 0xAARRGGBB
		 * @param	c2	forecolor 0xAARRGGBB
		 * @return	0xAARRGGBB
		 */
		public static function hard32( c1:uint, c2:uint ):uint
		{
			return hardRGBA( (c1 & 0x00ff0000) >>> 16, (c1 & 0x0000ff00) >>> 8, c1 & 0x000000ff, (c2 & 0x00ff0000) >>> 16, (c2 & 0x0000ff00) >>> 8, c2 & 0x000000ff, (c1 & 0xff000000) >>> 24, (c2 & 0xff000000) >>> 24 );
		}
		/**
		 * RGBA値を指定して ハードライト(HARDLIGHT) でブレンドします．
		 * @return 0xAARRGGBB
		 */
		public static function hardRGBA( r1:uint, g1:uint, b1:uint, r2:uint, g2:uint, b2:uint, a1:uint=0xff, a2:uint=0xff ):uint
		{
			return Math.min( a1 + a2, 0xff ) << 24 | _hard32(r1,r2,a2)<<16 | _hard32(g1,g2,a2)<<8 | _hard32(b1,b2,a2);
		}
		/**
		 * @private
		 */
		private static function _hard32( e1:uint, e2:uint, a2:uint ):uint
		{
			return (e1*(a2^0xff)>>8) + ( ( e2 < 0x80 ) ? e1*e2*a2>>15 : (((e1^0xff)*(e2^0xff)>>7)^0xff)*a2>>8 );
		}
		
		//-------------------------------
		/**
		 * 24bit Color (0xRRGGBB) を ソフトライト(SOFTLIGHT) でブレンドします．
		 * @param	c1	backcolor 0xRRGGBB
		 * @param	c2	forecolor 0xRRGGBB
		 * @return	0xRRGGBB
		 */
		public static function soft( c1:uint, c2:uint ):uint
		{
			return softRGB( (c1 & 0xff0000)>>>16, (c1 & 0x00ff00)>>>8, c1 & 0x0000ff, (c2 & 0xff0000)>>>16, (c2 & 0x00ff00)>>>8, c2 & 0x0000ff );
		}
		/**
		 * RGB値を指定して ソフトライト(SOFTLIGHT) でブレンドします．
		 * @return 0xRRGGBB
		 */
		public static function softRGB( r1:uint, g1:uint, b1:uint, r2:uint, g2:uint, b2:uint ):uint
		{
			return _soft(r1,r2)<<16 | _soft(g1,g2)<<8 | _soft(b1,b2);
		}
		/**
		 * @private
		 */
		private static function _soft( e1:uint, e2:uint ):uint
		{
			return ( e1 * e2 + e1 * ( 0xff - ((e1 ^ 0xff) * (e2 ^ 0xff) >> 8) - (e1 * e2 >> 8) )) >> 8;
		}
		
		/**
		 * 32bit Color (0xAARRGGBB) を ソフトライト(SOFTLIGHT) でブレンドします．
		 * @param	c1	backcolor 0xAARRGGBB
		 * @param	c2	forecolor 0xAARRGGBB
		 * @return	0xAARRGGBB
		 */
		public static function soft32( c1:uint, c2:uint ):uint
		{
			return softRGBA( (c1 & 0x00ff0000) >>> 16, (c1 & 0x0000ff00) >>> 8, c1 & 0x000000ff, (c2 & 0x00ff0000) >>> 16, (c2 & 0x0000ff00) >>> 8, c2 & 0x000000ff, (c1 & 0xff000000) >>> 24, (c2 & 0xff000000) >>> 24 );
		}
		/**
		 * RGBA値を指定して ソフトライト(SOFTLIGHT) でブレンドします．
		 * @return 0xAARRGGBB
		 */
		public static function softRGBA( r1:uint, g1:uint, b1:uint, r2:uint, g2:uint, b2:uint, a1:uint=0xff, a2:uint=0xff ):uint
		{
			return Math.min( a1 + a2, 0xff ) << 24 | _soft32(r1,r2,a2)<<16 | _soft32(g1,g2,a2)<<8 | _soft32(b1,b2,a2);
		}
		/**
		 * @private
		 */
		private static function _soft32( e1:uint, e2:uint, a2:uint ):uint
		{
			return (e1*(a2^0xff)>>8) + (( e1*e2 + e1*( 0xff - ((e1^0xff)*(e2^0xff)>>8) - (e1*e2>>8) ))*a2>>16);
		}
		
		//-------------------------------
		/**
		 * 24bit Color (0xRRGGBB) を 覆い焼き(DODGE) でブレンドします．
		 * @param	c1	backcolor 0xRRGGBB
		 * @param	c2	forecolor 0xRRGGBB
		 * @return	0xRRGGBB
		 */
		public static function dodge( c1:uint, c2:uint ):uint
		{
			return dodgeRGB( (c1 & 0xff0000)>>>16, (c1 & 0x00ff00)>>>8, c1 & 0x0000ff, (c2 & 0xff0000)>>>16, (c2 & 0x00ff00)>>>8, c2 & 0x0000ff );
		}
		/**
		 * RGB値を指定して 覆い焼き(DODGE) でブレンドします．
		 * @return 0xRRGGBB
		 */
		public static function dodgeRGB( r1:uint, g1:uint, b1:uint, r2:uint, g2:uint, b2:uint ):uint
		{
			return _dodge(r1,r2)<<16 | _dodge(g1,g2)<<8 | _dodge(b1,b2);
		}
		/**
		 * @private
		 */
		private static function _dodge( e1:uint, e2:uint ):uint
		{
			var x:uint;
			if ( e2 == 0xff || ( x = Math.floor( e1*0xff/(e2^0xff)) ) > 0xff )
				return 0xff;
			else
				return x;
		}
		/**
		 * 32bit Color (0xAARRGGBB) を 覆い焼き(DODGE) でブレンドします．
		 * @param	c1	backcolor 0xAARRGGBB
		 * @param	c2	forecolor 0xAARRGGBB
		 * @return	0xAARRGGBB
		 */
		public static function dodge32( c1:uint, c2:uint ):uint
		{
			return dodgeRGBA( (c1 & 0x00ff0000) >>> 16, (c1 & 0x0000ff00) >>> 8, c1 & 0x000000ff, (c2 & 0x00ff0000) >>> 16, (c2 & 0x0000ff00) >>> 8, c2 & 0x000000ff, (c1 & 0xff000000) >>> 24, (c2 & 0xff000000) >>> 24 );
		}
		/**
		 * RGBA値を指定して 覆い焼き(DODGE) でブレンドします．
		 * @return 0xAARRGGBB
		 */
		public static function dodgeRGBA( r1:uint, g1:uint, b1:uint, r2:uint, g2:uint, b2:uint, a1:uint=0xff, a2:uint=0xff ):uint
		{
			return Math.min( a1 + a2, 0xff ) << 24 | _dodge32(r1,r2,a2)<<16 | _dodge32(g1,g2,a2)<<8 | _dodge32(b1,b2,a2);
		}
		/**
		 * @private
		 */
		private static function _dodge32( e1:uint, e2:uint, a2:uint ):uint
		{
			var x:uint;
			if ( e2 == 0xff || ( x = Math.floor( e1*0xff/(e2^0xff)) ) > 0xff )
				x = 0xff;
			return (e1*(a2^0xff) + x*a2)>>8;
		}
		
		//-------------------------------
		/**
		 * 24bit Color (0xRRGGBB) を 焼き込み(BURN) でブレンドします．
		 * @param	c1	backcolor 0xRRGGBB
		 * @param	c2	forecolor 0xRRGGBB
		 * @return	0xRRGGBB
		 */
		public static function burn( c1:uint, c2:uint ):uint
		{
			return burnRGB( (c1 & 0xff0000)>>>16, (c1 & 0x00ff00)>>>8, c1 & 0x0000ff, (c2 & 0xff0000)>>>16, (c2 & 0x00ff00)>>>8, c2 & 0x0000ff );
		}
		/**
		 * RGB値を指定して 焼き込み(BURN) でブレンドします．
		 * @return 0xRRGGBB
		 */
		public static function burnRGB( r1:uint, g1:uint, b1:uint, r2:uint, g2:uint, b2:uint ):uint
		{
			return _burn(r1,r2)<<16 | _burn(g1,g2)<<8 | _burn(b1,b2);
		}
		/**
		 * @private
		 */
		private static function _burn( e1:uint, e2:uint ):uint
		{
			var x:uint;
			if ( e2 == 0 || (x = 0xff - Math.floor( (e1^0xff)*0xff/e2 ) ) < 0 )
				return 0;
			else
				return x;
		}
		/**
		 * 32bit Color (0xAARRGGBB) を 焼き込み(BURN) でブレンドします．
		 * @param	c1	backcolor 0xAARRGGBB
		 * @param	c2	forecolor 0xAARRGGBB
		 * @return	0xAARRGGBB
		 */
		public static function burn32( c1:uint, c2:uint ):uint
		{
			return burnRGBA( (c1 & 0x00ff0000) >>> 16, (c1 & 0x0000ff00) >>> 8, c1 & 0x000000ff, (c2 & 0x00ff0000) >>> 16, (c2 & 0x0000ff00) >>> 8, c2 & 0x000000ff, (c1 & 0xff000000) >>> 24, (c2 & 0xff000000) >>> 24 );
		}
		/**
		 * RGBA値を指定して 焼き込み(BURN) でブレンドします．
		 * @return 0xAARRGGBB
		 */
		public static function burnRGBA( r1:uint, g1:uint, b1:uint, r2:uint, g2:uint, b2:uint, a1:uint=0xff, a2:uint=0xff ):uint
		{
			return Math.min( a1 + a2, 0xff ) << 24 | _burn32(r1,r2,a2)<<16 | _burn32(g1,g2,a2)<<8 | _burn32(b1,b2,a2);
		}
		/**
		 * @private
		 */
		private static function _burn32( e1:uint, e2:uint, a2:uint ):uint
		{
			var x:uint;
			if ( e2 == 0 || (x = 0xff - Math.floor( (e1^0xff)*0xff/e2 ) ) < 0 )
				x = 0;
			return (e1*(a2^0xff) + x*a2)>>8;
		}
		
		//-------------------------------
		/**
		 * 24bit Color (0xRRGGBB) を 除外(EXCLUSION) でブレンドします．
		 * @param	c1	backcolor 0xRRGGBB
		 * @param	c2	forecolor 0xRRGGBB
		 * @return	0xRRGGBB
		 */
		public static function excl( c1:uint, c2:uint ):uint
		{
			return exclRGB( (c1 & 0xff0000)>>>16, (c1 & 0x00ff00)>>>8, c1 & 0x0000ff, (c2 & 0xff0000)>>>16, (c2 & 0x00ff00)>>>8, c2 & 0x0000ff );
		}
		/**
		 * RGB値を指定して 除外(EXCLUSION) でブレンドします．
		 * @return 0xRRGGBB
		 */
		public static function exclRGB( r1:uint, g1:uint, b1:uint, r2:uint, g2:uint, b2:uint ):uint
		{
			return _excl(r1,r2)<<16 | _excl(g1,g2)<<8 | _excl(b1,b2);
		}
		/**
		 * @private
		 */
		private static function _excl( e1:uint, e2:uint ):uint
		{
			return e1 + e2 - ( e1*e2>>>7 );
		}
		/**
		 * 32bit Color (0xAARRGGBB) を 除外(EXCLUSION) でブレンドします．
		 * @param	c1	backcolor 0xAARRGGBB
		 * @param	c2	forecolor 0xAARRGGBB
		 * @return	0xAARRGGBB
		 */
		public static function excl32( c1:uint, c2:uint ):uint
		{
			return exclRGBA( (c1 & 0x00ff0000) >>> 16, (c1 & 0x0000ff00) >>> 8, c1 & 0x000000ff, (c2 & 0x00ff0000) >>> 16, (c2 & 0x0000ff00) >>> 8, c2 & 0x000000ff, (c1 & 0xff000000) >>> 24, (c2 & 0xff000000) >>> 24 );
		}
		/**
		 * RGBA値を指定して 除外(EXCLUSION) でブレンドします．
		 * @return 0xAARRGGBB
		 */
		public static function exclRGBA( r1:uint, g1:uint, b1:uint, r2:uint, g2:uint, b2:uint, a1:uint=0xff, a2:uint=0xff ):uint
		{
			return Math.min( a1 + a2, 0xff ) << 24 | _excl32(r1,r2,a2)<<16 | _excl32(g1,g2,a2)<<8 | _excl32(b1,b2,a2);
		}
		/**
		 * @private
		 */
		private static function _excl32( e1:uint, e2:uint, a2:uint ):uint
		{
			return e1 + (e2 * a2 >> 8) - ( e1 * e2 * a2 >>> 15 );
		}
		
		//---------------------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static function _to32( c:uint, a:Number ):uint
		{
			a = ( isNaN(a) ) ? 0xff : Math.round(0xff*a);
			return (a << 24) | c;
		}
	}
}