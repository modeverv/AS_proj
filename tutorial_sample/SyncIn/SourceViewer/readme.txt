WHAT IS THIS
------------
The Source Viewer is a plug & play module that allows your end-user to inspect
your HTML-based Air application's source code.


HOW TO INCLUDE
--------------
Insert a link to SourceViewer.js in your application's main HTML file:
<script type="text/javascript" src="SourceViewer.js"></script>


HOW TO USE
----------
The SourceViewer's API only contains two public methods:

	public	viewSource ()
				Opens a new window where the user can browse and open source 
				files of the host application.
				
	public	setup (configObject)
				Applies given settings to the Source Viewer.
				
				Parameters:
				
					configObject 
						An object literal containing configuration directives.
						Currently it only supports one directive:
						
					configObject.exclude 
						An array containing application directory relative paths
						to files or folders to be excluded form listing. 
						Wildcards are not currently supported.


	examples:

	// run the Source Viewer with no configuration (will list everything,
	// including itself): 
	SourceViewer.getDefault().viewSource();

	// setup the Source Viewer to hide himself from listing:
	var browser = SourceViewer.getDefault();
	browser.setup({ exclude:[/SourceViewer.js] });
	browser.viewSource();
