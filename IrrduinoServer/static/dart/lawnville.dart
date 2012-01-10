#import('dart:html');

typedef void Continuation();

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
  final int TIMER_INTERVAL = 10000;      // 10 seconds
  final int REPOSITION_DURATION = 1000;  // 1 second
  final int DROID_WIDTH = 100;
  final int DROID_HEIGHT = 100;
  final int DROID_IDLE_X = 381;
  final int DROID_IDLE_Y = 395;
  final double HALF = 0.5;
  
  Queue _actionQueue;
  bool _waitingForTimer = false;
  ImageElement _droid;
  
  Lawnville() {
    _actionQueue = new Queue();
  }

  void _run() {
    document.title = "LawnVille in Dart!";
    _droid = document.query("#droid");
    _handleZoneClicks();
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
 
  void _water(zone) {
    window.console.log("Watering zone: ${zone}");
    AreaElement zone = document.query("#${zone}");
    int x = Math.parseInt(zone.dataAttributes["center-x"]);
    int y = Math.parseInt(zone.dataAttributes["center-y"]);
    _repositionDroid(x, y, () {
      _droid.src = "/static/images/droid-watering-1.png";
    });
  }
  
  /**
   * Move the droid in an animated way.
   *
   * If continuation is not null, then call it once the movement is done.
   */
  void _repositionDroid(int x, int y, [Continuation continuation = null]) {
    x -= (HALF * DROID_WIDTH).toInt();
    y -= DROID_HEIGHT;
    _droid.src = "/static/images/droid-jetpack-on-front.png";
    _droid.style.left = "${x}px";
    _droid.style.top = "${y}px";
    window.setTimeout(() {
      if (continuation != null) {
        continuation();
      } else {
        _droid.src = "/static/images/droid-waiting-front.png";
      }
    }, REPOSITION_DURATION);
  }
  
  void _idle() {
    _repositionDroid(DROID_IDLE_X, DROID_IDLE_Y);
    window.console.log("I'm bored");
  }
}

void main() {
  new Lawnville()._run();
}