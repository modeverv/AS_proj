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

Podcast.SoundPlayer = function () {
	this.initialize(arguments);
}

Podcast.SoundPlayer.prototype  = {
	s: null,
	
	initialize: function() {
		air.trace("Sound.Player initialized");
		this.playBtn = document.getElementById("playBtn");
		this.pauseBtn = document.getElementById("pauseBtn");
		this.stopBtn = document.getElementById("stopBtn");
		this.resumeBtn = document.getElementById("resumeBtn");		
		this.urlTxt = document.getElementById("urlTxt");
		this.titleTxt = document.getElementById("titleTxt");		
		this.autoPlayCb = document.getElementById("autoPlayCb");
		this.playing = document.getElementById("p2");
		this.loading = document.getElementById("l2");
		this.playingMessage = document.getElementById("p2Message");
		this.loadingMessage = document.getElementById("l2Message");
		//
		this.playBtn.addEventListener("click", this.onPlayBtn.createCallback(this));
		this.pauseBtn.addEventListener("click", this.onPauseBtn.createCallback(this));
		this.stopBtn.addEventListener("click", this.onStopBtn.createCallback(this));
		this.resumeBtn.addEventListener("click", this.onResumeBtn.createCallback(this));		
		// default to 5 seconds of buffer time instead of 1 second
		air.SoundMixer.bufferTime = 5000;
		//
		resumeBtn.disabled = true;
		pauseBtn.disabled = true;
		stopBtn.disabled = true;
	},
	
	load: function(url, title) {
		this.title = typeof(title) != 'undefined' ? title : "";
		air.trace("Loading URL: " + url + "CB: " + this.autoPlayCb.checked);
		if (url.length == 0) {
			return;
		}
		
		this.setProgress(this.loading, this.loadingMessage, 0, 1);
		this.setProgress(this.playing, this.playingMessage, 0, 1);
		//TODO: this.loadingPb.setProgress(0, 1);
		//this.playingPb.setProgress(0, 1);
				
//		if (this.s != null && this.s.isPlaying)
		if (this.s != null)
		{
			this.s.stop();
		}
		var cbs = {
			loadProgress: this.onLoadProgress.createCallback(this),
			loadOpen: this.onLoadOpen.createCallback(this),
			loadComplete: this.onLoadComplete.createCallback(this),
			playComplete: this.onPlayComplete.createCallback(this),
			progress: this.onPlayProgress.createCallback(this),									
		};
		this.s = new PodcastPlayer.SoundFacade(url, cbs, true, this.autoPlayCb.checked, true, 100000);
		
		this.urlTxt.innerHTML = url;
		this.titleTxt.innerHTML = title;
		
		if (this.autoPlayCb.checked)
		{
			this.playBtn.disabled = true;
		}
		else
		{
			this.playBtn.disabled = false;
		}
		this.stopBtn.disabled = false;
		this.pauseBtn.disabled = true;
		this.resumeBtn.disabled = true;
	},
	
	onLoadOpen: function(event)
	{
		// none of the properties are available when the open event arrives
		air.trace("onLoadOpen");
			
		if (!this.autoPlayCb.checked)
		{
			this.playBtn.disabled = false;
		}		
	},
	
	onLoadComplete: function(evt)
	{
		// all of the properties are available when the complete event arrives
		air.trace("onLoadComplete");
		if (this.s.isPlaying)
		{
			// can't pause until the file is fully loaded
			this.pauseBtn.disabled = false;
		}
	},
		
	onLoadProgress: function(event)
	{   
		this.setProgress(this.loading, this.loadingMessage, event.bytesLoaded, event.bytesTotal);
		//TODO: this.dispatchEvent(event.clone());
	},
	
	onPlayProgress: function(bytesLoaded, bytesTotal)
	{
		this.setProgress(this.playing, this.playingMessage, bytesLoaded, bytesTotal);
	},
	
	onPlayComplete: function(evt)
	{
		air.trace("onPlayComplete");
		
		this.playBtn.disabled = false;
		this.stopBtn.disabled = true;
	},
			
	onPlayBtn: function(evt)
	{
		if (this.s != null)
		{
			this.s.play(); 
			this.stopBtn.disabled = false;
			this.playBtn.disabled = true;
			if (this.s.isLoaded)
			{
				this.pauseBtn.disabled = false;
				this.resumeBtn.disabled = true;
			}
		}
	},

	onPauseBtn: function(evt)
	{
		this.s.pause();
		
		this.playBtn.disabled = false;
		this.pauseBtn.disabled = true;
		this.resumeBtn.disabled = false;
	},
		
	onResumeBtn: function(evt)
	{
		this.s.resume();
		
		this.pauseBtn.disabled = false;
		this.resumeBtn.disabled = true;
	},
		
	onStopBtn: function(evt)
	{
		this.s.stop();
		this.setProgress(this.playing, this.playingMessage, 0, 1);
		//this.playingPb.setProgress(0, 1);
		
		this.playBtn.disabled = false;
		this.pauseBtn.disabled = true;
		this.resumeBtn.disabled = true;
		this.stopBtn.disabled = true;
	},
	
	setProgress: function(elm, message, bytesLoaded, bytesTotal)
	{
		//air.trace("progress: "+ bytesLoaded + "/" + bytesTotal);
		var len = Math.ceil(300 * bytesLoaded / bytesTotal);
		elm.style.width= len +"px";
		
		
		var loaded = Math.round(100*bytesLoaded / bytesTotal);
		if(!isNaN(loaded))
			message.innerHTML = loaded + '%';
		else
			message.innerHTML = '';
		
	}
};
