/*
    Adobe Systems Incorporated(r) Source Code License Agreement
    Copyright(c) 2005 Adobe Systems Incorporated. All rights reserved.
    
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
    NON-INFRINGEMENT, TITLE OR QUIET ENJOYMENT.  IN NO EVENT SHALL ADOBE 
    OR ITS SUPPLIERS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
    EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
    PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
    OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
    WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
    OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOURCE CODE, EVEN IF
    ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
package com.adobe.air.notification
{           
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.filters.DropShadowFilter;
    import flash.text.AntiAliasType;
    import flash.text.Font;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.ui.ContextMenu;
	
    public class Notification
        extends AbstractNotification
    {
    	//==========================================================
    	//外部から見た目を変更できるように追加したフィールド
    	
    	/**
    	 * タイトルの文字の色
    	 */
    	public var titleTextColor :uint = 0xFFFFFF;
    	
    	/**
    	 * タイトルの文字のフォント
    	 */
    	public var titleTextFont :String = "Verdana";

    	/**
    	 * メッセージの文字の色
    	 */
    	public var messageTextColor :uint = 0xFFFFFF;
    	
    	/**
    	 * メッセージの文字のフォント
    	 */
    	public var messageTextFont :String = "Verdana";
    	//==========================================================
    	
        private var _message:String;
        private var _title:String;
       	private var _bitmap: Bitmap;

        private var messageLabel :TextField;
       	private var titleLabel :TextField;

        public function Notification(title:String, message:String, position:String = null, duration:uint = 5, bitmap: Bitmap = null)
        {
            super(position, duration);

        	this.title = title;
        	this.message = message;
			this.bitmap = bitmap;

            this.width = 400;
            this.height = 100;
	    }

		/**
		 * 表示される直前の処理を行います。
		 */
		override protected function beforeVisible():void
		{
			//親クラスの処理を先に呼び出す
			super.beforeVisible();
			
			var titleLeftPos: int = (this.bitmap != null) ? 22 : 2;
			var cm:ContextMenu = new ContextMenu();
			cm.hideBuiltInItems();
			
			// title
            this.titleLabel = new TextField();
            this.titleLabel.autoSize = TextFieldAutoSize.LEFT;
            var titleFormat:TextFormat = this.titleLabel.defaultTextFormat;
            titleFormat.font = this.titleTextFont;
            titleFormat.bold = true;
            titleFormat.color = this.titleTextColor;
            titleFormat.size = 10;
			titleFormat.align = TextFormatAlign.LEFT;
            this.titleLabel.defaultTextFormat = titleFormat;
            this.titleLabel.multiline = false;
            this.titleLabel.selectable = false;
            this.titleLabel.wordWrap = false;
            this.titleLabel.contextMenu = cm;
            this.titleLabel.x = titleLeftPos;
            this.titleLabel.y = 2;
			this.titleLabel.width = this.width - 8;
			this.titleLabel.filters = [new DropShadowFilter(5, 45, this.titleTextColor, 0.5)];
            this.getSprite().addChild(this.titleLabel);

			// message            
            this.messageLabel = new TextField();
            this.messageLabel.autoSize = TextFieldAutoSize.NONE;
            var messageFormat:TextFormat = this.messageLabel.defaultTextFormat;
            messageFormat.font = this.messageTextFont;
            messageFormat.color = this.messageTextColor;
            messageFormat.size = 10;
			messageFormat.align = TextFormatAlign.LEFT;
            this.messageLabel.defaultTextFormat = messageFormat;
            this.messageLabel.multiline = true;
            this.messageLabel.selectable = false;
            this.messageLabel.wordWrap = true;
            this.messageLabel.contextMenu = cm;
            this.messageLabel.x = 2;
            this.messageLabel.y = 19;
			this.messageLabel.width = this.width - (this.messageLabel.x + 4);
			this.messageLabel.height = this.height - (this.messageLabel.y + 4);
			this.messageLabel.filters = [new DropShadowFilter(5, 45, this.messageTextColor, 0.5)];
            this.getSprite().addChild(this.messageLabel);


			//==========================================================
            //指定されたフォントが埋め込みフォントの場合は、埋め込みフォント用の設定にする
            
			//埋め込みフォントの配列を取得
			var embedFontArray :Array = Font.enumerateFonts();
			
			//埋め込みフォントの配列がnullまたは空配列で内場合
            if((embedFontArray != null) && (embedFontArray.length != 0))
            {
            	//埋め込みフォントの配列の全ての要素に対して処理を行う
	            for each(var font :Font in embedFontArray)
	            {
	            	//タイトルの文字のフォントが埋め込みフォントだった場合
	            	if(this.titleTextFont == font.fontName)
	            	{
	            		//タイトルのラベルを埋め込みフォント用の設定にする
	            		this.titleLabel.embedFonts = true;
	            		this.titleLabel.antiAliasType = AntiAliasType.ADVANCED;
	            		this.titleLabel.defaultTextFormat.bold = false;
	            		this.titleLabel.thickness = 200;
	            	}
	            	
	            	//メッセージの文字のフォントが埋め込みフォントだった場合
	            	if(this.messageTextFont == font.fontName)
	            	{
	            		//メッセージのラベルを埋め込みフォント用の設定にする
	            		this.messageLabel.embedFonts = true;
	            		this.messageLabel.antiAliasType = AntiAliasType.ADVANCED;
	            	}
	            }
            }

            //==========================================================
            
            //タイトルとメッセージのラベルに指定されたテキストを設定
        	this.titleLabel.text = this._title;
            this.messageLabel.text = this._message;

			//ビットマップが指定されている場合
			if (this.bitmap != null)
			{
				var posX: int = 2;
				var posY: int = 2;
				var scaleX: Number = 1;
				var scaleY: Number = 1;
	            var bitmapData:BitmapData = this.bitmap.bitmapData;
	            if (bitmapData.width > 16 || bitmapData.height > 16)
	            {
            		scaleX = (bitmapData.width > bitmapData.height) ? 16 / bitmapData.width : 16 / bitmapData.height;
	            	scaleY = scaleX;
	            	posX = 10 - ((bitmapData.width * scaleX) / 2);
	            	posY = 10 - ((bitmapData.height * scaleY) / 2);
	            }
	            else
	            {
		            posX = 10 - (bitmapData.width / 2);
		            posY = 10 - (bitmapData.height / 2);					
	            }
	            this.bitmap.scaleX = scaleX;
	            this.bitmap.scaleY = scaleY;
	            this.bitmap.x = posX;
	            this.bitmap.y = posY;
	            this.getSprite().addChild(this.bitmap);
			}
		}

		public function set bitmap(bitmap:Bitmap):void
		{
			this._bitmap = new Bitmap(bitmap.bitmapData);
	    	this._bitmap.smoothing = true;
		}
		
		public function get bitmap():Bitmap
		{
			return this._bitmap;
		}

        public override function set title(title:String):void
        {
        	this._title = title;
        }

        public override function get title():String
        {
            return this._title;
        }

        public function set message(message:String):void
        {
        	this._message = message;
        }

        public function get message():String
        {
            return this._message;
        }

        public override function set width(width:Number):void
        {
			super.width = width;
        }

        public override function set height(height:Number):void
        {
			super.height = height;
        }
                
    }
}