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
	 * RGB値とHSV値の色を包括的に扱うクラスです.
	 * 
	 * <p>内部的には、RGB値を指定した場合は ColorRGB として、HSV値を指定した場合は ColorHSV として処理されます.<br/>
	 * 例えば、RGB値で色を指定した場合、HSV値への変換は行われず、HSV値を参照したときに変換処理がなされます.</p>
	 * 
	 * @author nutsu
	 * @version 0.1
	 * 
	 * @see frocessing.color.ColorRGB
	 * @see frocessing.color.ColorHSV
	 */
	public class FColor implements IFColor{
		
		private var rgbmode:Boolean;
		private var rgbcolor:ColorRGB;
		private var hsvcolor:ColorHSV;
		private var _colour:IColor;
		
		/**
		 * 新しい FColor クラスのインスタンスを生成します.
		 * 
		 * @param	col	0xRRGGBB
		 * @param	a	Alpha [0.0,1.0]
		 */
		public function FColor( col:uint = 0, a:Number = 1.0 ) 
		{
			rgbcolor = new ColorRGB();
			hsvcolor = new ColorHSV();
			rgbmode  = true;
			rgbcolor.value = col;
			rgbcolor.alpha = a;
			_colour = rgbcolor;
		}
		
		//---------------------------------------------------------------------------------------------------ICOLOR INTERFACE
		
		/**
		 * @copy frocessing.color.ColorRGB#value
		 */
		public function get value():uint { return _colour.value; }
		public function set value( value_:uint ):void
		{
			rgbcolor.value = value_;
			_colour = rgbcolor;
			rgbmode = true;
		}
		
		/**
		 * @copy frocessing.color.ColorRGB#value32
		 */
		public function get value32():uint { return _colour.value32; }
		public function set value32( value_:uint ):void
		{
			rgbcolor.value32 = value_;
			_colour = rgbcolor;
			rgbmode = true;
		}
		
		/**
		 * @copy frocessing.color.ColorRGB#alpha
		 */
		public function get alpha():Number { return _colour.alpha; }
		public function set alpha(value_:Number):void {
			_colour.alpha = value_;
		}
		
		/**
		 * @copy frocessing.color.ColorRGB#alpha8
		 */
		public function get alpha8():uint { return _colour.alpha8; }
		public function set alpha8(value_:uint):void{
			_colour.alpha8 = value_;
		}
		
		/**
		 * @copy frocessing.color.ColorRGB#r
		 */
		public function get r():uint { return _colour.r; }
		public function set r( value_:uint ):void 
		{
			convertHSV2RGB();
			rgbcolor.r = value_;
		}
		
		/**
		 * @copy frocessing.color.ColorRGB#g
		 */
		public function get g():uint { return _colour.g; }
		public function set g( value_:uint ):void 
		{
			convertHSV2RGB();
			rgbcolor.g = value_;
		}
		
		/**
		 * @copy frocessing.color.ColorRGB#b
		 */
		public function get b():uint { return _colour.b; }
		public function set b( value_:uint ):void 
		{
			convertHSV2RGB();
			rgbcolor.b = value_;
		}
		
		//---------------------------------------------------------------------------------------------------H,S,V
		
		/**
		 * @copy frocessing.color.ColorHSV#h
		 */
		public function get h():Number 
		{
			convertRGB2HSV();
			return hsvcolor.h;
		}
		public function set h( value_:Number ):void 
		{
			convertRGB2HSV();
			hsvcolor.h = value_;
		}
		
		/**
		 * @copy frocessing.color.ColorHSV#hr
		 */
		public function get hr():Number 
		{
			convertRGB2HSV();
			return hsvcolor.hr;
		}
		public function set hr( value_:Number ):void 
		{
			convertRGB2HSV();
			hsvcolor.hr = value_;
		}
		
		/**
		 * @copy frocessing.color.ColorHSV#s
		 */
		public function get s():Number 
		{
			convertRGB2HSV();
			return hsvcolor.s;
		}
		public function set s( value_:Number ):void 
		{
			convertRGB2HSV();
			hsvcolor.s = value_;
		}
		
		/**
		 * @copy frocessing.color.ColorHSV#v
		 */
		public function get v():Number 
		{
			convertRGB2HSV();
			return hsvcolor.v;
		}
		public function set v( value_:Number ):void 
		{
			convertRGB2HSV();
			hsvcolor.v = value_;
		}
		
		//---------------------------------------------------------------------------------------------------SETTING
		
		/**
		 * RGB値で色を指定します.
		 * @param	r_	Red [0,255]
		 * @param	g_	Green [0,255]
		 * @param	b_	Blue [0,255]
		 * @param	a	Alpha [0.0,1.0]
		 */
		public function rgb( r_:uint, g_:uint, b_:uint, a:Number=1.0 ):void
		{
			rgbcolor.rgb( r_, g_, b_ );
			rgbcolor.alpha = a;
			_colour = rgbcolor;
			rgbmode = true;
		}
		
		/**
		 * グレイ値で色を指定します.
		 * @param	gray_	Gray [0,255]
		 * @param	a	Alpha [0.0,1.0]
		 */
		public function gray( gray_:uint, a:Number=1.0 ):void
		{
			rgbcolor.gray( gray_ );
			rgbcolor.alpha = a;
			_colour = rgbcolor;
			rgbmode = true;
		}
		
		/**
		 * HSV値で色を指定します.
		 * @param	h_	Hue (degree 360)
		 * @param	s_	Saturation [0.0,1.0]
		 * @param	v_	Brightness [0.0,1.0]
		 * @param	a	Alpha [0.0,1.0]
		 */
		public function hsv( h_:Number, s_:Number=1.0, v_:Number=1.0, a:Number=1.0 ):void
		{
			hsvcolor.hsv( h_, s_, v_ );
			hsvcolor.alpha = a;
			_colour = hsvcolor;
			rgbmode = false;
		}
		
		//---------------------------------------------------------------------------------------------------PRIVATE
		
		/**
		 * 内部カラーオブジェクトを ColorRGB から ColorHSV へ変換します.
		 * @private
		 */
		private function convertRGB2HSV():void
		{
			if ( rgbmode )
			{
				hsvcolor = rgbcolor.toHSV();
				_colour = hsvcolor;
				rgbmode = false;
			}
		}
		
		/**
		 * 内部カラーオブジェクトを ColorHSV から ColorRGB へ変換します.
		 * @private
		 */
		private function convertHSV2RGB():void
		{
			if ( !rgbmode )
			{
				rgbcolor = hsvcolor.toRGB();
				_colour = rgbcolor;
				rgbmode = true;
			}
		}
		
		//---------------------------------------------------------------------------------------------------VALUE
		
		/**
		 * @return 0xRRBBGG
		 */
		public function valueOf():uint
		{
			return _colour.value;
		}
		
		public function toString():String
		{
			return "[FColor" + _colour + "]";
		}
		
		/**
		 * FColor インスタンスのクローンを生成します.
		 */
		public function clone():FColor
		{
			return new FColor( _colour.value, _colour.alpha );
		}
	}
	
}