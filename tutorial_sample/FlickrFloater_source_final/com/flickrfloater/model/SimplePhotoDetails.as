package com.flickrfloater.model
{
    /*
     * Value object representing all known information about a Photo's note.
     */
    [Bindable]
    public class SimplePhotoDetails extends ValueObject
    {
    	public var photoId:Number;
    	public var title:String;
    	public var fileName:String;
    	public var tags:String;
    	public var description:String;
   }
}