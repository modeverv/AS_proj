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

package jp.fores.common.controls
{
	import mx.controls.TextInput;
	import flash.events.FocusEvent;

	/**
	 * A text input that displays a gray label inside itself when it's empty.  When the user clicks in,
	 * the label disappears.  If the user exits the field and leaves it empty, the label reappears.
	 * 
	 * TODO: get the label color from a style instead of hard-coding it.
	 *
	 * @author Narciso Jaramillo <nj_flex@rictus.com>
	 */
	 
	public class SelfLabelingTextInput extends TextInput
	{
		private var _textIsEmpty: Boolean = true;
		private var _label: String;
		
		/**
		 * The label to display when the text field is empty.
		 */
		public function get label(): String {
			return _label;
		}
		
		public function set label(value: String): void {
			_label = value;
			toolTip = value;
			updateContents();
		}
		
		[Bindable]
		override public function get text(): String {
			if (_textIsEmpty) {
				return "";
			}
			else {
				return super.text;
			}
		}
		
		override public function set text(value: String): void {
			if (value == "") {
				_textIsEmpty = true;
			}
			else {
				_textIsEmpty = false;
				super.text = value;
			}
			updateContents();
		}
		
		private function updateContents(): void {
			if (_textIsEmpty) {
				setStyle("color", 0xaaaaaa);
				super.text = _label;
			}
			else {
				setStyle("color", 0x000000);
			}
		}

		
		private function handleTextChange(event: Event): void {
			if (super.text == "") {
				_textIsEmpty = true;
			}
			else {
				_textIsEmpty = false;
			}
		}
		
		private function handleFocusIn(event: FocusEvent): void {
			if (_textIsEmpty) {
				super.text = "";
				setStyle("color", 0x000000);
			}
		}
		
		private function handleFocusOut(event: FocusEvent): void {
			updateContents();
		}
		
		override public function initialize(): void {
			super.initialize();
			addEventListener(Event.CHANGE, handleTextChange);
			addEventListener(FocusEvent.FOCUS_IN, handleFocusIn);
			addEventListener(FocusEvent.FOCUS_OUT, handleFocusOut);
			updateContents();
		}
	}
}