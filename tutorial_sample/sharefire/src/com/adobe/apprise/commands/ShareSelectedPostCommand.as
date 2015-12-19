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

package com.adobe.apprise.commands
{
	import com.adobe.apprise.events.ShareSelectedPostEvent;
	import com.adobe.apprise.model.ModelLocator;
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.resources.ResourceManager;
		
	public class ShareSelectedPostCommand implements ICommand
	{
		public function execute(ce:CairngormEvent):void
		{
			var post:Object = ModelLocator.getInstance().selectedPost;
			var shareTitle:String = post.title;
			var postURL:String = post.url;				
			var shareFrom:String = post.feed_name;
			var shareMessage:String = ResourceManager.getInstance().getString('resources', 'SHARE_DEFAULT_MESSAGE').replace('$1',shareFrom).replace('$2',shareTitle).replace('$3',postURL);
			shareMessage = escape(shareMessage);
			var shareURL:String;
			
			var shareType:int = ShareSelectedPostEvent(ce).shareType;
			switch (shareType)
			{
				case ShareSelectedPostEvent.FACEBOOK:
					shareURL = "http://www.facebook.com/share.php?u=" + postURL;											
					break;
				case ShareSelectedPostEvent.DELICIOUS:
					shareURL = "http://del.icio.us/post?url=" + postURL + "&title=" + shareTitle;					
					break;
				case ShareSelectedPostEvent.WINDOWS_LIVE:
					shareURL = "https://favorites.live.com/quickadd.aspx?&url=" + postURL + "&title=" + shareTitle;					
					break;
				case ShareSelectedPostEvent.DIGG:
					shareURL = "http://digg.com/submit?phase=2&url=" + postURL + "&title=" + shareTitle;					
					break;
				case ShareSelectedPostEvent.GOOGLE_BOOKMARKS:					
					shareURL = "http://www.google.com/bookmarks/mark?op=edit&bkmk=" + postURL + "&title=" + shareTitle;					
					break;
				case ShareSelectedPostEvent.MYSPACE:
					shareURL = "http://www.myspace.com/Modules/PostTo/Pages/?l=3&u=" + postURL + "&t=" + shareTitle;
					break;				
				case ShareSelectedPostEvent.NEWSVINE:
					shareURL = "http://newsvine.com/_tools/seed&save?u=" + postURL + "&h=" + shareTitle;
					break;
				case ShareSelectedPostEvent.EMAIL_GMAIL:
					shareURL = "https://mail.google.com/mail/?fs=1&view=cm&su=" + shareTitle + "&body=" + shareMessage; 
					break;
				case ShareSelectedPostEvent.EMAIL_HOTMAIL:
					shareURL = "http://www.hotmail.msn.com/secure/start?action=compose&subject=" + shareTitle + "&body=" + shareMessage;
					break;
				case ShareSelectedPostEvent.EMAIL_YAHOO:
					shareURL = "http://compose.mail.yahoo.com/?Subject=" + shareTitle + "&Body=" + shareMessage;
					//for some reason, Yahoo cannot handle escaped apostrophes
					shareURL = shareURL.replace(new RegExp("%27","g"),"%60");					 
					break;
				case ShareSelectedPostEvent.EMAIL_DEFAULT_CLIENT:
					shareURL = "mailto:?subject=" + shareTitle + "&body=" + shareMessage;
					break;
				default:
					break;
			}				
			if ( shareURL )
			{
				navigateToURL(new URLRequest(shareURL));
			}
		}
	}
}
