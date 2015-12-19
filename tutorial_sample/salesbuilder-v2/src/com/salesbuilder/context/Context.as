package com.salesbuilder.context
{
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.AsyncToken;
	import mx.rpc.Responder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;

	public dynamic class Context
	{
		private static var instance:Context;
		
		public var stateList:ArrayCollection;
		
		public var accountTypeList:ArrayCollection = new ArrayCollection([
			{data: 0, label:"Select"}, 
			{data: 1, label:"Customer"},
			{data: 2, label:"Partner"},
			{data: 3, label:"Competitor"}]); 

		public var industryList:ArrayCollection = new ArrayCollection([
			{data: 0, label:"Select"}, 
			{data: 1, label:"Aerospace"}, 
			{data: 2, label:"Airlines"}, 
			{data: 3, label:"Automobile"}, 
			{data: 4, label:"Biotechnology"}, 
			{data: 5, label:"Computer Hardware"},
			{data: 6, label:"Computer Software"},
			{data: 7, label:"Conglomerates"},
			{data: 8, label:"Financial Services"},
			{data: 9, label:"Food and Beverage"},
			{data: 10, label:"Government"},
			{data: 11, label:"Telecom"},
			{data: 12, label:"Paper Industry"}
			]);

		public var ownerList:ArrayCollection = new ArrayCollection([
			{data: 0, label:"Select"}, 
			{data: 1, label:"Christophe Coenraets"},
			{data: 2, label:"Lloyd Hill"},
			{data: 3, label:"Brian Rull"}]); 
		
		// Static initializer
		{
			instance = new Context();
		}
		
		public function Context()
		{
			var srv:HTTPService = new HTTPService();
			srv.url = "data/states.xml";
			var token:AsyncToken = srv.send();
			token.addResponder(new Responder(
				function (event:ResultEvent):void
				{
					stateList = event.result.states.state;
				},
				function (event:FaultEvent):void
				{
					Alert.show(event.fault.faultString);
				}
			));
		}

		public static function getAttribute(name:String):*
		{
			if (instance.hasOwnProperty(name))
			{
				return instance[name];
			}
			else
			{
				trace("Context property '" + name + "' not found");
				return null;
			}
		}		

		public static function setAttribute(name:String, value:*):void
		{
			instance[name] = value;	
		}		

	}
}