/**
 * CLASS
 *      WidgetTools
 * DESCRIPTION
 *      Provides a convenience way to controll Dojo widgets. 
 * USAGE
 *      // all class' public members are static:
        WidgetTools.hideWidget()
 * @class
 * @public
 */
WidgetTools = function() {
}

/**
 * Enables the given widget, provided it has an 'enable-disable' mechanism.
 * @method
 * @public
 * @static
 * @param widget { Object }
 *      The Dojo widget to enable.
 */
WidgetTools.enable = function(widget) {
    if (
        (widget instanceof dijit.form.CheckBox)    ||
        (widget instanceof dijit.form.RadioButton) ||
        (widget instanceof dijit.form.ComboBox)    ||
        (widget instanceof dijit.form.TextBox)     ||
        (widget instanceof dijit.form.Button)      ||
        (widget instanceof dijit.form.DropDownButton)
    ) {
        if(widget.setDisabled) {
            if(widget.disabled){
                widget.setDisabled(false);
            }
        }
    } else if(widget instanceof dijit.TitlePane) {
        var disabledItems = widget.disabledItems;
        if(disabledItems && disabledItems['toggle']) {
        	var originalToggleFunction = disabledItems['toggle'];
        	if(originalToggleFunction) {
        		widget.toggle = originalToggleFunction;
        		delete disabledItems['toggle'];
				var titleDiv = widget.domNode.getElementsByTagName("div")[0];
        		titleDiv.style.opacity = "";
                titleDiv.style.cursor = "pointer";
                if(widget.open) {
		            var descendants = widget.getDescendants();
		            for(var i=0; i<descendants.length; i++) {
		                WidgetTools.enable(descendants[i]);
		            }
                }
        	}
        }
    } else if(widget instanceof dijit.layout.AccordionContainer) {
        var disabledItems = widget.disabledItems;
        if(disabledItems && disabledItems['selectChild']) {
        	var originalSelectChildFunction = disabledItems['selectChild'];
        	if(originalSelectChildFunction) {
	            widget.selectChild = originalSelectChildFunction;
	            delete disabledItems['selectChild'];
	            var children = widget.getChildren();
	            for(var i=0; i<children.length; i++) {
	                var titleDomEl = children[i].domNode
	                  .getElementsByTagName('div')[0]; 
	                titleDomEl.style.opacity = "";
	                titleDomEl.style.cursor = "pointer";
	            }
	            var descendants = widget.getDescendants();
	            for(var j=0; j<descendants.length; j++) {
	                WidgetTools.enable(descendants[j])
	            }
        	}
        }
    }
}

/**
 * Disables the given widget, provided it has an 'enable-disable' mechanism.
 * @method
 * @public
 * @static
 * @param widget { Object }
 *      The Dojo widget to disable.
 */
WidgetTools.disable = function(widget) {
	if (
		(widget instanceof dijit.form.CheckBox)    ||
		(widget instanceof dijit.form.RadioButton) ||
		(widget instanceof dijit.form.ComboBox)    ||
		(widget instanceof dijit.form.TextBox)     ||
		(widget instanceof dijit.form.Button)      ||
		(widget instanceof dijit.form.DropDownButton)
	) {
		if(widget.setDisabled) {
			if(!widget.disabled){
				widget.setDisabled(true);
			}
		}
	} else if(widget instanceof dijit.TitlePane) {
		var disabledItems = widget.disabledItems || (widget.disabledItems = {});
		if(!disabledItems['toggle']) {
			disabledItems['toggle'] = widget.toggle;
			widget.toggle = function(){};
			var titleDomEl = widget.domNode.getElementsByTagName("div")[0];
			titleDomEl.style.opacity = "0.4";
			titleDomEl.style.cursor = "default";
            if(widget.open) {
				var descendants = widget.getDescendants();
				for(var i=0; i<descendants.length; i++) {
					WidgetTools.disable(descendants[i]);
				}
            }
		}
    } else if(widget instanceof dijit.layout.AccordionContainer) {
        var disabledItems = widget.disabledItems || (widget.disabledItems = {});
        if(!disabledItems['selectChild']) {
            disabledItems['selectChild'] = widget.selectChild;
            widget.selectChild = function(){};
            var children = widget.getChildren();
            for(var i=0; i<children.length; i++) {
	        	var titleDomEl = children[i].domNode
	        	  .getElementsByTagName('div')[0]; 
            	titleDomEl.style.opacity = "0.4";
            	titleDomEl.style.cursor = "default";
            }
            var descendants = widget.getDescendants();
            for(var j=0; j<descendants.length; j++) {
            	WidgetTools.disable(descendants[j]);
            }
        }
    }
}

/**
 * Brings the given widget into layout flow.
 * @method
 * @public
 * @static
 * @param widget { Object }
 *      The Dojo widget to show.
 */
WidgetTools.show = function(widget) {
    widget.domNode.style.display = "";
}

/**
 * Removes the given widget from the layout flow.
 * @method
 * @public
 * @static
 * @param widget { Object }
 *      The Dojo widget to hide.
 */
WidgetTools.hide = function(widget) {
    widget.domNode.style.display = "none";
}

/**
 * Will only apply to a few layout controll widgets that have the ability to
 * host content. 'Activating' a widget will make it reveal its content 
 * (namely, by expanding or switching to a certain tab).
 * @method
 * @public
 * @static
 * @param widget { Object }
 *      The parent widget that needs to activate (itself or one of its children)
 * @param childIndex { Number }
 *      Optional. The child widget's numeric index to be activated, should the
 *      widget have children.
 */
WidgetTools.activate = function(widget, childIndex) {
	if(widget instanceof dijit.TitlePane) {
		if(!widget.open) {
			widget.toggle();
		}
	} else if(widget instanceof dijit.layout.AccordionContainer) {
		if(typeof childIndex == "number") {
			var children = widget.getChildren();
			if(childIndex < children.length) {
				widget.selectChild(children[childIndex]);
			}
		}
	} else if(widget instanceof dijit.layout.TabContainer) {
		if(typeof childIndex == "number") {
            var children = widget.getChildren();
            if(childIndex < children.length) {
            	var child = children[childIndex];
            	WidgetTools.show(child.controlButton);
                widget.selectChild(child);
                child.activated = true;
            }
		}
	} else {
		widget.domNode.style.visibility = "visible";
	}
}

/**
 * Will only apply to a few layout controll widgets that have the ability to
 * host content. 'Deactivating' a widget will make it conceal its content 
 * (namely, by collapsing or switching to a different tab).
 * @method
 * @public
 * @static
 * @param widget { Object }
 *      The parent widget that needs to deactivate (itself or one of its
 *      children)
 * @param childIndex { Number }
 *      Optional. The child widget's numeric index to be deactivated, should the
 *      widget have children.
 */
WidgetTools.deactivate = function(widget, childIndex) {
    if(widget instanceof dijit.TitlePane) {
        if(widget.open) {
            widget.toggle();
        }
    } else if(widget instanceof dijit.layout.AccordionContainer) {
        widget.selectChild(null);
    } else if(widget instanceof dijit.layout.TabContainer) {
        if(typeof childIndex == "number") {
            var children = widget.getChildren();
            if(childIndex < children.length) {
                var child = children[childIndex];
                WidgetTools.hide(child);
                WidgetTools.hide(child.controlButton);
                child.deactivated = true;
                var searchDirection = -1;
                var indexToSelect = childIndex;
                while((indexToSelect = indexToSelect + searchDirection) >= 0) {
                	if(!children[indexToSelect].deactivated){
                		WidgetTools.activate(widget, indexToSelect);
                		return;
                	}
                }
                searchDirection = 1;
                var indexToSelect = childIndex;
                while((indexToSelect = indexToSelect + searchDirection) 
                    < children.length) {
                	if(!children[indexToSelect].deactivated){
                		WidgetTools.activate(widget, indexToSelect);
                		return;
                	}
                }
            }
        }
    } else {
    	widget.domNode.style.visibility = "hidden";
    }
}