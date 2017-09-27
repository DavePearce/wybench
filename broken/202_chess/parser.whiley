// This file implements a parse for chess games in Portable Game
// Notation (PGN) format.  This is based around short-algebraic notation.
// Such moves are, by themselves, incomplete.  We must have access to the 
// current board state in order to decode them.
//
// See http://en.wikipedia.org/wiki/Algebraic_chess_notation for more.
import std::ascii

import ShortRound from shortmove

type state is {ascii::string input, int pos}

ShortRound DUMMY = {}

public function parseChessGame(ascii::string input) -> ShortRound[]|null:
    int pos = 0
    ShortRound[] moves = [DUMMY; 0]
    while pos < |input|:        
        ShortRound|null round
        round,pos = parseRound(pos,input)
        if round is null:
            return null
        else:
            moves = append(moves,round)
    return moves

function parseRound(int pos, ascii::string input) -> (ShortRound|null r, int npos):
    ShortMove white
    ShortMove|null black
    int|null tpos = parseNumber(pos,input)
    if tpos == null:
        return null,pos
    pos = parseWhiteSpace(npos,input)
    white,pos = parseMove(pos,input,true)
    pos = parseWhiteSpace(pos,input)
    if pos < |input|:
        black,pos = parseMove(pos,input,false)
        pos = parseWhiteSpace(pos,input)
    else:
        black = null
    return (white,black),pos

function parseNumber(int pos, ascii::string input) -> int|null:
    while pos < |input| && input[pos] != '.':
        pos = pos + 1
    if pos == |input|:
        return null
    else:
        return pos+1

function parseMove(int pos, ascii::string input, bool isWhite) -> (ShortMove,int):
    ShortMove move
    // first, we check for castling moves    
    if |input| >= (pos+5) && input[pos..(pos+5)] == "O-O-O":
        move = Move.Castle(isWhite, false)
        pos = pos + 5
    else if |input| >= (pos+3) && input[pos..(pos+3)] == "O-O":
        move = Move.Castle(isWhite, true)
        pos = pos + 3
    else:
        Piece p
        ShortPos f, ShortPos t
        bool flag
        // not a castling move
        p,pos = parsePiece(pos,input,isWhite)
        f,pos = parseShortPos(pos,input)
        if input[pos] == 'x':
            pos = pos + 1
            flag = true
        else:
            flag = false
        t,pos = parsePos(pos,input)
        move = { piece: p, from: f, to: t, isTake: flag }
    // finally, test for a check move
    if pos < |input| && input[pos] == '+':
        pos = pos + 1
        move = {check: move}     
    return move,pos

function parsePiece(int index, ascii::string input, bool isWhite) -> (Piece,int):
    ascii::char lookahead = input[index]
    int piece
    switch lookahead:
        case 'N':
            piece = KNIGHT
        case 'B':
            piece = BISHOP
        case 'R':
            piece = ROOK
        case 'K':
            piece = KING
        case 'Q':
            piece = QUEEN
        default:
            index = index - 1
            piece = PAWN
    return {kind: piece, colour: isWhite}, index+1
    
function parsePos(int pos, ascii::string input) -> (Pos,int):
    int c = (int) input[pos] - 'a'
    int r = (int) input[pos+1] - '1'
    return { col: c, row: r },pos+2

function parseShortPos(int index, ascii::string input) -> (ShortPos,int):
    ascii::char c = input[index]
    if ascii::isDigit(c):
        // signals rank only
        return { row: (int) c - '1' },index+1
    else if c != 'x' && ascii::isLetter(c):
        // so, could be file only, file and rank, or empty
        ascii::char d = input[index+1]
        if ascii::isLetter(d):
            // signals file only
            return { col: (int) c - 'a' },index+1         
        else if (index+2) < |input| && ascii::isLetter(input[index+2]):
            // signals file and rank
            return { col: ((int) c - 'a'), row: (int) d - '1' },index+2
    // no short move given
    return null,index

function parseWhiteSpace(int index, ascii::string input) -> int:
    while index < |input| && isWhiteSpace(input[index]):
        index = index + 1
    return index

function isWhiteSpace(ascii::char c) -> bool:
    return c == ' ' || c == '\t' || c == '\n'

// FIXME: this should really not be here
function append(ShortRound[] rounds, ShortRound round):
    ShortRound[] nRounds = [DUMMY; |rounds| + 1]
    //
    int i = 0
    while i < |nRounds|:
        nRounds[i] = rounds[i]
        i = i + 1
    //
    nRounds[i] = round
    return nRounds
