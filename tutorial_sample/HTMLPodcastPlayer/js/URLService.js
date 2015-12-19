// Copyright (c) 2007. Adobe Systems Incorporated.
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
//   * Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//   * Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//   * Neither the name of Adobe Systems Incorporated nor the names of its
//     contributors may be used to endorse or promote products derived from this
//     software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

var Podcast; if (!Podcast) Podcast = {};

Podcast.URLService = function() {
	this.initialize.apply(this, arguments);
}

Podcast.URLService.prototype  = {
	url: null,
	loader: null,
	cbs: {},
	//
	initialize: function(url, callbacks) {
		this.url = url;
		this.cbs = callbacks;
	},
	
	send: function() {
		air.trace("Loading: " + this.url);
		this.loader = new air.URLLoader();
		var request = new air.URLRequest(this.url);
		
		this.loader.addEventListener(air.Event.COMPLETE, this.onLoadComplete.createCallback(this));
        this.loader.addEventListener(air.IOErrorEvent.IO_ERROR, this.onIOError.createCallback(this));
        this.loader.addEventListener(air.ProgressEvent.PROGRESS, this.onLoadProgress.createCallback(this));
        this.loader.addEventListener(air.SecurityErrorEvent.SECURITY_ERROR, this.onSecurityError.createCallback(this));
        this.loader.addEventListener(air.HTTPStatusEvent.HTTP_STATUS, this.onHTTPStatus.createCallback(this));
            
        this.loader.load(request);			
	},
	
	onLoadComplete: function(event) {
		air.trace("LoadComplete: " + event);
		var loaded = event.target;
		if (loaded != null && loaded.data != null)
		{
			if (this.cbs.loadComplete) this.cbs.loadComplete({data: loaded.data});
		}
		else
		{
			air.trace("No data was received.");
			if (this.cbs.IOError) this.cbs.IOError({text: "No data was received."});
		}
	},
	
	onHTTPStatus: function(event) {
		air.trace("HTTPStatus: " + event.status);
		if (this.cbs.httpStatus) this.cbs.httpStatus(event);		
	},
	
	onLoadProgress: function(event) {
		air.trace("Progress: " + event.bytesLoaded + "/" + event.bytesTotal + " = " + 100 * (event.bytesLoaded / event.bytesTotal) + "%");
		if (this.cbs.loadProgress) this.cbs.loadProgress(event);	
	},
	
	onIOError: function(event) {
		air.trace("IOError: " + event.text);
		if (this.cbs.IOError) this.cbs.IOError(event);
	},
	
	onSecurityError: function(event) {
		air.trace("SecurityError: " + event.text);		
		if (this.cbs.securityError) this.cbs.securityError(event);		
	}
};
