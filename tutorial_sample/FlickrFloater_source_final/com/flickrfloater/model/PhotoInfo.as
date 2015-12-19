package com.flickrfloater.model
{
    
    import mx.collections.ArrayCollection;
    /**
     * Value object representing all known information about a Photo.
     */
    [Bindable]
    public class PhotoInfo extends ValueObject
    {
    	public var id:int;
    	public var secret:String;
    	public var server:int;
    	public var farm:int;
    	public var dateuploaded:Date;
    	public var isfavorite:int;
    	public var license:int;
    	public var rotation:int;
    	public var originalsecret:String;
    	public var originalformat:String;
    	public var views:int;
    	public var ownerNsid:String;
    	public var ownerUsername:String;
    	public var ownerRealname:String;
    	public var ownerLocation:String;
    	public var title:String;
    	public var description:String;
    	public var ispublic:int;
    	public var isfriend:int;
    	public var isfamily:int;    	
    	public var datePosted:Date;
    	public var dateTaken:String;
    	public var takengranularity:int;
    	public var lastupdate:Date;
    	public var permcomment:int;
    	public var permaddmeta:int;
    	public var cancomment:int;
    	public var canaddmeta:int;
    	public var comments:int;
    	public var notes:ArrayCollection;
    	public var tags:ArrayCollection;
    	public var urls:ArrayCollection;
   }
}