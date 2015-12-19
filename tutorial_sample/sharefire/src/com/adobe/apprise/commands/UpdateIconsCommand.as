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
	import com.adobe.apprise.model.ModelLocator;
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.desktop.InteractiveIcon;
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class UpdateIconsCommand implements ICommand
	{
		
		public function execute(ce:CairngormEvent):void
		{
			var ml:ModelLocator = ModelLocator.getInstance();
			
			if (!NativeApplication.nativeApplication.icon is InteractiveIcon || !NativeApplication.supportsDockIcon ) return; // Windows/Linux icons are too small for ##, ###, or ####
			
			var responder:DatabaseResponder = new DatabaseResponder();
			responder.addEventListener(DatabaseEvent.RESULT_EVENT,
				function(e:DatabaseEvent):void
				{
					var unreadPosts:Number = (e.data >= 0) ? e.data : 0;					
					
					// Create a dynamic icon, showing the number of new posts per update
					var postsSprite:Sprite = new Sprite();
					postsSprite.width = 128;
					postsSprite.height = 128;

					var postsText:TextField = new TextField();
					postsText.width = 128;
					postsText.height = 30;
					postsText.x = -7;
					postsText.y = 2;						
					postsText.autoSize = TextFieldAutoSize.RIGHT; 
					var textFormat:TextFormat = new TextFormat("Arial",23,0xFFFFFF, true);						
					postsText.text = (Math.abs(unreadPosts) > 99999999) ? String.fromCharCode("931","185","8260","8339") : String(unreadPosts); // Read your news already.										
					postsText.setTextFormat(textFormat);																									
					
					var colors:Array = [0x0033FF, 0x000099];
					var alphas:Array = [0.9,0.7];
					var ratios:Array = [0,255];
					var matrix:Matrix = new Matrix();
					
					matrix.createGradientBox(60,30,45,75,5);
					postsSprite.graphics.beginGradientFill(GradientType.LINEAR,colors,alphas,ratios,matrix);

					postsSprite.graphics.drawRoundRect(postsText.x-2,4,postsText.width+3,26,15); 
					postsSprite.graphics.endFill();
										
					postsSprite.addChild(postsText);
					
					var postsData:BitmapData = new BitmapData(128,128,true,0x00000000);
					postsData.draw(postsSprite);
					var appData:BitmapData = new ml.appIconClass().bitmapData;			
					appData.copyPixels(postsData, 
													new Rectangle(0,0, postsData.width, postsData.height),
													new Point(0,0), 
													null,null,true);				
					ml.appIcon = new Bitmap(appData);

					InteractiveIcon(NativeApplication.nativeApplication.icon).bitmaps = [ml.appIcon];						
				});			
			ml.db.getUnreadCount(responder);											
		}
	}
}
