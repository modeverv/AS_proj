package org.libspark.next {
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	public dynamic class NextFactory extends Proxy {
		flash_proxy override function callProperty(name:*, ...rest):* {
			var n:Next = new Next();
			return n[name].apply(n, rest);
		}
		flash_proxy override function getProperty(name:*):* {
			return (new Next())[name];
  	}
	}
}