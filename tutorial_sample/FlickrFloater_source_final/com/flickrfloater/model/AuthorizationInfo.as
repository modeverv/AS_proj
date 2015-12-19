package com.flickrfloater.model
{
    import com.flickrfloater.Settings;
    
    [Bindable]
    public class AuthorizationInfo extends Settings
    {
		public var apiKey:String;
		public var secret:String;		
		public var authToken:String;	
		public var accountName:String;	
		public var frob:String;
		public var authorizationURL:String;
		public var nsid:String;
   }
}