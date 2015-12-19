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
	import com.adobe.air.alert.NativeAlert;
	import com.adobe.apprise.events.ExportFeedsEvent;
	import com.adobe.apprise.model.ModelLocator;
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.desktop.NativeApplication;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.collections.ArrayCollection;
	import mx.resources.ResourceManager;
	
	public class ExportFeedsCommand implements ICommand
	{
		public function execute(ce:CairngormEvent):void
		{
			var saveFile:File = ExportFeedsEvent(ce).feedFile;

					var feeds:ArrayCollection = ModelLocator.getInstance().feeds;
					if (feeds == null || feeds.length == 0) return;

					XML.prettyIndent = 4;

					var opml:XML = <opml version="1.0"/>
					opml.appendChild(<head><title>Export From ShareFire</title></head>);
					var body:XML = <body/>
					opml.appendChild(body);

					for each (var node:Object in feeds)
					{
						createXMLFromTree(node, body);
					}

					var fs:FileStream = new FileStream();
					fs.open(saveFile, FileMode.WRITE);
					fs.writeUTFBytes("<?xml version=\"1.0\" encoding=\"utf-8\"?>\n" + opml.toXMLString());
					fs.close();
					NativeAlert.show(ResourceManager.getInstance().getString('resources', 'EXPORTFEEDSCOMMAND_EXPORT_COMPLETE_MESSAGE'),
									 ResourceManager.getInstance().getString('resources', 'EXPORTFEEDSCOMMAND_EXPORT_COMPLETE_TITLE'),
									 NativeAlert.OK,
									 true,
									 NativeApplication.nativeApplication.openedWindows[0]);
		}
		
		private function createXMLFromTree(node:Object, xmlTarget:XML):void
		{
			if ( node.is_folder ) 
			{
				xmlTarget.appendChild(expressFolderAsXML(node));
			}
			else 
			{
				xmlTarget.appendChild(expressFeedAsXML(node));
			}
		}
	
		private function expressFolderAsXML(folder:Object):XML
		{
			var outline:XML = <outline/>
			if ( folder.name ) 
			{
				outline.@title = folder.name;
			}
			if ( folder.children ) 
			{
				for each ( var child:Object in folder.children ) 
				{
					createXMLFromTree(child, outline);
				}
			}
			return outline;	
		}
	
		//takes the object and returns it as an <outline title="..." xmlUrl="xs..."/> XML object	
		private function expressFeedAsXML(feed:Object):XML
		{
			var outline:XML = <outline/>
			if ( feed.custom_name ) 
			{
				outline.@title = feed.custom_name;
			}
			else if ( feed.name )
			{
				outline.@title = feed.name;
			}
			if ( feed.feed_url )
			{
				outline.@xmlUrl = feed.feed_url;
			}
			if ( feed.site_url )
			{
				outline.@htmlUrl = feed.site_url;
			}
			return outline;
		}
	} 
}
