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
	 * FColorMode クラスは、Processingの色設定メソッド(colorModeなど)を実現するクラスです．
	 * 
	 * @author nutsu
	 * @version 0.1.1
	 * 
	 * @see frocessing.color.ColorMode
	 */
	public class FColorMode {
		
		private var _color_mode:String;
		private var _range1:Number;
		private var _range2:Number;
		private var _range3:Number;
		private var _range4:Number;
		
		/**
		 * 新しい FColorMode クラスのインスタンスを生成します.
		 * 
		 * <p>引数の数により有効値の設定が異なります.</p>
		 * 
		 * <listing>new FColorMode( ColorMode.RGB, value);</listing>
		 * 
		 * <p>range1～range4 全てに value が適用されます.</p>
		 * 
		 * <listing>new FColorMode( ColorMode.RGB, value1, value2 );</listing>
		 * <p>range1～range3　に value1、range4 に value2 が適用されます.透明度の有効値だけを変えたい場合に使用します.</p>
		 * 
		 * <listing>new FColorMode( ColorMode.RGB, value1, value2, value3 );</listing>
		 * <p>range1 に value1、range2 に value2、range3 に value3 が適用されます.透明度にはデフォルト値(1.0)が適用されます.</p>
		 * 
		 * <listing>new FColorMode( ColorMode.RGB, value1, value2, value3, value4 );</listing>
		 * <p>range1～range4　をそれぞれ個別に指定します.</p>
		 * 
		 * @param	mode
		 * @param	range1_
		 * @param	range2_
		 * @param	range3_
		 * @param	range4_
		 * @see frocessing.color.ColorMode
		 */
		public function FColorMode( mode:String="rgb", range1_:Number=0xff, range2_:Number=0xff, range3_:Number=0xff, range4_:Number=1.0 )
		{
			colorMode( mode, range1_, range2_, range3_, range4_ );
		}
		
		/**
		 * カラーモードと、色の有効値を設定します.
		 * 
		 * <p>引数の数により有効値の設定が異なります.</p>
		 * 
		 * <listing>colorMode( ColorMode.RGB, value);</listing>
		 * 
		 * <p>range1～range4 全てに value が適用されます.</p>
		 * 
		 * <listing>colorMode( ColorMode.RGB, value1, value2 );</listing>
		 * <p>range1～range3　に value1、range4 に value2 が適用されます.透明度の有効値だけを変えたい場合に使用します.</p>
		 * 
		 * <listing>colorMode( ColorMode.RGB, value1, value2, value3 );</listing>
		 * <p>range1 に value1、range2 に value2、range3 に value3 が適用されます.透明度は変更されません.</p>
		 * 
		 * <listing>colorMode( ColorMode.RGB, value1, value2, value3, value4 );</listing>
		 * <p>range1～range4　をそれぞれ個別に指定します.</p>
		 * 
		 * @param	mode
		 * @param	range1_
		 * @param	range2_
		 * @param	range3_
		 * @param	range4_
		 * @see frocessing.color.ColorMode
		 */
		public function colorMode( mode:String, range1_:Number=NaN, range2_:Number=NaN, range3_:Number=NaN, range4_:Number=NaN ):void
		{
			_color_mode = mode;
			if ( !isNaN(range1_) ) {
				if ( isNaN(range2_) )
				{
					_range1 = _range2 = _range3 = _range4 = range1_;
				}
				else if ( isNaN(range3_) )
				{
					_range1 = _range2 = _range3 = range1_;
					_range4 = range2_;
				}
				else if ( isNaN(range4_ ) )
				{
					_range1 = range1_;
					_range2 = range2_;
					_range3 = range3_;
				}
				else
				{
					_range1 = range1_;
					_range2 = range2_;
					_range3 = range3_;
					_range4 = range4_;
				}
			}
		}
		
		/**
		 * FColor クラスのインスタンスを生成します.
		 * 
		 * <p>引数の数により色の指定が異なります.</p>
		 * 
		 * <listing>color(gray);</listing>
		 * 
		 * <p>グレースケールで色の指定を行います.</p>
		 * 
		 * <listing>color( gray, alpha );</listing>
		 * <p>グレースケールと透明度で色の指定を行います.</p>
		 * 
		 * <listing>color( value1, value2, value3 );</listing>
		 * <p>RGB、または HSV を個別に指定します.</p>
		 * 
		 * <listing>color( value1, value2, value3, alpha );</listing>
		 * <p>全て個別に指定します.</p>
		 * 
		 * @param	c1	first value
		 * @param	c2	second value
		 * @param	c3	third value
		 * @param	c4	fourth value
		 */
		public function color( c1:Number, c2:Number=NaN, c3:Number=NaN, c4:Number=NaN ):FColor
		{
			if ( isNaN( c2 ) )
			{
				return FColorUtil.gray( uint(c1/_range1*0xff), 1.0 );
			}
			else if ( isNaN( c3 ) )
			{
				return FColorUtil.gray( uint(c1/_range1*0xff), c2/_range4 );
			}
			else if ( isNaN( c4 ) )
			{
				if ( _color_mode == ColorMode.HSB )
					return FColorUtil.hsv( 360*c1/_range1 , c2/_range2, c3/_range3, 1.0 );
				else
					return FColorUtil.rgb( uint(c1/_range1*0xff), uint(c2/_range2*0xff), uint(c3/_range3*0xff), 1.0 );
			}
			else
			{
				if ( _color_mode == ColorMode.HSB )
					return FColorUtil.hsv( 360*c1/_range1 , c2/_range2, c3/_range3, c4/_range4 );
				else
					return FColorUtil.rgb( uint(c1/_range1*0xff), uint(c2/_range2*0xff), uint(c3/_range3*0xff), c4/_range4 );
			}
		}
		
		/**
		 * IFColor の色を変更します.
		 * 
		 * <p>色の指定方法は、color() と同じです.</p>
		 * 
		 * @param	colObj	target color Object
		 * @param	c1	first value
		 * @param	c2	second value
		 * @param	c3	third value
		 * @param	c4	fourth value
		 * 
		 * @see #color
		 */
		public function setColor( colObj:IFColor, c1:Number, c2:Number=NaN, c3:Number=NaN, c4:Number=NaN ):void
		{
			if ( isNaN( c2 ) )
			{
				colObj.gray( uint(c1/_range1*0xff), 1.0 );
			}
			else if ( isNaN( c3 ) )
			{
				colObj.gray( uint(c1/_range1*0xff), c2/_range4 );
			}
			else if ( isNaN( c4 ) )
			{
				if ( _color_mode == ColorMode.HSB )
					colObj.hsv( 360*c1/_range1 , c2/_range2, c3/_range3, 1.0 );
				else
					colObj.rgb( uint(c1/_range1*0xff), uint(c2/_range2*0xff), uint(c3/_range3*0xff), 1.0 );
			}
			else
			{
				if ( _color_mode == ColorMode.HSB )
					colObj.hsv( 360*c1/_range1 , c2/_range2, c3/_range3, c4/_range4 );
				else
					colObj.rgb( uint(c1/_range1*0xff), uint(c2/_range2*0xff), uint(c3/_range3*0xff), c4/_range4 );
			}
		}
		
		/**
		 * IFColor の 赤(red) 値を、range1でスケーリングした値を返します.
		 */
		public function red( c:IFColor ):Number
		{
			return _range1 * c.r / 0xff;
		}
		
		/**
		 * IFColor の 緑(green) 値を、range2でスケーリングした値を返します.
		 */
		public function green( c:IFColor ):Number
		{
			return _range2 * c.g / 0xff;
		}
		
		/**
		 * IFColor の 青(blue) 値を、range3でスケーリングした値を返します.
		 */
		public function blue( c:IFColor ):Number
		{
			return _range3 * c.b / 0xff;
		}
		
		/**
		 * IFColor の 色相(hue) 値を、range1でスケーリングした値を返します.
		 */
		public function hue( c:IFColor ):Number
		{
			return _range1 * c.h / 360;
		}
		
		/**
		 * IFColor の 彩度(saturation) 値を、range2でスケーリングした値を返します.
		 */
		public function saturation( c:IFColor ):Number
		{
			return _range2 * c.s;
		}
		
		/**
		 * IFColor の 明度(value・brightness) 値を、range3でスケーリングした値を返します.
		 */
		public function brightness( c:IFColor ):Number
		{
			return _range3 * c.v;
		}
		
		/**
		 * IFColor の 透明度(alpha) を、range4でスケーリングした値を返します.
		 */
		public function alpha( c:IFColor ):Number
		{
			return _range4 * c.alpha;
		}
		
		/**
		 * 2つの色の 中間色 の FColor クラスのインスタンスを生成します.
		 * @param	color1 from color
		 * @param	color2 to color
		 * @param	amt	[0.0,1.0]
		 * @see frocessing.color.FColorUtil#lerpColorRGB
		 * @see frocessing.color.FColorUtil#lerpColorHSV
		 * @see frocessing.color.ColorLerp
		 */
		public function lerpColor( color1:IFColor, color2:IFColor, amt:Number ):FColor
		{
			if ( _color_mode == ColorMode.HSB )
				return FColorUtil.lerpColorHSV( color1, color2, amt );
			else
				return FColorUtil.lerpColorRGB( color1, color2, amt );
		}
		
		/**
		 * 2つの色をブレンドした FColor クラスのインスタンスを生成します.
		 * @param	color1	back color
		 * @param	color2	fore color
		 * @param	blend_mode
		 * @see frocessing.color.FColorUtil#blendColor
		 * @see frocessing.color.ColorBlend
		 */
		public static function blendColor( color1:IColor, color2:IColor, blend_mode:String ):FColor
		{
			return FColorUtil.blendColor( color1, color2, blend_mode );
		}
		
		//---------------------------------------------------------------------------------------------------
		
		/**
		 * カラーモードを示します．有効な値は、ColorMode.RGB　または ColorMode.HSV(ColorMode.HSB)　です. 
		 * @default ColorMode.RGB
		 */
		public function get mode():String { return _color_mode; }
		public function set mode(value:String):void {
			_color_mode = value;
		}
		
		/**
		 * 赤(red) または 色相(hue) の有効な値を示します。デフォルト値は 255 です.
		 * @default 255
		 */
		public function get range1():Number { return _range1; }
		public function set range1(value:Number):void {
			_range1 = value;
		}
		
		/**
		 * 緑(green) または 彩度(saturation) の有効な値を示します。デフォルト値は 255 です.
		 * @default 255
		 */
		public function get range2():Number { return _range2; }
		public function set range2(value:Number):void {
			_range2 = value;
		}
		
		/**
		 * 青(blue) または 明度(value・brightness) の有効な値を示します。デフォルト値は 255 です.
		 * @default 255
		 */
		public function get range3():Number { return _range3; }
		public function set range3(value:Number):void {
			_range3 = value;
		}
		
		/**
		 * 透明度(alpha) の有効な値を示します。デフォルト値は 1.0 です.
		 * @default 1.0
		 */
		public function get range4():Number { return _range4; }
		public function set range4(value:Number):void {
			_range4 = value;
		}
		
	}
	
}