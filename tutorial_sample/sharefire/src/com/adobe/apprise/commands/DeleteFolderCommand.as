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
	import com.adobe.apprise.events.DeleteFeedEvent;
	import com.adobe.apprise.events.DeleteFolderEvent;
	import com.adobe.apprise.model.ModelLocator;
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class DeleteFolderCommand implements ICommand
	{
		public function execute(ce:CairngormEvent):void
		{
			var folderId:Number = DeleteFolderEvent(ce).folderId;
			var _preventAggregation:Boolean = DeleteFolderEvent(ce).preventAggregation;
			
			//get every child of this folder
			var responder:DatabaseResponder = new DatabaseResponder();
			responder.addEventListener(DatabaseEvent.RESULT_EVENT,
				function(e:DatabaseEvent):void
				{
					for each ( var o:Object in e.data ) 
					{
						if ( o.is_folder ) 
						{
							var dFe:DeleteFolderEvent = new DeleteFolderEvent();
							dFe.folderId = o.id;
							dFe.dispatch();
						}
						else 
						{
							var dfe2:DeleteFeedEvent = new DeleteFeedEvent();
							dfe2.feedId = o.id;	
							dfe2.preventAggregation = _preventAggregation;
							dfe2.feedUrl = o.feed_url;						
							dfe2.dispatch();
						}
					}
					
					//delete myself
					var dfe:DeleteFeedEvent = new DeleteFeedEvent();
					dfe.feedId = folderId;
					dfe.dispatch();			
				});
			ModelLocator.getInstance().db.selectByParent(responder,folderId);
		}
	}
}
