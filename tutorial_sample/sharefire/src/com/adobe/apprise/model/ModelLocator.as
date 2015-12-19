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

package com.adobe.apprise.model
{
	import air.update.ApplicationUpdaterUI;
	
	import com.adobe.air.notification.NotificationQueue;
	import com.adobe.air.preferences.Preference;
	import com.adobe.apprise.aggregator.AggregatorResponder;
	import com.adobe.apprise.database.Database;
	import com.adobe.cairngorm.model.IModelLocator;
	import com.aol.api.wim.Session;
	
	import flash.display.Bitmap;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	
	public class ModelLocator implements com.adobe.cairngorm.model.IModelLocator
	{
		protected static var inst:ModelLocator;
		
        [Embed(source="assets/apprise_dynamic_logo_128.png")]
        public var appIconClass:Class;
		public var appIcon:Bitmap;

		[Bindable] public var languages:ArrayCollection;
		[Bindable] public var statusMessage:String;
		[Bindable] public var db:Database;
		[Bindable] public var isFeedDrawerOpen:Boolean;
		[Bindable] public var feedDrawerDefaultURL:String;
		[Bindable] public var totals:ArrayCollection;
		[Bindable] public var feeds:ArrayCollection;
		[Bindable] public var topics:ArrayCollection;
		[Bindable] public var authors:ArrayCollection;
		[Bindable] public var posts:ArrayCollection;
		[Bindable] public var smartFolders:ArrayCollection;
		[Bindable] public var selectedPost:Object;
		[Bindable] public var selectedFeed:Object;
		[Bindable] public var currentlyAggregating:Boolean;
		[Bindable] public var loadingHtml:Boolean;
		[Bindable] public var stopAggregating:Boolean;
		[Bindable] public var deletedFeedUrls:ArrayCollection;
		[Bindable] public var currentAggregatorResponder:AggregatorResponder;
		[Bindable] public var preferences:Preference;
		[Bindable] public var updateTimer:Timer;
		[Bindable] public var prunePostsTimer:Timer;
		[Bindable] public var feedInfoWindowOpen:Boolean;
		[Bindable] public var preferenceWindowOpen:Boolean;
		[Bindable] public var twitterWindowOpen:Boolean;
		[Bindable] public var autoOpenFolders:Boolean; 
		[Bindable] public var appUpdater:ApplicationUpdaterUI;	
		[Bindable] public var notificationQueue:NotificationQueue;
		
		[Bindable] public var aimSession:Session;
		[Bindable] public var aimBuddies:ArrayCollection;
		[Bindable] public var aimWindowOpen:Boolean;
		[Bindable] public var aimState:String;  //used in AIMStatusBox for changewatching of online status
		[Bindable] public var aimMessageSent:Boolean; 
		
		public var AIM_DEV_KEY:String = "ab19DEFncNpfrbhy"; 
		
		public var EMAIL_SERVICE_GMAIL:uint = 0;
		public var EMAIL_SERVICE_YAHOO:uint = 1;
		public var EMAIL_SERVICE_HOTMAIL:uint = 2;
		public var EMAIL_SERVICE_DEFAULT:uint = 3;
		
		public var MAX_SEARCH_RESULTS:uint = 5000; //used in db.searchPosts

		public function ModelLocator()
		{
		}
		
		public static function getInstance():ModelLocator
		{
			if (inst == null)
			{
				inst = new ModelLocator();
			}
			return inst;
		}

	}
}
