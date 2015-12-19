/*
 * Copyright 2007-2008. Adobe Systems Incorporated.
 * All rights reserved.
 */

Ext.tree.TreeFolderEditor = function(tree, config){
	config = config || {};
	var field = config.events ? config : new Ext.form.TextField(config);
	Ext.tree.TreeFolderEditor.superclass.constructor.call(this, field);

	this.tree = tree;

	if(!tree.rendered){
		tree.on('render', this.initEditor, this);
	}else{
		this.initEditor(tree);
	}
};

Ext.extend(Ext.tree.TreeFolderEditor, Ext.Editor, {
    
	alignment: "l-l",
	autoSize: false,
    
	hideEl : false,
    
	cls: "x-small-editor x-tree-editor",
    
	shim:false,
	shadow:"frame",
    
	maxWidth: 250,
    
	editDelay : 350,

	initEditor : function(tree){
		tree.on('beforeclick', this.beforeNodeClick, this);
		this.on('complete', this.updateNode, this);
		this.on('beforestartedit', this.fitToTree, this);
		this.on('startedit', this.bindScroll, this, {delay:10});
		this.on('specialkey', this.onSpecialKey, this);
    },

	fitToTree : function(ed, el){
		var td = this.tree.getTreeEl().dom, nd = el.dom;
		if(td.scrollLeft >  nd.offsetLeft){
			td.scrollLeft = nd.offsetLeft;
		}
		var w = Math.min(
				this.maxWidth,
				(td.clientWidth > 20 ? td.clientWidth : td.offsetWidth) - Math.max(0, nd.offsetLeft-td.scrollLeft) - 5);
		this.setSize(w, '');
	},

	triggerEdit : function(node){
		this.completeEdit();
		this.editNode = node;
		this.startEdit(node.ui.textNode, node.text);
	},

	bindScroll : function(){
		this.tree.getTreeEl().on('scroll', this.cancelEdit, this);
	},

	beforeNodeClick : function(node, e){
		var sinceLast = (this.lastClick ? this.lastClick.getElapsed() : 0);
		this.lastClick = new Date();
		if(sinceLast > this.editDelay && this.tree.getSelectionModel().isSelected(node)){
			e.stopEvent();
			this.triggerEdit(node);
			return false;
		}
	},

	updateNode : function(ed, value){
		this.tree.getTreeEl().un('scroll', this.cancelEdit, this);
		this.editNode.setText(value);
	},

	onHide : function(){
		Ext.tree.TreeFolderEditor.superclass.onHide.call(this);
		if(this.editNode){
			this.editNode.ui.focus();
		}
	},

	onSpecialKey : function(field, e){
		var k = e.getKey();
		if(k == e.ESC){
			e.stopEvent();
			this.cancelEdit();
		}else if(k == e.ENTER && !e.hasModifier()){
			e.stopEvent();
			this.completeEdit();
		}
	}
});