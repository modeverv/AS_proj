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
	import com.adobe.apprise.database.DatabaseEvent;
	import com.adobe.apprise.database.DatabaseResponder;
	import com.adobe.apprise.events.PrunePostsEvent;
	import com.adobe.apprise.events.RefreshCountsEvent;
	import com.adobe.apprise.model.ModelLocator;
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	
	public class PrunePostsCommand implements ICommand
	{
		
		private var _firstInvalidPostId:int;
		private var ppe:PrunePostsEvent;
		
		public function execute(ce:CairngormEvent):void
		{
			this.ppe = ce as PrunePostsEvent;

			if (ModelLocator.getInstance().currentlyAggregating)
			{
				if (ppe.responder != null)
				{
					ppe.responder.dispatchEvent(new Event(Event.COMPLETE));
				}
				return;
			}

			var responder:DatabaseResponder = new DatabaseResponder();
			responder.addEventListener(DatabaseEvent.RESULT_EVENT,
				function(e:DatabaseEvent):void
				{										
					_firstInvalidPostId = (e.data as int) + 1;
					//delete posts, authors, and topics that have ids less than this item
					deleteTopics();
				});
			ModelLocator.getInstance().db.getPrunePostId(responder);		
		}
				
		private function deleteTopics():void
		{
			var responder:DatabaseResponder = new DatabaseResponder();
			responder.addEventListener(DatabaseEvent.RESULT_EVENT, deleteAuthors);
			ModelLocator.getInstance().db.deleteTopicsLessThanPostId(responder, _firstInvalidPostId);									
		}
		
		private function deleteAuthors(e:Event):void
		{
			var responder:DatabaseResponder = new DatabaseResponder();
			responder.addEventListener(DatabaseEvent.RESULT_EVENT, deletePosts);
			ModelLocator.getInstance().db.deleteAuthorsLessThanPostId(responder, _firstInvalidPostId);										
		}
		
		private function deletePosts(e:Event):void
		{
			var responder:DatabaseResponder = new DatabaseResponder();
			responder.addEventListener(DatabaseEvent.RESULT_EVENT,
				function(e:Event):void
				{	
					new RefreshCountsEvent().dispatch();
					if (ppe.responder != null)
					{
						ppe.responder.dispatchEvent(new Event(Event.COMPLETE));
					}
				});
			ModelLocator.getInstance().db.deletePostsLessThanPostId(responder, _firstInvalidPostId);													
		}
	}
}
