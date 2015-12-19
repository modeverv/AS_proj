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

var PodcastPlayer; if (!PodcastPlayer) PodcastPlayer = {};

PodcastPlayer.SoundFacade = function () {
	this.initialize.apply(this, arguments);
};

PodcastPlayer.SoundFacade.prototype = {
	bufferTime: 1000,
	isLoaded: false,
	isReadyToPlay: false,
	isPlaying: false,
	isStreaming: true,
	autoLoad: true,
	autoPlay: true,
	pausePosition: 0,
	progressInterval: 1000,
	PLAY_PROGRESS: "playProgress",
	playTimer: null,

	initialize: function(soundUrl, callbacks, autoLoad, autoPlay, streaming, bufferTime) {
		this.url = soundUrl;
		this.cbs = callbacks;
		this.autoLoad = typeof(autoLoad) != 'undefined' ? autoLoad : true;
		this.autoPlay = typeof(autoPlay) != 'undefined' ? autoPlay : true;
		this.streaming = typeof(streaming) != 'undefined' ? streaming : true;		
		this.bufferTime = typeof(bufferTime) != 'undefined' ? bufferTime : -1;
		
		// defaults to the global bufferTime value
		if (this.bufferTime < 0) {
			this.bufferTime = air.SoundMixer.bufferTime;
		}
		
		// keeps buffer time reasonable, between 0 and 30 seconds
		this.bufferTime = Math.min(Math.max(0, this.bufferTime), 30);
		    
		if (this.autoLoad)
		{
			this.load();
		}		
	},
	
	load: function() {
		if (this.isPlaying)
		{
			this.stop();
			this.s.close();
			this.pausePosition = 0;
		}
		this.isLoaded = false;
			
		this.s = new air.Sound();
			
		this.s.addEventListener(air.ProgressEvent.PROGRESS, this.onLoadProgress.createCallback(this));
		this.s.addEventListener(air.Event.OPEN, this.onLoadOpen.createCallback(this));
		this.s.addEventListener(air.Event.COMPLETE, this.onLoadComplete.createCallback(this));
		this.s.addEventListener(air.Event.ID3, this.onID3.createCallback(this));
		this.s.addEventListener(air.IOErrorEvent.IO_ERROR, this.onIOError.createCallback(this));
		this.s.addEventListener(air.SecurityErrorEvent.SECURITY_ERROR, this.onIOError.createCallback(this));

		air.trace("LoadSound: " + this.url);			
		var req = new air.URLRequest(this.url);
			
		var context = new air.SoundLoaderContext(this.bufferTime, true);

		this.s.load(req, context);		
	},
	
	onLoadOpen: function(event)
	{
		if (this.isStreaming)
		{
			this.isReadyToPlay = true;
			if (this.autoPlay)
			{
				air.trace("AUTO PLAY");
				this.play();
			}
		}
		if (this.cbs.loadOpen) this.cbs.loadOpen(event);
		//TODO: this.dispatchEvent(event.clone());
	},
		
	onLoadProgress: function(event)
	{   
		if (this.cbs.loadProgress) this.cbs.loadProgress(event);
		//TODO: this.dispatchEvent(event.clone());
	},
		
	onLoadComplete: function(event)
	{
		this.isReadyToPlay = true;
		this.isLoaded = true;
		if (this.cbs.loadComplete) this.cbs.loadComplete(event);
		//TODO: this.dispatchEvent(event.clone());
			
		// if the sound hasn't started playing yet, start it now
		if (this.autoPlay && !this.isPlaying)
		{
			this.play();
		}
	},
	
	play: function(_pos)
	{
		var pos = typeof(_pos) != 'undefined' ? _pos : 0;
		air.trace("IsPlaying: " + this.isPlaying + " pos: " + pos);
		if (!this.isPlaying)
		{
			if (this.isReadyToPlay)
			{
				this.sc = this.s.play(pos);
				this.sc.addEventListener(air.Event.SOUND_COMPLETE, this.onPlayComplete.createCallback(this));
				air.trace("PLAYING");
				this.isPlaying = true;
					
				this.playTimer = new air.Timer(this.progressInterval);
				this.playTimer.addEventListener(air.TimerEvent.TIMER, this.onPlayTimer.createCallback(this));
				this.playTimer.start();
			} 
			else if (this.isStreaming && !this.isLoaded)
			{
				// start loading again and play when ready
				// it appears to resume loading from the spot where it left off...cool
				this.load();
				return;
			}
		} 
	},
		
	stop: function(_pos)
	{
		var pos = typeof(_pos) != 'undefined' ? _pos : 0;
		if (this.isPlaying)
		{
			this.pausePosition = pos;
			this.sc.stop();
			this.playTimer.stop();
			this.isPlaying = false;
		}
		if (this.isStreaming && !this.isLoaded)
		{
		    // stop streaming
		    try {
			    this.s.close();
		    }catch(ex){}
		    this.isReadyToPlay = false;
		}
	},
		
	pause: function() 
	{
		var pos = this.sc ? this.sc.position : 0;
		air.trace("PAUSE: " + pos);
		this.stop(pos);
	},
		
	resume: function()
	{
		this.play(this.pausePosition);
	},

	isPaused: function()
	{
		return (this.pausePosition > 0)
	},

	onPlayComplete: function(event)
	{
		this.pausePosition = 0;
		this.playTimer.stop();
		this.isPlaying = false;
     
		if (this.cbs.playComplete) this.cbs.playComplete(event);       
		//TODO: this.dispatchEvent(event.clone());
	},
		
	onID3: function(event)
	{
		try
		{
			var id3 = event.target.id3;
    		    
			for (var propName in id3)
			{
				air.trace(propName + " = " + id3[propName]);
			}
		}catch (err)
		{
			air.trace("Could not retrieve ID3 data.");
		}
	},
		
	id3: function()
	{
		return this.s.id3;
	},
	
	onIOError: function(event)
	{
		air.trace("SoundFacade.onIOError: " + event);
		if (this.cbs.IOError) this.cbs.IOError(event);       		
		//TODO: this.dispatchEvent(event.clone());
	},
		
	onPlayTimer: function(event)
	{
		var estimatedLength = Math.ceil(this.s.length / (this.s.bytesLoaded / this.s.bytesTotal));
		//air.trace("Progress: position: " + this.sc.position + " length: " + estimatedLength);
		if (this.cbs.progress) this.cbs.progress(this.sc.position, estimatedLength);       				
		//var progEvent = new ProgressEvent(PLAY_PROGRESS, false, false, this.sc.position, estimatedLength);
		//TODO: this.dispatchEvent(progEvent);
	}	
};