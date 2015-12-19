package com.adobe.htmlscout
{
	import mx.collections.ArrayCollection;

	public class DOMNode
	{
		public var children:ArrayCollection;
		public var label:String;
		public var htmlNode:Object;
		
		public function DOMNode(label:String)
		{
			this.label = label;
			this.children = new ArrayCollection();
		}
	}
}
