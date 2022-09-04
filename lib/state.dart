import 'package:chess2/chess.dart';
import 'package:chess2/move.dart';

class State {
  final Move move;
  final ColorMap<int> kings;
  final Color turn;
  final ColorMap<int> castling;
  final int? ep_square;
  final int half_moves;
  final int move_number;
  const State(this.move, this.kings, this.turn, this.castling, this.ep_square, this.half_moves, this.move_number);
}