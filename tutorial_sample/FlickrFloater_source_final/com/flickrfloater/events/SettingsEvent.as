/*

	Part of the application logic used in Flickr Floater has been sourced from
	open source demo code originally provided by Adobe or it's staff or representatives, 
	the disclaimer below is acknowledgement of that code and the original authors rights
	and responsibilities

*/

/*
	Copyright (c) 2007 Adobe Systems Incorporated
	
	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:
	
	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	THE SOFTWARE.
*/

package com.flickrfloater.events
{
	import flash.events.Event;
	import com.flickrfloater.Settings;

	//Event related to changes in settings
	public class SettingsEvent extends Event
	{
		//broadcast when the settings have been updated
		public static const SETTINGS_CHANGED:String = "settingsChanged";
		
		//the updated settings
		[Bindable]
		public var settings:Settings;		
		
		public function SettingsEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		
		
	}
}