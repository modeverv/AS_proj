/*
	Copyright (c) 2006 Narciso Jaramillo <nj_flex@rictus.com>
	
	Permission is hereby granted, free of charge, to any person obtaining
	a copy of this software and associated documentation files (the "Software"),
	to deal in the Software without restriction, including without limitation 
	the rights to use, copy, modify, merge, publish, distribute, sublicense, 
	and/or sell copies of the Software, and to permit persons to whom the 
	Software is furnished to do so, subject to the following conditions:
	
	The above copyright notice and this permission notice shall be included 
	in all copies or substantial portions of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
	IN THE SOFTWARE.
*/

package jp.fores.common.containers
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	
	import jp.fores.common.assets.AssetsConstant;
	import jp.fores.common.controls.SelfLabelingTextInput;
	
	import mx.containers.HBox;
	import mx.controls.Image;
	import mx.controls.TextInput;

	[Event(name="change", type="flash.events.Event")]
	public class SearchBox extends HBox
	{
		private var _textInput: SelfLabelingTextInput;
		private var _label: String;
		
		[Bindable]
		public function get text(): String {
			return _textInput.text;
		}
		public function set text(value: String): void {
			_textInput.text = value;
		}
		
		[Bindable]
		override public function get label(): String {
			return _label;
		}
		override public function set label(value: String): void {
			_label = value;
			if (_textInput != null) {
				_textInput.label = value;
			}
		}

		override protected function createChildren(): void {
			super.createChildren();
			
			setStyle("borderStyle", "solid");
			setStyle("backgroundColor", 0xffffff);
			setStyle("horizontalGap", 0);
			setStyle("paddingLeft", 3);
			setStyle("paddingRight", 3);
			setStyle("cornerRadius", 5);
			setStyle("verticalAlign", "middle");
			
			var image: Image = new Image();
			image.source = AssetsConstant.SEARCH_ICON;
			addChild(image);
			
			_textInput = new SelfLabelingTextInput();
			_textInput.setStyle("borderStyle", "none");
			_textInput.setStyle("focusAlpha", 0);
			_textInput.percentWidth = 100;
			// This is a hack around the fact that we don't have baseline alignment.
			// Without this, the text field doesn't center properly.
			_textInput.height = 18;
			_textInput.addEventListener(Event.CHANGE, handleTextChange);
			_textInput.label = _label;
			addChild(_textInput);
		}
		
		private function handleTextChange(event: Event): void {
			callLater(dispatchEvent, [new Event(Event.CHANGE)]);
		}
	}
}