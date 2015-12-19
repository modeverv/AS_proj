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

package frocessing.color
//package 
{
	
	/**
	 * 色相（Hue） 彩度(Saturation) 明度(Value・Brightness) で色を定義するクラスです.
	 * 
	 * @author nutsu
	 * @version 0.1
	 * 
	 * @see frocessing.color.ColorRGB
	 * @see frocessing.color.FColor
	 */
	public class ColorHSV implements IColor{
		
		private var _h:Number;	//Hue
		private var _s:Number;	//Saturation
		private var _v:Number;	//Value | Brightness
		private var _r:uint;
		private var _g:uint;
		private var _b:uint;
		private var _alpha:Number;
		private var update_flg:Boolean;
		
		/**
		 * 新しい ColorHSV クラスのインスタンスを生成します.
		 * 
		 * @param	h_	Hue (degree 360)
		 * @param	s_	Saturation [0.0,1.0]
		 * @param	v_	Brightness [0.0,1.0]
		 * @param	a	Alpha [0.0,1.0]
		 */
		public function ColorHSV( h_:Number=0.0, s_:Number = 1.0, v_:Number = 1.0, a:Number = 1.0  ) 
		{
			hsv( h_, s_, v_ );
			_alpha = a;
		}
		
		//---------------------------------------------------------------------------------------------------ICOLOR INTERFACE
		
		/**
		 * 24bit Color (0xRRGGBB) を示します.
		 */
		public function get value():uint
		{
			if ( update_flg )
				update();
			return _r << 16 | _g << 8 | _b;
		}
		public function set value( value_:uint ):void
		{
			_r = value_ >> 16;
			_g = ( value_ & 0x00ff00 ) >> 8;
			_b = value_ & 0x0000ff;
			update_hsv();
		}
		
		/**
		 * 32bit Color (0xAARRGGBB) を示します.
		 */
		public function get value32():uint
		{
			if ( update_flg )
				update();
			return ( Math.round( _alpha*0xff ) & 0xff )<<24 | _r << 16 | _g << 8 | _b ;
		}
		public function set value32( value_:uint ):void
		{
			_r = ( value_ & 0x00ff0000 ) >>> 16;
			_g = ( value_ & 0x0000ff00 ) >>> 8;
			_b = value_ & 0x000000ff;
			_alpha = ( value_ >>> 24 ) / 0xff;
			update_hsv();
		}
		
		/**
		 * 色の 透明度(Alpha) 値を示します.<br/>
		 * 有効な値は 0.0　～　1.0　です.デフォルト値は　1.0　です.
		 */
		public function get alpha():Number { return _alpha; }
		public function set alpha(value_:Number):void
		{
			_alpha = value_;
		}
		
		/**
		 * 色の 透明度(Alpha) 値を 0～255 で示します.<br/>
		 * 有効な値は 0～255　です.
		 */
		public function get alpha8():uint { return uint(_alpha*0xff); }
		public function set alpha8(value_:uint):void
		{
			_alpha = 1.0*value_/0xff;
		}
		
		/**
		 * 色の 赤(Red) 値を示します.<br/>
		 * 有効な値は 0 ～ 255 です.デフォルト値は 0 です.
		 */
		public function get r():uint
		{
			if ( update_flg )
				update();
			return _r;
		}
		public function set r( value_:uint ):void
		{
			_r = value_ & 0xff;
			update_hsv();
		}
		
		/**
		 * 色の 緑(Green) 値を示します.<br/>
		 * 有効な値は 0 ～ 255 です.デフォルト値は 0 です.
		 */
		public function get g():uint
		{
			if ( update_flg )
				update();
			return _g;
		}
		public function set g( value_:uint ):void
		{
			_g = value_ & 0xff;
			update_hsv();
		}
		
		/**
		 * 色の 青(Blue) 値を示します.<br/>
		 * 有効な値は 0 ～ 255 です.デフォルト値は 0 です.
		 */
		public function get b():uint
		{
			if ( update_flg )
				update();
			return _b;
		}
		public function set b( value_:uint ):void
		{
			_b = value_ & 0xff;
			update_hsv();
		}
		
		//---------------------------------------------------------------------------------------------------H,S,V
		
		/**
		 * 色の 色相(Hue) 値を、色相環上のディグリーの角度( 0～360 )で示します.<br/>
		 * 0 度が赤、120 度が緑、240 度が青になります. 
		 */
		public function get h():Number { return _h; }
		public function set h( value_:Number ):void
		{
			_h = value_;
			update_flg = true;
		}
		/**
		 * 色の 色相(Hue) 値を、色相環上のラジアン( 0～2PI )で示します.<br/>
		 * 0 が赤、2PI/3 が緑、4PI/3 が青になります. 
		 */
		public function get hr():Number { return Math.PI*_h / 180; }
		public function set hr( value_:Number ):void
		{
			_h = 180*value_/Math.PI;
			update_flg = true;
		}
		
		/**
		 * 色の 彩度(Saturation) 値を示します.<br/>
		 * 有効な値は 0.0 ～ 1.0 です.デフォルト値は 1 です.
		 */
		public function get s():Number { return _s; }
		public function set s( value_:Number ):void
		{
			_s = Math.max( 0.0, Math.min( 1.0, value_ ) );
			update_flg = true;
		}
		
		/**
		 * 色の 明度(Value・Brightness) 値を示します.<br/>
		 * 有効な値は 0.0 ～ 1.0 です.デフォルト値は 1 です.
		 */
		public function get v():Number { return _v; }
		public function set v( value_:Number ):void
		{
			_v = Math.max( 0.0, Math.min( 1.0, value_ ) );
			update_flg = true;
		}
		
		//---------------------------------------------------------------------------------------------------SET
		
		/**
		 * HSV値で色を指定します.
		 * @param	h_	Hue (degree 360)
		 * @param	s_	Saturation [0.0,1.0]
		 * @param	v_	Brightness [0.0,1.0]
		 */
		public function hsv( h_:Number, s_:Number = 1.0, v_:Number = 1.0 ):void
		{
			_h = h_;
			_s = Math.max( 0.0, Math.min( 1.0, s_ ) );
			_v = Math.max( 0.0, Math.min( 1.0, v_ ) );
			update_flg = true;
		}
		
		/**
		 * RGB値で色を指定します.
		 * @param	r_	Red [0,255]
		 * @param	g_	Green [0,255]
		 * @param	b_	Blue [0,255]
		 */
		public function rgb( r_:uint, g_:uint, b_:uint ):void
		{
			_r = r_ & 0xff;
			_g = g_ & 0xff;
			_b = b_ & 0xff;
			update_hsv();
		}
		
		/**
		 * グレイ値で色を指定します.
		 * @param	gray_	Gray [0,255]
		 */
		public function gray( gray_:uint ):void
		{
			_h = 0.0;
			_s = 0.0;
			_v = _r = _g = _b = gray_ / 0xff;
		}
		
		//---------------------------------------------------------------------------------------------------CONVERT
		
		/**
		 * HSV 値を RGB 値に変換して ColorRGB クラスのインスタンスを生成します.
		 */
		public function toRGB():ColorRGB
		{
			if ( update_flg )
				update();
			return new ColorRGB( _r, _g, _b, _alpha );
		}
		
		/**
		 * RGB値から ColorHSV クラスのインスタンスを生成します.
		 * @param	r_	Red [0,255]
		 * @param	g_	Green [0,255]
		 * @param	b_	Blue [0,255]
		 * @param	a	Alpha [0.0,1.0]
		 */
		public static function fromRGB( r_:uint, g_:uint, b_:uint, a:Number=1.0 ):ColorHSV
		{
			var c:ColorHSV = new ColorHSV( 0, 1, 1, a );
			c.rgb( r_, g_, b_ );
			return c;
		}
		
		//---------------------------------------------------------------------------------------------------UPDATE RGB
		
		/**
		 * HSV値をRGB値に変換します
		 * @private
		 */
		private function update():void
		{
			update_flg = false;
			if ( _s == 0 )
			{
				_r = _g = _b = Math.round( _v * 0xff );
			}
			else
			{
				var ht:Number = _h;
				ht = (((ht %= 360) < 0) ? ht + 360 : ht )/60;
				var vt:Number = Math.max( 0, Math.min( 0xff, _v*0xff ) );
				var hi:int = Math.floor( ht );
				
				switch( hi )
				{
					case 0:
						_r = vt;
						_g = Math.round( vt * ( 1 - (1 - ht + hi) * _s ) );
						_b = Math.round( vt * ( 1 - _s ) );
						break;
					case 1:
						_r = Math.round( vt * ( 1 - _s * ht + _s * hi ) );
						_g = vt;
						_b = Math.round( vt * ( 1 - _s ) );
						break;
					case 2:
						_r = Math.round( vt * ( 1 - _s ) );
						_g = vt;
						_b = Math.round( vt * ( 1 - (1 - ht + hi) * _s ) );
						break;
					case 3:
						_r = Math.round( vt * ( 1 - _s ) );
						_g = Math.round( vt * ( 1 - _s * ht + _s * hi ) );
						_b = vt;
						break;
					case 4:
						_r = Math.round( vt * ( 1 - (1 - ht + hi) * _s ) );
						_g = Math.round( vt * ( 1 - _s ) );
						_b = vt;
						break;
					case 5:
						_r = vt;
						_g = Math.round( vt * ( 1 - _s ) );
						_b = Math.round( vt * ( 1 - _s * ht + _s * hi ) );
						break;
				}
			}
		}
		
		/**
		 * RGB値をHSV値に変換します
		 * @private
		 */
		private function update_hsv():void
		{
			var max:Number = Math.max( _r , Math.max( _g, _b ) );
			var min:Number = Math.min( _r , Math.min( _g, _b ) );
			var mm:Number  = max - min;
			
			if ( mm == 0 )
			{
				_h = 0;
				_s = 0;
				_v = max / 0xff;
			}
			else
			{
				_s = mm / max;
				_v = max / 0xff;
				if ( _r == max )
					_h = 60 * ( _g - _b ) / mm;
				else if ( _g == max )
					_h = 60 * ( _b - _r ) / mm + 120;
				else
					_h = 60 * ( _r - _g ) / mm + 240;
			}
		}
		
		//---------------------------------------------------------------------------------------------------STRING, VALUE
		
		public function toString():String 
		{
			return "[HSV(" + _h.toFixed(2) + "," + _s.toFixed(2) + "," + _v.toFixed(2) + ")A("+ _alpha.toFixed(2)+")]";
		}
		
		/**
		 * @return 0xRRBBGG
		 */
		public function valueOf():uint 
		{
			return value;
		}
		
		/**
		 * ColorHSV　インスタンスのクローンを生成します.
		 */
		public function clone():ColorHSV
		{
			return new ColorHSV( _h, _s, _v, _alpha );
		}
	}
	
}