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

package com.adobe.apprise.controller
{
	import com.adobe.cairngorm.control.FrontController;
	
	public class Controller extends FrontController
	{

		import com.adobe.apprise.events.*;
		import com.adobe.apprise.commands.*;

		public function Controller()
		{
			this.addCommands();
		}
		
		private function addCommands():void
		{
			this.addCommand(InitEvent.INIT_EVENT, InitCommand);
			this.addCommand(ShutdownEvent.SHUTDOWN_EVENT, ShutdownCommand);
			this.addCommand(AddFeedEvent.ADD_FEED_EVENT, AddFeedCommand);
			this.addCommand(AggregateEvent.AGGREGATE_EVENT, AggregateCommand);
			this.addCommand(PopulateViewControlEvent.POPULATE_VIEW_CONTROL_EVENT, PopulateViewControlCommand);
			this.addCommand(RefreshCountsEvent.REFRESH_COUNTS_EVENT, RefreshCountsCommand);
			this.addCommand(ImportFeedsEvent.IMPORT_FEEDS_EVENT, ImportFeedsCommand);
			this.addCommand(ExportFeedsEvent.EXPORT_FEEDS_EVENT, ExportFeedsCommand);
			this.addCommand(RefreshAllEvent.REFRESH_ALL_EVENT, RefreshAllCommand);
			this.addCommand(DeleteFeedEvent.DELETE_FEED_EVENT, DeleteFeedCommand);
			this.addCommand(DeleteFolderEvent.DELETE_FOLDER_EVENT, DeleteFolderCommand);
			this.addCommand(SearchEvent.SEARCH_EVENT, SearchCommand);
			this.addCommand(MarkAllReadEvent.MARK_ALL_READ_EVENT, MarkAllReadCommand);
			this.addCommand(BusyEvent.BUSY_EVENT, BusyCommand);
			this.addCommand(PrunePostsEvent.PRUNE_POSTS_EVENT, PrunePostsCommand);
			this.addCommand(SendTwitterEvent.SEND_TWITTER_EVENT, SendTwitterCommand);
			this.addCommand(AIMInitEvent.AIM_CONNECT_EVENT, AIMInitCommand);
			this.addCommand(SaveSortOrderEvent.SAVE_SORT_ORDER_EVENT, SaveSortOrderCommand);
			this.addCommand(ShareSelectedPostEvent.SHARE_SELECTED_POST_EVENT, ShareSelectedPostCommand);
			this.addCommand(NotifyEvent.NOTIFY_EVENT, NotifyCommand);
			this.addCommand(UpdateIconsEvent.UPDATE_ICONS_EVENT, UpdateIconsCommand);
		}
		
	}
}
