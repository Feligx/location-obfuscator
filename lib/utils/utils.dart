import 'dart:math';

List getCoords(List ogCoords, int maxErr) {
  int a = Random().nextInt(maxErr);
  int b = Random().nextInt(maxErr);

  while (a*a + b*b > maxErr*maxErr) {
    a = Random().nextInt(maxErr);
    b = Random().nextInt(maxErr);
  }

  List list = [1, -1];

  var aMult = list[Random().nextInt(list.length)];
  var bMult = list[Random().nextInt(list.length)];

  List coords = [ogCoords[0] + a*aMult, ogCoords[1] + b*bMult];

  int dist = sqrt(a*a + b*b).toInt();

  return [coords, dist];
}