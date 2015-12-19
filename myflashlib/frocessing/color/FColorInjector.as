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
	
	/**
	* 今後使うかもしれないクラス.
	* 
	* @author nutsu
	* @version 0.1
	* 
	*/
	public class FColorInjector implements IFColor{
		
		public var fcolor:FColor;
		public var is_updated:Boolean;
		
		public function FColorInjector( col:uint, a:Number=1.0 ) {
			fcolor = new FColor( col, a );
			is_updated = false;
		}
		
		//---------------------------------------------------------------------------------------------------BASIC
		
		/**
		 * 24bit Color
		 */
		public function get value():uint { return fcolor.value; }
		public function set value(value_:uint):void 
		{
			fcolor.value = value_;
			applySetting();
		}
		
		/**
		 * 32bit Color
		 */
		public function get value32():uint { return fcolor.value32; }
		public function set value32(value_:uint):void 
		{
			fcolor.value32 = value_;
			applySetting();
		}
		
		/**
		 * Alpha
		 */
		public function get alpha():Number { return fcolor.alpha; }	
		public function set alpha(value_:Number):void 
		{
			fcolor.alpha = value_;
			applySetting();
		}
		
		public function get alpha8():uint { return fcolor.alpha8; }	
		public function set alpha8(value_:uint):void 
		{
			fcolor.alpha8 = value_;
			applySetting();
		}
		
		//---------------------------------------------------------------------------------------------------R,G,B
		
		/**
		 * Red
		 */
		public function get r():uint { return fcolor.r; }
		public function set r( value_:uint ):void 
		{
			fcolor.r = value_;
			applySetting();
		}
		
		/**
		 * Green
		 */
		public function get g():uint { return fcolor.g; }
		public function set g( value_:uint ):void 
		{
			fcolor.g = value_;
			applySetting();
		}
		
		/**
		 * Blue
		 */
		public function get b():uint { return fcolor.b; }
		public function set b( value_:uint ):void 
		{
			fcolor.b = value_;
			applySetting();
		}
		
		//---------------------------------------------------------------------------------------------------H,S,V
		
		/**
		 * Hue	degree 360
		 */
		public function get h():Number { return fcolor.h; }
		public function set h( value_:Number ):void 
		{
			fcolor.h = value_;
			applySetting();
		}
		
		/**
		 * Hue	radian
		 */
		public function get hr():Number { return fcolor.hr; }
		public function set hr( value_:Number ):void 
		{
			fcolor.hr = value_;
			applySetting();
		}
		
		/**
		 * Saturation	[0.0,0.1]
		 */
		public function get s():Number { return fcolor.s; }
		public function set s( value_:Number ):void 
		{
			fcolor.s = value_;
			applySetting();
		}
		
		/**
		 * Brightness	[0.0,0.1]
		 */
		public function get v():Number { return fcolor.v; }
		public function set v( value_:Number ):void 
		{
			fcolor.v = value_;
			applySetting();
		}
		
		//---------------------------------------------------------------------------------------------------SET
		/**
		 * RGB値を指定します
		 * @param	Red		[0,255]
		 * @param	Green	[0,255]
		 * @param	Blue	[0,255]
		 * @param	Alpha	[0.0,1.0]
		 */
		public function rgb( r_:uint, g_:uint, b_:uint, a:Number = 1.0 ):void
		{
			fcolor.rgb( r_, g_, b_, a );
			applySetting();
		}
		
		/**
		 * グレイ値を指定します
		 * @param	Gray	[0,255]
		 * @param	Alpha	[0.0,1.0]
		 */
		public function gray( gray_:uint, a:Number=1.0 ):void
		{
			fcolor.gray( gray_, a );
			applySetting();
		}
		
		/**
		 * HSV値を指定します
		 * @param	Hue			degree 360
		 * @param	Saturation	[0.0,1.0]
		 * @param	Brightness	[0.0,1.0]
		 * @param	Alpha		[0.0,1.0]
		 */
		public function hsv( h_:Number, s_:Number=1.0, v_:Number=1.0, a:Number=1.0 ):void
		{
			fcolor.hsv( h_, s_, v_, a );
			applySetting();
		}
		
		//---------------------------------------------------------------------------------------------------applySetting
		/**
		 * function call after setting
		 */
		public function applySetting():void
		{
			is_updated = true;
		}
		
	}
	
}