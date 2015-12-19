////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2003-2006 Adobe Macromedia Software LLC and its licensors.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package com.adobe.empdir.controls
{
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

import mx.controls.ComboBox;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.events.ListEvent;

use namespace mx_internal;

/**
 *  Dispatched when the <code>typedText</code> property changes.
 *
 *  You can listen for this event and update the component
 *  when the <code>typedText</code> property changes.</p>
 * 
 *  @eventType flash.events.Event
 */
[Event(name="typedTextChange", type="flash.events.Event")]


/**
 * Dispatched when the user has hit ENTER and made a selection.
 * 
 * @eventType flash.events.Event
 */ 
[Event(name="selectionChange", type="flash.events.Event")]

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="editable", kind="property")]

/**
 * 
 * The CustomAutoComplete control is a customized version of the 
 * AutoComplete control used to work with an external, asychronously
 * updating data source.  
 * 
 * 
 *  The AutoComplete control is an enhanced 
 *  TextInput control which pops up a list of suggestions 
 *  based on characters entered by the user. These suggestions
 *  are to be provided by setting the <code>dataProvider
 *  </code> property of the control.
 *  @mxml
 *
 *  <p>The <code>&lt;fc:AutoComplete&gt;</code> tag inherits all the tag attributes
 *  of its superclass, and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;fc:AutoComplete
 *    <b>Properties</b>
 *    lookAhead="false"
 *    typedText=""
 *
 *    <b>Events</b>
 *    typedTextChange="<i>No default</i>"
 *    
 *  /&gt;
 *  </pre>
 *

 *  @see mx.controls.ComboBox
 *
 */
public class CustomAutoComplete extends ComboBox 
{

	//--------------------------------------------------------------------------
	//
	//  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     */
	public function CustomAutoComplete()
	{
	    super();

	    //Make ComboBox look like a normal text field
	    editable = true;

	    setStyle("arrowButtonWidth",0);
		setStyle("fontWeight","normal");
		setStyle("cornerRadius",0);
		setStyle("paddingLeft",0);
		setStyle("paddingRight",0);
		rowCount = 7;
		
		addEventListener( "change", onSelectionChange );
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private var cursorPosition:Number=0;

	/**
	 *  @private
	 */
	private var prevIndex:Number = -1;

	/**
	 *  @private
	 */
	private var removeHighlight:Boolean = false;	

	/**
	 *  @private
	 */
	private var showDropdown:Boolean=false;

	/**
	 *  @private
	 */
	private var showingDropdown:Boolean=false;



	
	/**
	 *  @private
	 */
	private var dropdownClosed:Boolean=true;

	//--------------------------------------------------------------------------
	//
	//  Overridden Properties
	//
	//--------------------------------------------------------------------------

 	//----------------------------------
	//  editable
	//----------------------------------
	/**
	 *  @private
	 */
 	override public function set editable(value:Boolean):void
	{
	    //This is done to prevent user from resetting the value to false
	    super.editable = true;
	}
	/**
	 *  @private
	 */
 	override public function set dataProvider(value:Object):void
	{
		super.dataProvider = value;
	}

	//----------------------------------
	//  labelField
	//----------------------------------
	/**
	 *  @private
	 */
 	override public function set labelField(value:String):void
	{
		super.labelField = value;
		
		invalidateProperties();
		invalidateDisplayList();
	}


	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------



	//----------------------------------
	//  lookAhead
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the lookAhead property.
	 */
	private var _lookAhead:Boolean=false;

	/**
	 *  @private
	 */
	private var lookAheadChanged:Boolean;

	[Bindable("lookAheadChange")]
	[Inspectable(category="Data")]

	/**
	 *  lookAhead decides whether to auto complete the text in the text field
	 *  with the first item in the drop down list or not. 
	 *
	 *  @default "false"
	 */
	public function get lookAhead():Boolean
	{
		return _lookAhead;
	}

	/**
	 *  @private
	 */
	public function set lookAhead(value:Boolean):void
	{
		_lookAhead = value;
		lookAheadChanged = true;
	}

	//----------------------------------
	//  typedText
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the typedText property.
	 */
	private var _typedText:String="";

	/**
	 *  @private
	 */
	private var typedTextChanged:Boolean;


	/**
	 * @private
	 */ 
    private var collectionChanged : Boolean;
    
	[Bindable("typedTextChange")]
	[Inspectable(category="Data")]
	/**
	 *  A String to keep track of the text changed as 
	 *  a result of user interaction.
	 */
	public function get typedText():String
	{
	    return _typedText;
	}

	/**
	 *  @private
	 */
	public function set typedText(input:String):void
	{
	    _typedText = input;
	    typedTextChanged = true;
			
	    invalidateProperties();
		invalidateDisplayList();
		dispatchEvent(new Event("typedTextChange"));
	}

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	override protected function commitProperties():void
	{
	    super.commitProperties();
		
  	    if(!dropdown)
			selectedIndex=-1;
  			
	    if(dropdown)
		{
		    if( typedTextChanged || collectionChanged )
		    {
			    cursorPosition = textInput.selectionBeginIndex;

			    //In case there are no suggestions there is no need to show the dropdown
  			    if(collection.length==0 || typedText==""|| typedText==null)
  			    {
  			    	dropdownClosed=true;
			    	showDropdown=false;
			    	close();
  			    }
				else
				{	
					showDropdown = true;
					selectedIndex = -1;
 		    	}
 		    }
 		    
 		    
		}
	}

	
	/**
	 *  @private
	 */
	override public function getStyle(styleProp:String):*
	{
		if(styleProp != "openDuration")
			return super.getStyle(styleProp);
		else
		{
	     	if(dropdownClosed)
	     		return super.getStyle(styleProp);
     		else
     			return 0;
		}
	}
	
	
	/**
	 *  @private
	 */
	override protected function keyDownHandler(event:KeyboardEvent):void
	{
	    super.keyDownHandler(event);

	    if(!event.ctrlKey)
		{
		    //An UP "keydown" event on the top-most item in the drop-down
		    //or an ESCAPE "keydown" event should change the text in text
		    // field to original text
		    if(event.keyCode == Keyboard.UP && prevIndex==0)
			{
	 		    textInput.text = _typedText;
			    textInput.setSelection(textInput.text.length, textInput.text.length);
			    selectedIndex = -1; 
			}
		    else if(event.keyCode==Keyboard.ESCAPE && showingDropdown)
			{
	 		    textInput.text = _typedText;
			    textInput.setSelection(textInput.text.length, textInput.text.length);
			    showingDropdown = false;
			    dropdownClosed=true;
			}
			else if(event.keyCode == Keyboard.ENTER)
			{
				if ( selectedIndex == -1 && dropdown )
				{
					selectedIndex = 0;
					dispatchEvent( new Event( "selectionChange" ) );
				}
 			}
			else if(lookAhead && event.keyCode ==  Keyboard.BACKSPACE 
			|| event.keyCode == Keyboard.DELETE)
			    removeHighlight = true;
	 	}
	 	else
		    if(event.ctrlKey && event.keyCode == Keyboard.UP)
		    	dropdownClosed=true;
	 	
 	    prevIndex = selectedIndex;
	}
	
	/**
	 *  @private
	 */
	override protected function measure():void
	{
	    super.measure();
	    measuredWidth = mx.core.UIComponent.DEFAULT_MEASURED_WIDTH;
	}

	override protected function collectionChangeHandler(event:Event):void
	{
		if ( event is CollectionEvent )
		{
			var kind : String = CollectionEvent( event ).kind;
			
			// RESET is what is currently getting invoked for our implementation
			// UPDATE can get called when updating an item within the collection, so we ignore that.
			// The other cases are put in because they would seemingly make sense.
			switch ( kind ) 
			{
				case CollectionEventKind.ADD:
				case CollectionEventKind.REMOVE:
				case CollectionEventKind.RESET:
				case CollectionEventKind.REPLACE:
				{
					collectionChanged = true;
					invalidateProperties();	
					break;
				}
			}
			
			
		}
		
	}
	
	override public function setFocus():void
    {
    	super.setFocus();
    }
    
	
	/**
	 *  @private
	 */
	override protected function updateDisplayList(unscaledWidth:Number, 
						      unscaledHeight:Number):void
	{
	    super.updateDisplayList(unscaledWidth, unscaledHeight);
	    
	    
	    // needed to make visual artifact go away completely.
	    mx_internal::downArrowButton.visible = false;
		
		//An UP "keydown" event on the top-most item in the drop 
		//down list otherwise changes the text in the text field to ""
  	    if( selectedIndex == -1  )
  	    {
	    	textInput.text = typedText;
	    	typedTextChanged = false;
  	    }
	    if(dropdown)
		{
			
		    if(typedTextChanged || collectionChanged)
			{
			    //This is needed because a call to super.updateDisplayList() set the text
			    // in the textInput to "" and thus the value 
			    //typed by the user losts
  			    if(lookAhead && showDropdown && typedText!="" && !removeHighlight)
				{
					var label:String = itemToLabel(collection[0]);
					var index:Number =  label.toLowerCase().indexOf(_typedText.toLowerCase());
					if(index==0)
					{
					    textInput.text = _typedText+ label.substr(_typedText.length);
					    textInput.setSelection(textInput.text.length,_typedText.length);
					}
					else
					{
					    textInput.text = _typedText;
					    textInput.setSelection(cursorPosition, cursorPosition);
					    removeHighlight = false;
					}
						
				}
			    else
				{
				    textInput.text = _typedText;
				    textInput.setSelection(cursorPosition, cursorPosition);
				    removeHighlight = false;
				}
			    
			    typedTextChanged = false;
			    collectionChanged = false;
			}
		    else if(typedText)
		    	//Sets the selection when user navigates the suggestion list through
		    	//arrows keys.
				textInput.setSelection(_typedText.length,textInput.text.length);
		}
		
 	    if(showDropdown && !dropdown.visible)
 	    {
 	    	//This is needed to control the open duration of the dropdown
 	    	super.open();
	    	showDropdown = false;
 	    	showingDropdown = true;

 	    	if(dropdownClosed)
	 	    	dropdownClosed=false;
 	    }
	}
	

	/**
	 *  @private
	 */
	override protected function textInput_changeHandler(event:Event):void
	{
	    super.textInput_changeHandler(event);
	    //Stores the text typed by the user in a variable
	    typedText=text;
	}
	
	

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
				
	private function onSelectionChange( evt:ListEvent = null ) : void
	{
		// When the index is -1, that means we're typing in the field.
		if ( selectedIndex != -1 )
		{
			dispatchEvent( new Event( "selectionChange" ) );
		}
	}	
}	
}
