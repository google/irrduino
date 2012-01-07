#import('dart:html');

class Lawnville {

  Lawnville() {
  }

  void run() {
    write("LawnVille in Dart!");
  }

  void write(String message) {
    document.title = message;
  }
}

void main() {
  new Lawnville().run();
}
