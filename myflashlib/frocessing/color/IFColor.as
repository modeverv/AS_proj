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
	 * 色オブジェクトの拡張インターフェイスです.
	 * 
	 * @author nutsu
	 * @version 0.1
	 * 
	 */
	public interface IFColor extends IColor
	{
		/**
		 * RGB値で色を指定します.
		 */
		function rgb( r:uint, g:uint, b:uint, a:Number = 1.0 ):void;
		
		/**
		 * HSV値で色を指定します.
		 */
		function hsv( h:Number, s:Number = 1.0, v:Number = 1.0, a:Number = 1.0 ):void;
		
		/**
		 * グレイ値で色を指定します.
		 */
		function gray( value_:uint, a:Number = 1.0 ):void;
		
		/**
		 * 色の 色相(Hue) 値を、色相環上のディグリーの角度( 0～360 )で示します.
		 */
		function get h():Number;
		function set h( value_:Number ):void;
		
		/**
		 * 色の 色相(Hue) 値を、色相環上のラジアン( 0～2PI )で示します.
		 */
		function get hr():Number;
		function set hr( value_:Number ):void;
		
		/**
		 * 色の 彩度(Saturation) 値を示します.
		 */
		function get s():Number;
		function set s( value_:Number ):void;
		
		/**
		 * 色の 明度(Value・Brightness) 値を示します.
		 */
		function get v():Number;
		function set v( value_:Number ):void;
	}
	
}