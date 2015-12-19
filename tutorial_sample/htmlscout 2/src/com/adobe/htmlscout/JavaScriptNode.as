package com.adobe.htmlscout
{
	import mx.collections.ArrayCollection;

	public class JavaScriptNode
	{
		public var children:ArrayCollection;
		public var label:String;
		public var jsNode:Object;
		
		public function JavaScriptNode(label:String)
		{
			this.label = label;
			this.children = new ArrayCollection();
		}
	}
}
