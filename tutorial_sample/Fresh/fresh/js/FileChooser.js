/*
 * Copyright 2007-2008. Adobe Systems Incorporated.
 * All rights reserved.
 */


 
var Fresh;
if (!Fresh) Fresh = {};

    Fresh.FileChooser = {};
    Fresh.FileChooser.dir = null;                  	// The current directory in the list.
    Fresh.FileChooser.initialList = true;       // Whether the listFiles() method is processing the first list for the window.
    Fresh.FileChooser.files = null;                    // The list of files in the current directory.	
    Fresh.FileChooser.selectedFile = null;

    Fresh.FileChooser.initFileChooser = function(dom) {
		Fresh.FileChooser.initialList = true;
		Fresh.FileChooser.dir = runtime.flash.filesystem.File.documentsDirectory;
		Fresh.FileChooser.listFiles(Fresh.FileChooser.dir);
    };
		
		/** Lists contents (files and subdirectories) of the dir directory, and 
		/* renders them as DIV elements in the fileList frame.
		 */
     Fresh.FileChooser.listFiles = function(dir) {
		var retStr = "";
		if (dir.parent != null) {
			upDivStr = "<div onclick='Fresh.FileChooser.selectDiv(-1)' id='listDivRoot' ' height='300' class='listDiv'>" 
						+ "<img src='fresh/images/folder_icon.png' width='16' height='16' />" 
						+ "<font face='verdana' size='2'>..</font></div>";
			retStr += upDivStr;
		}
		Fresh.FileChooser.dir = dir;
		Fresh.FileChooser.files = dir.listDirectory();
		for (i = 0; i < Fresh.FileChooser.files.length; i++) {
			var imgTxt;
			if (Fresh.FileChooser.files[i].isDirectory) {
				imgTxt = "<img src='fresh/images/folder_icon.png' width='16' height='16' /> ";
			} else {
				imgTxt = "<img src='fresh/images/file_icon.png' width='16' height='16' /> ";
			}
			var divStr = "<div onclick='Fresh.FileChooser.selectDiv(" + i + ")' "
							+ "id='listDiv" + i + "' height='300' class='listDiv'>" 
								+ imgTxt 
								+ "<font face='Verdana, Geneva, Arial, Helvetica, sans-serif' size='2'>" 
								+ Fresh.FileChooser.files[i].name + "</font>"
						+ "</div>";
		    retStr += divStr;
		}
		initialList = false;
        Ext.get("filebrowser").dom.innerHTML = retStr;
	};
		
		/** Responds to the user clicking a file or directory  in the list. If the user 
		 * clicks a file, this method adds the filename to the filename text field.
		 * If the user clicks the ../ directory, the method updates the directory list to
		 * display the contents of the parent directory. If the user clicks another directory,
		 * the method updates the directory list to display the contents of the selected 
		 * directory.
		 */
     Fresh.FileChooser.selectDiv = function(n) {
		if (n == -1) {
			Fresh.FileChooser.listFiles(Fresh.FileChooser.dir.parent);
		} else {
			var node = Fresh.FileChooser.files[n];
			if (!node.isDirectory) {
				Ext.get("location").dom.innerHTML = node.name;
				Fresh.FileChooser.selectedFile = Fresh.FileChooser.dir.resolve(node.name);
			} else {
				Fresh.FileChooser.listFiles(node);
			}
		}
	};
		
    Fresh.FileChooser.getFile = function() {
		return Fresh.FileChooser.selectedFile;
	};


