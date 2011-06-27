// A simple chess model
//
// David J. Pearce, 2010

// =============================================================
// Pieces
// =============================================================

define PAWN as 0
define KNIGHT as 1 
define BISHOP as 2
define ROOK as 3
define QUEEN as 4
define KING as 5
define PIECE_CHARS as [ 'P', 'N', 'B', 'R', 'Q', 'K' ]

define PieceKind as { PAWN, KNIGHT, BISHOP, ROOK, QUEEN, KING }
define Piece as { PieceKind kind, bool colour }

define WHITE_PAWN as { kind: PAWN, colour: true }
define WHITE_KNIGHT as { kind: KNIGHT, colour: true }
define WHITE_BISHOP as { kind: BISHOP, colour: true }
define WHITE_ROOK as { kind: ROOK, colour: true }
define WHITE_QUEEN as { kind: QUEEN, colour: true }
define WHITE_KING as { kind: KING, colour: true }

define BLACK_PAWN as { kind: PAWN, colour: false }
define BLACK_KNIGHT as { kind: KNIGHT, colour: false }
define BLACK_BISHOP as { kind: BISHOP, colour: false }
define BLACK_ROOK as { kind: ROOK, colour: false }
define BLACK_QUEEN as { kind: QUEEN, colour: false }
define BLACK_KING as { kind: KING, colour: false }

// =============================================================
// Positions
// =============================================================

define RowCol as int // where 0 <= $ && $ <= 8
define Pos as { RowCol col, RowCol row } 

// =============================================================
// board
// =============================================================

define Square as Piece | null
define Row as [Square] // where |$| == 8
define Board as {
    [Row] rows, 
    bool whiteCastleKingSide,
    bool whiteCastleQueenSide,
    bool blackCastleKingSide,
    bool blackCastleQueenSide
}    

define startingChessRows as [
    [ WHITE_ROOK,WHITE_KNIGHT,WHITE_BISHOP,WHITE_QUEEN,WHITE_KING,WHITE_BISHOP,WHITE_KNIGHT,WHITE_ROOK ], // rank 1
    [ WHITE_PAWN,WHITE_PAWN,WHITE_PAWN,WHITE_PAWN,WHITE_PAWN,WHITE_PAWN,WHITE_PAWN,WHITE_PAWN ],          // rank 2
    [ null, null, null, null, null, null, null, null ],                                                   // rank 3
    [ null, null, null, null, null, null, null, null ],                                                   // rank 4
    [ null, null, null, null, null, null, null, null ],                                                   // rank 5
    [ null, null, null, null, null, null, null, null ],                                                   // rank 6
    [ BLACK_PAWN,BLACK_PAWN,BLACK_PAWN,BLACK_PAWN,BLACK_PAWN,BLACK_PAWN,BLACK_PAWN,BLACK_PAWN ],          // rank 7
    [ BLACK_ROOK,BLACK_KNIGHT,BLACK_BISHOP,BLACK_QUEEN,BLACK_KING,BLACK_BISHOP,BLACK_KNIGHT,BLACK_ROOK ]  // rank 8
]

define startingChessBoard as {
    rows: startingChessRows,
    whiteCastleKingSide: true,
    whiteCastleQueenSide: true,
    blackCastleKingSide: true,
    blackCastleQueenSide: true
}

// =============================================================
// Moves
// =============================================================

define SingleMove as { Piece piece, Pos from, Pos to }
define SingleTake as { Piece piece, Pos from, Pos to, Piece taken }
define SimpleMove as SingleMove | SingleTake

define CastleMove as { bool isWhite, bool kingSide }
define CheckMove as { Move check }
define Move as CheckMove | CastleMove | SimpleMove

// castling
// en passant

// =============================================================
// Valid Move Dispatch
// =============================================================

// The purpose of the validMove method is to check whether or not a
// move is valid on a given board.
bool validMove(Move move, Board board):
    nboard = applyMove(move,board)
    // first, test the check status of this side, and the opposition
    // side.
    if move is CheckMove:
        move = move.check
        oppCheck = true
    else:
        // normal expectation of opposition
        oppCheck = false
    // Now, identify what colour I am
    if move is CastleMove:
        isWhite = move.isWhite
    else if move is SingleMove:
        isWhite = move.piece.colour
    else:
        isWhite = false // deadcode
    // finally, check everything is OK
    return !inCheck(isWhite,nboard) && // I'm in check?
        oppCheck == inCheck(!isWhite,nboard) && // oppo in check?
        internalValidMove(move, board) // move otherwise ok?

bool internalValidMove(Move move, Board board):
    if move is SingleTake:
        return validPieceMove(move.piece,move.from,move.to,true,board) &&
            validPiece(move.taken,move.to,board)
    else if move is SingleMove:
        return validPieceMove(move.piece,move.from,move.to,false,board) &&
            squareAt(move.to,board) is null
    else if move is CastleMove:
        return validCastle(move, board)
    // the following should be dead-code, but to remove it requires
    // more structuring of CheckMoves
    return false

bool validPieceMove(Piece piece, Pos from, Pos to, bool isTake, Board board):
    if validPiece(piece,from,board):
        if piece.kind == PAWN:
            return validPawnMove(piece.colour,from,to,isTake,board)        
        else if piece.kind == KNIGHT:
            return validKnightMove(piece.colour,from,to,isTake,board)
        else if piece.kind == BISHOP:
            return validBishopMove(piece.colour,from,to,isTake,board)
        else if piece.kind == ROOK:
            return validRookMove(piece.colour,from,to,isTake,board)
        else if piece.kind == QUEEN:
            return validQueenMove(piece.colour,from,to,isTake,board)
        else if piece.kind == KING:
            return validKingMove(piece.colour,from,to,isTake,board)
    return false

// Check whether a given piece is actually at a given position in the
// board.
bool validPiece(Piece piece, Pos pos, Board board):
    sq = squareAt(pos,board)
    if sq is null:
        return false
    else:
        return sq == piece

// Determine whether the board is in check after the given move, with
// respect to the opposite colour of the move.
bool inCheck(bool isWhite, Board board):
    if isWhite:
        kpos = findPiece(WHITE_KING,board)
    else:
        kpos = findPiece(BLACK_KING,board)    
    if kpos is null:   
        return false // dead-code!
    // check every possible piece cannot take king
    for r in range(0,8):
        for c in range(0,8):
            tmp = board.rows[r][c]
            if !(tmp is null) && tmp.colour == !isWhite && 
                validPieceMove(tmp,{row: r, col: c},kpos,true,board):
                return true
    // no checks found
    return false

bool validCastle(CastleMove move, Board board):
    // FIXME: this functionis still broken, since we have to check
    // that we're not castling through check :(
    if move.isWhite:
        if move.kingSide:
            return board.whiteCastleKingSide && 
                board.rows[0][5] == null && board.rows[0][6] == null
        else:
            return board.whiteCastleQueenSide && 
                board.rows[0][1] == null && board.rows[0][2] == null && board.rows[0][3] == null
    else:
        if move.kingSide:
            return board.blackCastleKingSide && 
                board.rows[7][5] == null && board.rows[7][6] == null
        else:
            return board.blackCastleQueenSide && 
                board.rows[7][1] == null && board.rows[7][2] == null && board.rows[7][3] == null

// =============================================================
// Individual Piece Moves
// =============================================================

bool validPawnMove(bool isWhite, Pos from, Pos to, bool isTake, Board board):
    // calculate row difference
    if (isWhite):
        rowdiff = to.row - from.row
    else:
        rowdiff = from.row - to.row        
    // check row difference either 1 or 2, and column 
    // fixed (unless take)
    if rowdiff <= 0 || rowdiff > 2 || (!isTake && from.col != to.col):
        return false
    // check that column difference is one for take
    if isTake && from.col != (to.col - 1) && from.col != (to.col + 1):
        return false
    // check if rowdiff is 2 that on the starting rank
    if isWhite && rowdiff == 2 && from.row != 1:
        return false
    else if !isWhite && rowdiff == 2 && from.row != 6:
        return false
    // looks like we're all good
    return true    

bool validKnightMove(bool isWhite, Pos from, Pos to, bool isTake, Board board):
    diffcol = max(from.col,to.col) - min(from.col,to.col)
    diffrow = max(from.row,to.row) - min(from.row,to.row)
    return (diffcol == 2 && diffrow == 1) || (diffcol == 1 && diffrow == 2)

bool validBishopMove(bool isWhite, Pos from, Pos to, bool isTake, Board board):
    return clearDiaganolExcept(from,to,board)

bool validRookMove(bool isWhite, Pos from, Pos to, bool isTake, Board board):
    return clearRowExcept(from,to,board) || clearColumnExcept(from,to,board)

bool validQueenMove(bool isWhite, Pos from, Pos to, bool isTake, Board board):
    return clearRowExcept(from,to,board) || clearColumnExcept(from,to,board) ||
        clearDiaganolExcept(from,to,board)

bool validKingMove(bool isWhite, Pos from, Pos to, bool isTake, Board board):
    diffcol = max(from.col,to.col) - min(from.col,to.col)
    diffrow = max(from.row,to.row) - min(from.row,to.row)
    return diffcol == 1 || diffrow == 1

// =============================================================
// Apply Move
// =============================================================

Board applyMove(Move move, Board board):
    if move is SingleMove:
        // SingleTake is processed in the same way
        return applySingleMove(move,board)
    else if move is CheckMove:
        return applyMove(move.check,board)
    else if move is CastleMove:
        return applyCastleMove(move,board)
    return board

Board applySingleMove(SingleMove move, Board board):
    from = move.from
    to = move.to
    board.rows[from.row][from.col] = null
    board.rows[to.row][to.col] = move.piece
    return board

Board applyCastleMove(CastleMove move, Board board):
    row = 7
    if move.isWhite:
        row = 0
    king = board.rows[row][4]
    board.rows[row][4] = null   
    if move.kingSide:
        rook = board.rows[row][7]
        board.rows[row][7] = null
        board.rows[row][6] = king
        board.rows[row][5] = rook
    else:
        rook = board.rows[row][0]
        board.rows[row][0] = null
        board.rows[row][2] = king
        board.rows[row][3] = rook
    return board

// =============================================================
// Helper Functions
// =============================================================

Square squareAt(Pos p, Board b):
    return b.rows[p.row][p.col]

// The following method checks whether a given row is completely
// clear, excluding the end points. Observe that this doesn't
// guarantee a given diaganol move is valid, since this function does not
// ensure anything about the relative positions of the given pieces.
bool clearRowExcept(Pos from, Pos to, Board board):
    // check this is really a row
    if from.row != to.row || from.col == to.col:
        return false
    inc = sign(from.col,to.col)
    row = from.row
    col = from.col + inc
    while col != to.col:
        if board.rows[row][col] is null:
            col = col + inc
        else:
            return false        
    return true

// The following method checks whether a given column is completely
// clear, excluding the end points. Observe that this doesn't
// guarantee a given diaganol move is valid, since this function does not
// ensure anything about the relative positions of the given pieces.
bool clearColumnExcept(Pos from, Pos to, Board board):
    if from.col != to.col || from.row == to.row:
        return false
    inc = sign(from.row,to.row)
    row = from.row + inc
    col = from.col
    while row != to.row:
        if board.rows[row][col] is null:
            row = row + inc
        else:
            return false            
    return true

// The following method checks whether the given diaganol is completely
// clear, excluding the end points. Observe that this doesn't
// guarantee a given diaganol move is valid, since this function does not
// ensure anything about the relative positions of the given pieces.
bool clearDiaganolExcept(Pos from, Pos to, Board board):
    // check this is really a diaganol
    diffcol = max(from.col,to.col) - min(from.col,to.col)
    diffrow = max(from.row,to.row) - min(from.row,to.row)
    if diffcol != diffrow:
        return false
    // determine the col and row signs
    colinc = sign(from.col,to.col)
    rowinc = sign(from.row,to.row)
    // finally, walk the line!
    row = from.row + rowinc
    col = from.col + colinc
    while row != to.row && col != to.col:
        if board.rows[row][col] is null:
            col = col + colinc
            row = row + rowinc
        else:
            return false
    // ok, looks like we're clear
    return true 

int sign(int x, int y):
    if x < y:
        return 1
    else:
        return -1
    
// This method finds a given piece.  It's used primarily to locate
// kings on the board to check if they are in check.
Pos|null findPiece(Piece p, Board b):
    for r in range(0,8):
        for c in range(0,8):
            if b.rows[r][c] == p:
                // ok, we've located the piece
                return { row: r, col: c }            
    // could find the piece
    return null

// range should be built in
[int] range(int start, int end):
    r = []
    while start < end:
        r = r + [start]
        start = start + 1
    return r

int max(int a, int b):
    if a < b:
        return b
    else:
        return a

int min(int a, int b):
    if a > b:
        return b
    else:
        return a
