/*
	Adobe Systems Incorporated(r) Source Code License Agreement
	Copyright(c) 2008 Adobe Systems Incorporated. All rights reserved.
	
	Please read this Source Code License Agreement carefully before using
	the source code.
	
	Adobe Systems Incorporated grants to you a perpetual, worldwide, non-exclusive, 
	no-charge, royalty-free, irrevocable copyright license, to reproduce,
	prepare derivative works of, publicly display, publicly perform, and
	distribute this source code and such derivative works in source or 
	object code form without any attribution requirements.  
	
	The name "Adobe Systems Incorporated" must not be used to endorse or promote products
	derived from the source code without prior written permission.
	
	You agree to indemnify, hold harmless and defend Adobe Systems Incorporated from and
	against any loss, damage, claims or lawsuits, including attorney's 
	fees that arise or result from your use or distribution of the source 
	code.
	
	THIS SOURCE CODE IS PROVIDED "AS IS" AND "WITH ALL FAULTS", WITHOUT 
	ANY TECHNICAL SUPPORT OR ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING,
	BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
	FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  ALSO, THERE IS NO WARRANTY OF 
	NON-INFRINGEMENT, TITLE OR QUIET ENJOYMENT.  IN NO EVENT SHALL MACROMEDIA
	OR ITS SUPPLIERS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
	EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
	PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
	OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
	WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
	OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOURCE CODE, EVEN IF
	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package com.adobe.apprise.views
{
	import com.adobe.apprise.views.Browser;
	import flash.html.HTMLHost;
	import flash.html.HTMLWindowCreateOptions;
	import flash.html.HTMLLoader;
	import flash.events.Event;
	import mx.core.Window;
	
	public class CustomHost extends HTMLHost
	{
		public override function createWindow(options:HTMLWindowCreateOptions):HTMLLoader
		{
			var win:Window = new Window();
			win.title = "Apprise";
			win.width = 800;
			win.height = 600;
			var browser:Browser = new Browser();
			browser.addEventListener(Event.LOCATION_CHANGE,
				function(e:Event):void
				{
					win.status = "Loading " + e.target.locationBar.text;
				});
			browser.addEventListener(Event.COMPLETE,
				function(e:Event):void
				{
					win.status = "Done";
				});
			browser.percentHeight = 100;
			browser.percentWidth = 100;
			win.addChild(browser);
			win.open(true);
			return browser.html.htmlLoader;
		}
		
		public override function updateLocation(locationURL:String):void
		{
			this.htmlLoader.dispatchEvent(new Event(Event.LOCATION_CHANGE));
		}

		public override function updateTitle(title:String):void
		{
			// Do nothing
		}
	}
}