HTMLMediaElement Simulator
=========
  
HTML5 HTMLMediaElement Simulator by ActionScript 3.0
  
## Usage

### Audio
  
    import mediaelement.Audio;

    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.ProgressEvent;
    import flash.events.IOErrorEvent;

    var audio:Audio = new Audio();

    audio.src = 'sample.mp3';

    addChild(audio);

    audio.onprogress = function(event:ProgressEvent):void {
        // do something ...
    };

    audio.onerror = function(event:IOErrorEvent):void {
        // do something ...
    };

    audio.oncanplay = function(event:Event):void {
        stage.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
            if (audio.paused) {
                audio.play(audio.currentTime);
            } else {
                audio.pause();
            }
        }, false, 0, true);

        // do something ...
    };

    audio.ondurationchange = function(event:Event):void {
        // do something ...
    };

    audio.ontimeupdate = function(event:Event):void {
        // do something ...
    };

    audio.onended = function(event:Event):void {
        // do something ...
    };
  
### Video
  
    import mediaelement.VideoPlayer;

    import flash.events.Event;
    import flash.events.MouseEvent;

    var video:VideoPlayer = new VideoPlayer();

    video.src = 'sample.mp4';

    addChild(video);

    stage.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
        if (video.paused) {
            video.play(video.currentTime);
        } else {
            video.pause();
        }
    }, false, 0, true);

    video.onerror = function(event:IOErrorEvent):void {
        // do something ...
    };

    video.ondurationchange = function():void {
        // do something ...
    };

    video.ontimeupdate = function(event:Event):void {
        // do something ...
    };

    video.onended = function(event:Event):void {
        // do something ...
    };
  
## License
  
Copyright (c) 2014 Tomohiro IKEDA (Korilakkuma)  
Released under the MIT license
  
