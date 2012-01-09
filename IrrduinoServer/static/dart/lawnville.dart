#import('dart:html');

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
  int TIMER_INTERVAL = 10 * 1000;  // 10 seconds
  
  Queue _actionQueue;
  bool _waitingForTimer = false;
  
  Lawnville() {
    _actionQueue = new Queue();
  }

  void _run() {
    document.title = "LawnVille in Dart!";
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
    window.console.log("_actionQueue.length: " + _actionQueue.length);
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
    window.console.log("Doing action: " + action["action"] + " zone: " + action["zone"]);
    AreaElement zone = document.query("#" + action["zone"]);
    window.console.log("Center: " + 
      zone.dataAttributes["center-x"] + ", " +
      zone.dataAttributes["center-y"]);
  }
  
  void _idle() {
    window.console.log("I'm bored");
  }
}

void main() {
  new Lawnville()._run();
}