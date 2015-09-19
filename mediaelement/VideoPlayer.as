package mediaelement {

    import flash.display.Sprite;
    import flash.events.NetStatusEvent;
    import flash.events.AsyncErrorEvent;
    import flash.net.NetConnection;
    import flash.net.NetStream;
    import flash.media.Video;
    import flash.media.SoundTransform;
    import flash.events.Event;

    public class VideoPlayer extends Sprite {

        public static const EVENT_LOADSTART      = 'loadstart';
        public static const EVENT_PROGRESS       = 'progress';
        public static const EVENT_ERROR          = 'error';
        public static const EVENT_LOADEDMETADATA = 'loadedmetadata';
        public static const EVENT_CANPLAY        = 'canplay';
        public static const EVENT_PLAY           = 'play';
        public static const EVENT_PAUSED         = 'paused';
        public static const EVENT_TIMEUPDATE     = 'timeupdate';
        public static const EVENT_DURATIONCHANGE = 'durationchange';
        public static const EVENT_VOLUMECHANGE   = 'volumechange';
        public static const EVENT_ENDED          = 'ended';

        private var _netConnection:NetConnection = null;
        private var _netStream:NetStream         = null;
        private var _video:Video                 = null;
        private var _infoClients:Object          = null;
        private var _src:String                  = '';

        private var _volume:Number          = 1;
        private var _muted:Boolean          = false;
        private var _loop:Boolean           = false;
        private var _duration:Number        = 0;
        private var _currentTime:Number     = 0;
        private var _currentPosition:Number = 0;
        private var _paused:Boolean         = true;

        private var _onloadstart      = function():void {};
        private var _onprogress       = function():void {};
        private var _onerror          = function():void {};
        private var _onloadedmetadata = function():void {};
        private var _oncanplay        = function():void {};
        private var _onplay           = function():void {};
        private var _onpaused         = function():void {};
        private var _ontimeupdate     = function():void {};
        private var _onended          = function():void {};
        private var _ondurationchange = function():void {};
        private var _onvolumechange   = function():void {};

        public function VideoPlayer(src:String = '') {
            if (this._netStream is NetStream) {
                this._netStream.close();
            }

            if (this._video is Video) {
                this._video.clear();
            }

            this.src = src
        }

        public function get src():String {
            return this._src;
        }

        public function set src(src:String):void {
            this._src = src;

            this._netConnection = new NetConnection();
            this._netConnection.connect(null);

            this._netStream = new NetStream(this._netConnection);

            this._infoClients            = new Object();
            this._infoClients.onMetaData = this._onmetadata;
            this._infoClients.onCuePoint = this._oncuepoint;

            this._netStream.client = this._infoClients;

            this._netConnection.addEventListener(NetStatusEvent.NET_STATUS,   this._onnetstatus, false, 0, true);
            this._netConnection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, this._onerror,     false, 0, true);

            this._netStream.addEventListener(NetStatusEvent.NET_STATUS,   this._onnetstatus, false, 0, true);
            this._netStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, this._onerror,     false, 0, true);

            this._video = new Video();
            this._video.attachNetStream(this._netStream);

            this.addChild(this._video);

            this._oncanplay();
        }

        public function set onloadstart(onloadstart:Function):void {
           this._onloadstart = onloadstart;
        };

        public function set onprogress(onprogress:Function):void {
           this._onprogress = onprogress;
        };

        public function set onerror(onerror:Function):void {
           this._onerror = onerror;
        };

        public function set oncanplay(oncanplay:Function):void {
           this._oncanplay = oncanplay;
        };

        public function set onplay(onplay:Function):void {
           this._onplay = onplay;
        };

        public function set onpaused(onpaused:Function):void {
           this._onpaused = onpaused;
        };

        public function set ontimeupdate(ontimeupdate:Function):void {
           this._ontimeupdate = ontimeupdate;
        };

        public function set onended(onended:Function):void {
           this._onended = onended;
        };

        public function set ondurationchange(ondurationchange:Function):void {
           this._ondurationchange = ondurationchange;
        };

        public function set onvolumechange(onvolumechange:Function):void {
           this._onvolumechange = onvolumechange;
        };

        private function _onmetadata(info:Object):void {
            this._duration = info.duration;
            this._onloadedmetadata();
            this._ondurationchange();
        }

        private function _oncuepoint(info:Object):void {
            for (var key:String in info) {
                trace(key + ' : ' + info[key]);
            }
        }

        private function _onnetstatus(event:NetStatusEvent):void {
            trace(event.info.level + ' : ' + event.info.code);

            switch (event.info.code){
                case 'NetStream.Play.Start' :
                    this._paused = false;
                    break;
                case 'NetStream.Play.Stop' :
                    this._paused = true;

                    if (this._loop) {
                        this.play(0);
                    } else {
                        this._onended(event);
                    }

                    break;
                default :
                    break;
            }
        }

        private function _onvideoprogress(event:Event):void {
            this._currentTime = this._netStream.time;
            this._ontimeupdate(event);
        }

        public function play(position:Number = 0):void {
            if (this._src == '') {
                return;
            }

            if (this._paused) {
                this._netStream.play(this._src);
            } else {
                this._netStream.resume();
            }

            this._paused = false;
            this._onplay();

            this.addEventListener(Event.ENTER_FRAME, this._onvideoprogress, false, 0, true);
        }

        public function pause():void {
            if (!this._paused) {
                this._netStream.togglePause();
                this._onpaused();
            }
        }

        public function stop():void {
            this._netStream.close();
            this._video.clear();
            this._paused = true;
        }

        public function get volume():Number {
            return this._netStream.soundTransform.volume;
        }

        public function set volume(volume:Number):void {
            if ((this._netStream is NetStream) && (volume >= 0) && (volume <= 1)) {
                if (!this._muted) {
                    var soundTransform:SoundTransform = this._netStream.soundTransform
                    soundTransform.volume             = volume;
                    this._netStream.soundTransform    = soundTransform;
                }

                this._volume = volume;

                this._onvolumechange();
            }
        }

        public function get muted():Boolean {
            return this._muted;
        }

        public function set muted(muted:Boolean):void {
            this._muted = muted;

            if (this._netStream is NetStream) {
                var soundTransform:SoundTransform = this._netStream.soundTransform;
                soundTransform.volume             = this._muted ? 0 : this._volume;
                this._netStream.soundTransform    = soundTransform;
            }
        }

        public function get loop():Boolean {
            return this._loop;
        }

        public function set loop(loop:Boolean):void {
            this._loop = loop;
        }

        public function get duration():Number {
            return this._duration;
        }

        public function get currentTime():Number {
            return this._currentTime;
        }

        public function set currentTime(currentTime:Number):void {
            if ((currentTime >= 0) && (currentTime <= this._duration)) {
                this._netStream.seek(currentTime);
                this._ontimeupdate();
            }
        }

        public function get paused():Boolean {
            return this._paused;
        }
    }

}
