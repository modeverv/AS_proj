package com.flickrfloater.model
{
    /*
     * Value object representing all known information about a Photo's note.
     */
    [Bindable]
    public class ContactDetails extends ValueObject
    {
    	public var username:String;
    	public var nsid:String;
   }
}