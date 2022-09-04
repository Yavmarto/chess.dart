
import 'package:chess2/move.dart';
import 'package:chess2/state.dart';

class Line {
  List<State> history = [];
  List<Move> future = [];
}