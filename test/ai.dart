// Example of a simple chess AI in Dart using chess.dart
// The user plays white by default.

import 'dart:io';
import 'dart:math';

import 'package:chess2/chess.dart';

// find the best move using simple alphaBeta
Move? findBestMove(Chess chess) {
  const PLY = 4;
  final toPlay = chess.turn;
  final moveEvalPairs = <List>[];

  for (final m in chess.moves({'asObjects': true}) as Iterable<Move>) {
    chess.move(m);
    final eval = alphaBeta(Chess.fromFEN(chess.fen, check_validity: true), PLY,
        -9999999.0, 9999999.0, toPlay);
    moveEvalPairs.add([m, eval]);
    chess.undo();
  }

  var highestEval = -9999999.0;
  Move? bestMove;

  for (final l in moveEvalPairs) {
    if (l[1] > highestEval) {
      highestEval = l[1];
      bestMove = l[0];
    }
  }

  return bestMove;
}

// implements a simple alpha beta algorithm
double alphaBeta(Chess c, int depth, double alpha, double beta, Color player) {
  if (depth == 0 || c.game_over) {
    return evaluatePosition(c, player);
  }

  // if the computer is the current player
  if (c.turn == player) {
    // go through all legal moves
    for (final m in c.moves({'asObjects': true}) as Iterable<Move>) {
      c.move(m);
      alpha = max(alpha, alphaBeta(c, depth - 1, alpha, beta, player));
      if (beta <= alpha) {
        c.undo();
        break;
      }
      c.undo();
    }
    return alpha;
  } else {
    // opponent ist he player
    for (final m in c.moves({'asObjects': true}) as Iterable<Move>) {
      c.move(m);
      beta = min(beta, alphaBeta(c, depth - 1, alpha, beta, player));
      if (beta <= alpha) {
        c.undo();
        break;
      }
      c.undo();
    }
    return beta;
  }
}

const Map pieceValues = {
  PieceType.PAWN: 1,
  PieceType.KNIGHT: 3,
  PieceType.BISHOP: 3.5,
  PieceType.ROOK: 5,
  PieceType.QUEEN: 9,
  PieceType.KING: 10
};

// simple material based evaluation
double evaluatePosition(Chess c, Color player) {
  if (c.game_over) {
    if (c.in_draw) {
      // draw is a neutral outcome
      return 0.0;
    } else {
      // otherwise must be a mate
      if (c.turn == player) {
        // avoid mates
        return -9999.99;
      } else {
        // go for mating
        return 9999.99;
      }
    }
  } else {
    // otherwise do a simple material evaluation
    var evaluation = 0.0;
    var sq_color = 0;
    for (var i = Chess.SQUARES_A8; i <= Chess.SQUARES_H1; i++) {
      sq_color = (sq_color + 1) % 2;
      if ((i & 0x88) != 0) {
        i += 7;
        continue;
      }

      final piece = c.board[i];
      if (piece != null) {
        evaluation += (piece.color == player)
            ? pieceValues[piece.type]
            : -pieceValues[piece.type];
      }
    }

    return evaluation;
  }
}

void main() {
  final chess = Chess();
  while (!chess.game_over) {
    print(chess.ascii);
    print('What would you like to play?');
    final playerMove = stdin.readLineSync();
    if (chess.move(playerMove) == false) {
      print(
          "Could not understand your move or it's illegal. Moves should be in SAN format.");
      continue;
    }
    print('Computer thinking...');

    final compMove = findBestMove(chess);
    chess.move(compMove);
    //print('Computer Played: ' + chess.move_to_san(compMove));
  }

  print(chess.ascii);
  if (chess.in_checkmate) {
    print('Checkmate');
  }
  if (chess.in_stalemate) {
    print('Stalemate');
  }
  if (chess.in_draw) {
    print('Draw');
  }
  if (chess.insufficient_material) {
    print('Insufficient Material');
  }
}
