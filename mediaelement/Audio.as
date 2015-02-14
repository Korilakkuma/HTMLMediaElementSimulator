package mediaelement {

    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.ProgressEvent;
    import flash.events.IOErrorEvent;
    import flash.net.URLRequest;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundTransform;

    public class Audio extends Sprite {

        public static const EVENT_LOADSTART      = 'loadstart';
        public static const EVENT_PROGRESS       = 'progress';
        public static const EVENT_ERROR          = 'error';
        public static const EVENT_CANPLAY        = 'canplay';
        public static const EVENT_PLAY           = 'play';
        public static const EVENT_PAUSED         = 'paused';
        public static const EVENT_TIMEUPDATE     = 'timeupdate';
        public static const EVENT_DURATIONCHANGE = 'durationchange';
        public static const EVENT_VOLUMECHANGE   = 'volumechange';
        public static const EVENT_ENDED          = 'ended';

        private var _sound:Sound            = null;
        private var _channel:SoundChannel   = null;
        private var _src:String             = '';
        private var _isCanPlay:Boolean      = false;

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
        private var _oncanplay        = function():void {};
        private var _onplay           = function():void {};
        private var _onpaused         = function():void {};
        private var _ontimeupdate     = function():void {};
        private var _onended          = function():void {};
        private var _ondurationchange = function():void {};
        private var _onvolumechange   = function():void {};

        public function AudioPlayer(src:String = '') {
            this.src = src;
        }

        public function get src():String {
            return this._src;
        }

        public function set src(src:String):void {
            this._src = src;

            this._sound = new Sound();
            this._sound.addEventListener(Event.COMPLETE,         this._oncomplete, false, 0, true);
            this._sound.addEventListener(ProgressEvent.PROGRESS, this._onprogress, false, 0, true);
            this._sound.addEventListener(IOErrorEvent.IO_ERROR,  this._onerror,    false, 0, true);

            try {
                this._sound.load(new URLRequest(this._src));
                this._onloadstart();
            } catch (error:Error) {
                this._onerror(error);
            }
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

        private function _oncomplete(event:Event):void {
            this._sound.removeEventListener(Event.COMPLETE,         this._oncomplete);
            this._sound.removeEventListener(ProgressEvent.PROGRESS, this._onprogress);
            this._sound.removeEventListener(IOErrorEvent.IO_ERROR,  this._onerror);

            //this._sound = Sound(event.target);

            var rate:Number     = this._sound.bytesTotal / this._sound.bytesLoaded;
            var duration:Number = this._sound.length / rate;
            this._duration      = Math.floor(duration / 1000);  // msec -> sec

            this._ondurationchange(event);

            this._isCanPlay = true;
            this._oncanplay(event);
        }

        private function _onsoundprogress(event:Event):void {
            this._currentPosition = this._channel.position;
            this._currentTime     = this._currentPosition / 1000;  // msec -> sec
            this._ontimeupdate(event);
        }

        private function _onsoundcomplete(event:Event):void {
            this._channel.stop();
            this._paused = true;

            if (this._loop) {
                this.play(0);
            } else {
                this._onpaused(event);
                this._onended(event);
                this.removeEventListener(Event.ENTER_FRAME, this._onsoundprogress);
            }
        }

        public function play(position:Number = 0):void {
            if (!this._isCanPlay) {
                return;
            }

            if (this._paused) {
                var soundTransform:SoundTransform = new SoundTransform();

                if (this._channel is SoundChannel) {
                    soundTransform = this._channel.soundTransform;
                }

                this._channel                = this._sound.play(position);
                this._channel.soundTransform = soundTransform;
                this._channel.addEventListener(Event.SOUND_COMPLETE, this._onsoundcomplete, false, 0, true);

                this._paused = false;
                this._onplay();

                this.addEventListener(Event.ENTER_FRAME, this._onsoundprogress, false, 0, true);
            }
        }

        public function pause() {
            if (!this._isCanPlay) {
                return;
            }

            if (!this._paused) {
                this._channel.stop();
                this._paused = true;
                this._onpaused();
                this.removeEventListener(Event.ENTER_FRAME, this._onsoundprogress);
            }
        }

        public function get volume():Number {
            return this._channel.soundTransform.volume;
        }

        public function set volume(volume:Number):void {
            if ((this._channel is SoundChannel) && (volume >= 0) && (volume <= 1)) {
                if (!this._muted) {
                    var soundTransform:SoundTransform = this._channel.soundTransform;
                    soundTransform.volume             = volume;
                    this._channel.soundTransform      = soundTransform;
                }

                this._volume = volume;

                this._onvolumechange();
            }
        }

        public function get pan():Number {
            return this._channel.soundTransform.pan;
        }

        public function set pan(pan:Number):void {
            if ((this._channel is SoundChannel) && (pan >= -1) && (pan <= 1)) {
                var soundTransform:SoundTransform = this._channel.soundTransform;
                soundTransform.pan                = pan;
                this._channel.soundTransform      = soundTransform;
            }
        }

        public function get muted():Boolean {
            return this._muted;
        }

        public function set muted(muted:Boolean):void {
            this._muted = muted;

            if (this._channel is SoundChannel) {
                var soundTransform:SoundTransform = this._channel.soundTransform;
                soundTransform.volume             = this._muted ? 0 : this._volume;
                this._channel.soundTransform      = soundTransform;
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

        public function get currentPosition():Number {
            return this._currentPosition;
        }

        public function set currentTime(currentTime:Number):void {
            if ((currentTime >= 0) && (currentTime <= this._duration)) {
                this._channel.stop();
                this._paused = true;

                this.play(currentTime * 1000);
                this._ontimeupdate();
            }
        }

        public function get paused():Boolean {
            return this._paused;
        }
    }

}
