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
	* RGB と HSV の変換メソッドを提供します.
	* 
	* @author nutsu
	* @version 0.1.1
	* 
	*/
	public class ColorConvert {
		
		/**
		 * HSV値 を RGB値 に変換します.
		 * @param	h	hue degree 360
		 * @param	s	saturation [0.0,1.0]
		 * @param	v	brightness [0.0,1.0]
		 * @return	{ r:uint, g:uint ,b:uint }
		 */
		public static function HSV2RGB( _h:Number, _s:Number, _v:Number ):Object
		{
			var _r:uint;
			var _g:uint;
			var _b:uint;
			
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
			
			return { r:_r, g:_g, b:_b };
		}
		
		/**
		 * RGB値　を HSV値 に変換します.
		 * @param	r	red [0,255]
		 * @param	g	green [0,255]
		 * @param	b	blue [0,255]
		 * @return	{ h:Number, s:Number, v:Number }
		 */
		public static function RGB2HSV( _r:uint, _g:uint, _b:uint ):Object
		{
			var _h:Number;
			var _s:Number;
			var _v:Number;
			
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
			
			return { h:_h, s:_s, v:_v };
		}
		
		/**
		 * 24bit Color を HSV値に変換します.
		 * @param	col	0xRRGGBB
		 * @return	{ h:Number, s:Number, v:Number }
		 */
		public static function UInt2HSV( col:uint ):Object
		{
			return RGB2HSV( (col & 0xff0000) >>> 16, (col & 0x00ff00) >>> 8, col & 0x0000ff );
		}
		
		/**
		 * HSV値 を 24bit Color に変換します.
		 * @param	h	hue degree 360
		 * @param	s	saturation [0.0,1.0]
		 * @param	v	brightness [0.0,1.0]
		 * @return	0xRRGGBB
		 */
		public static function HSV2UInt( h:Number, s:Number, v:Number ):uint
		{
			var col:Object = HSV2RGB( h, s, v );
			return col.r << 16 | col.g << 8 | col.b;
		}
	}
	
}