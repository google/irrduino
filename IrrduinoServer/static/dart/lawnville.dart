#import('dart:html');

typedef void Callback();

/**
 * This is like FarmVille, but it actually works.
 *
 * This application is almost entirely client-side.  Even the queuing is
 * handled on the client side.  The up side of this is that it's a lot
 * simpler.  The down side is that we can't see if anyone else is trying
 * to control the sprinkler system, nor does it work once you close the
 * browser window.  The server-side part of IrrduinoServer is only used
 * to talk to IrrduinoController.
 */
class Lawnville {
  final int HALF_SECOND = 500;
  final int TIMER_INTERVAL = 10000;
  final int REPOSITION_DURATION = 1000;
  final int DROID_WIDTH = 100;
  final int DROID_HEIGHT = 100;
  final int DROID_IDLE_X = 381;
  final int DROID_IDLE_Y = 395;
  final double HALF = 0.5;
  
  Queue _actionQueue;
  bool _waitingForTimer = false;
  ImageElement _droid;
  Map<String, Callback> _animationCallbacks;
  int _animationStartTime;
  int _animationProgress;
  
  Lawnville() {
    _actionQueue = new Queue();
    _animationCallbacks = new HashMap<String, Callback>();
    _droid = document.query("#droid");
  }

  void _run() {
    document.title = "LawnVille in Dart!";
    _handleZoneClicks();
    _startAnimationLoop();
  }
  
  void _handleZoneClicks() {
    document.queryAll("area.zone").forEach((AreaElement el) {
      el.on.click.add((MouseEvent e) {
        window.console.log("_actionQueue.add({'action': 'water', 'zone': ${el.id}});");
        _actionQueue.add({'action': 'water', 'zone': el.id});
        _notifyActionQueue();
      });
    }); 
  }

  void _notifyActionQueue() {
    window.console.log("_notifyActionQueue");
    if (_waitingForTimer) {
      window.console.log("Busy, it'll have to wait");
    } else {
      window.console.log("Not busy, doing now");
      _executeActionQueue();
    }
  }
  
  void _executeActionQueue() {
    window.console.log("_executeActionQueue");
    window.console.log("_actionQueue.length: ${_actionQueue.length}");
    if (_actionQueue.isEmpty()) {
      window.console.log("Nothing to do");
      window.console.log("_waitingForTimer = false");
      _waitingForTimer = false;
      _idle();
    } else {      
      window.console.log("There is work to do");
      var action = _actionQueue.removeFirst();
      _doAction(action);
      window.console.log("_waitingForTimer = true");
      _waitingForTimer = true;
      window.setTimeout(_executeActionQueue, TIMER_INTERVAL);
    }
  }
    
  void _doAction(action) {
    // We only have one action at this point.
    assert (action["action"] == "water");
    _water(action["zone"]);
  }
 
  void _water(zoneId) {
    window.console.log("Watering zone: ${zoneId}");
    AreaElement zone = document.query("#${zoneId}");
    int x = Math.parseInt(zone.dataAttributes["center-x"]);
    int y = Math.parseInt(zone.dataAttributes["center-y"]);
    _repositionDroid(x, y, () {
      _droid.src = "/static/images/droid-watering-1.png";
      _animationCallbacks["_wateringAnimation"] = _wateringAnimation;
    });
  }
  
  void _wateringAnimation() {
    if (!_droid.src.contains("/static/images/droid-watering-")) {
      _animationCallbacks.remove("_wateringAnimation");
    } else {
      int oneOrTwo = (_animationProgress / HALF_SECOND).toInt() % 2 + 1;
      _droid.src = "/static/images/droid-watering-${oneOrTwo}.png";
    }
  }
  
  /**
   * Move the droid in an animated way.
   *
   * If callback is not null, then call it once the movement is done.
   */
  void _repositionDroid(int x, int y, [Callback callback = null]) {
    x -= (HALF * DROID_WIDTH).toInt();
    y -= DROID_HEIGHT;
    _droid.src = "/static/images/droid-jetpack-on-front.png";
    _droid.style.left = "${x}px";
    _droid.style.top = "${y}px";
    window.setTimeout(() {
      if (callback != null) {
        callback();
      } else {
        _droid.src = "/static/images/droid-waiting-front.png";
      }
    }, REPOSITION_DURATION);
  }
  
  void _idle() {
    _repositionDroid(DROID_IDLE_X, DROID_IDLE_Y);
    window.console.log("I'm bored");
  }
  
  void _startAnimationLoop() {
    _animationStartTime = new Date.now().value;    
    window.webkitRequestAnimationFrame(_animationLoop);
  }
  
  void _animationLoop(int timestamp) {
    _animationProgress = timestamp - _animationStartTime;
    for (Callback callback in _animationCallbacks.getValues()) {
      callback();
    }
    window.webkitRequestAnimationFrame(_animationLoop);
  }
}

void main() {
  new Lawnville()._run();
}