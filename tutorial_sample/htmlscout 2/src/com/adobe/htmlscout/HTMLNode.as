package com.adobe.htmlscout
{
	import mx.collections.ArrayCollection;

	public class HTMLNode
	{
		public var children:ArrayCollection;
		public var attributes:Array;
		public var _value:String;
		private var _label:String;
		private var _elementName:String;
		
		public function HTMLNode(elementName:String)
		{
			this._elementName = elementName;
			this.children = new ArrayCollection();
			this.attributes = new Array();
		}

		public function set value(value:String):void
		{
			this._value = value.replace(/\n/g, "");
		}

		public function get value():String
		{
			return this._value;
		}
		
		public function get label():String
		{
			var sb:String = "<" + this._elementName;

			for each (var attr:Object in this.attributes)
			{
				sb += " " + attr.name + "=\"" + attr.value + "\"";
			}

			if (this._value == null)
			{
				sb += "/>";
			}
			else
			{
				sb += ">";
				sb += this._value;
				sb += "</"+this._elementName+">";
			}
			return sb;
		}
		
	}
}
