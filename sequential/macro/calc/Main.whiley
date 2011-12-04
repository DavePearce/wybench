import * from whiley.lang.*
import * from whiley.io.File
import SyntaxError from whiley.lang.Errors

// ====================================================
// A simple calculator for expressions
// ====================================================

define ADD as 0
define SUB as 1
define MUL as 2
define DIV as 3

// binary operation
define BOp as { ADD, SUB, MUL, DIV }
define BinOp as { BOp op, Expr lhs, Expr rhs } 

// variables
define Var as { string id }

// list access
define ListAccess as { 
    Expr src, 
    Expr index
} 

// expression tree
define Expr as int |  // constant
    Var |              // variable
    BinOp |            // binary operator
    [Expr] |           // list constructor
    ListAccess         // list access

// values
define Value as int | [Value]

// stmts
define Print as { Expr rhs }
define Set as { string lhs, Expr rhs }
define Stmt as Print | Set

// ====================================================
// Expression Evaluator
// ====================================================

define RuntimeError as { string msg }

Value evaluate(Expr e, {string->Value} env) throws RuntimeError:
    if e is int:
        return e
    else if e is Var:
        return env[e.id]
    else if e is BinOp:
        lhs = evaluate(e.lhs, env)
        rhs = evaluate(e.rhs, env)
        // check if stuck
        if !(lhs is int && rhs is int):
            throw {msg: "arithmetic attempted on non-numeric value"}
        // switch statement would be good
        if e.op == ADD:
            return lhs + rhs
        else if e.op == SUB:
            return lhs - rhs
        else if e.op == MUL:
            return lhs * rhs
        else if rhs != 0:
            return lhs / rhs
        else:
            return 0 // for div-by-zero
    else if e is [Expr]:
        r = []
        for i in e:
            v = evaluate(i, env)
            r = r + [v]
        return r
    else:
        src = evaluate(e.src, env)
        index = evaluate(e.index, env)
        // santity checks
        if src is [Value] && index is int && index >= 0 && index < |src|:
            return src[index]
        else:
            throw {msg: "invalid list access"}

// ====================================================
// Expression Parser
// ====================================================

define State as { string input, int pos }

// Top-level parse method
(Stmt,State) parse(State st) throws SyntaxError:
    start = st.pos
    keyword,st = parseIdentifier(st)
    switch keyword.id:
        case "print":
            e,st = parseAddSubExpr(st)
            return {rhs: e},st
        case "set":
            st = parseWhiteSpace(st)
            v,st = parseIdentifier(st)
            e,st = parseAddSubExpr(st)
            return {lhs: v.id, rhs: e},st
        default:
            throw SyntaxError("unknown statement (" + keyword.id + ")",start,st.pos-1)

(Expr, State) parseAddSubExpr(State st) throws SyntaxError:    
    // First, pass left-hand side    
    lhs,st = parseMulDivExpr(st)
    
    st = parseWhiteSpace(st)
    // Second, see if there is a right-hand side
    if st.pos < |st.input| && st.input[st.pos] == '+':
        // add expression
        st.pos = st.pos + 1
        rhs,st = parseAddSubExpr(st)        
        return {op: ADD, lhs: lhs, rhs: rhs},st
    else if st.pos < |st.input| && st.input[st.pos] == '-':
        // subtract expression
        st.pos = st.pos + 1
        (rhs,st) = parseAddSubExpr(st)        
        return {op: SUB, lhs: lhs, rhs: rhs},st
    
    // No right-hand side
    return (lhs,st)

(Expr, State) parseMulDivExpr(State st) throws SyntaxError:    
    // First, pass left-hand side
    (lhs,st) = parseTerm(st)
    
    st = parseWhiteSpace(st)
    // Second, see if there is a right-hand side
    if st.pos < |st.input| && st.input[st.pos] == '*':
        // add expression
        st.pos = st.pos + 1
        (rhs,st) = parseMulDivExpr(st)                
        return {op: MUL, lhs: lhs, rhs: rhs}, st
    else if st.pos < |st.input| && st.input[st.pos] == '/':
        // subtract expression
        st.pos = st.pos + 1
        (rhs,st) = parseMulDivExpr(st)        
        return {op: DIV, lhs: lhs, rhs: rhs}, st
    
    // No right-hand side
    return (lhs,st)

(Expr, State) parseTerm(State st) throws SyntaxError:
    st = parseWhiteSpace(st)        
    if st.pos < |st.input|:
        if isLetter(st.input[st.pos]):
            return parseIdentifier(st)
        else if isDigit(st.input[st.pos]):
            return parseNumber(st)
        else if st.input[st.pos] == '[':
            return parseList(st)
    throw SyntaxError("expecting number or variable",st.pos,st.pos)

(Var, State) parseIdentifier(State st):    
    txt = ""
    // inch forward until end of identifier reached
    while st.pos < |st.input| && isLetter(st.input[st.pos]):
        txt = txt + st.input[st.pos]
        st.pos = st.pos + 1
    return ({id:txt}, st)

(Expr, State) parseNumber(State st) throws SyntaxError:    
    // inch forward until end of identifier reached
    start = st.pos
    while st.pos < |st.input| && isDigit(st.input[st.pos]):
        st.pos = st.pos + 1    
    return Int.parse(st.input[start..st.pos]), st

(Expr, State) parseList(State st) throws SyntaxError:    
    st.pos = st.pos + 1 // skip '['
    st = parseWhiteSpace(st)
    l = [] // initial list
    firstTime = true
    while st.pos < |st.input| && st.input[st.pos] != ']':
        if !firstTime && st.input[st.pos] != ',':
            throw SyntaxError("expecting comma",st.pos,st.pos)
        else if !firstTime:
            st.pos = st.pos + 1 // skip ','
        firstTime = false
        e,st = parseAddSubExpr(st)
        // perform annoying error check    
        l = l + [e]
        st = parseWhiteSpace(st)
    st.pos = st.pos + 1
    return l,st
 
// Parse all whitespace upto end-of-file
State parseWhiteSpace(State st):
    while st.pos < |st.input| && isWhiteSpace(st.input[st.pos]):
        st.pos = st.pos + 1
    return st

// Determine what is whitespace
bool isWhiteSpace(char c):
    return c == ' ' || c == '\t' || c == '\n' || c == '\r'

// ====================================================
// Main Method
// ====================================================

public void ::main(System sys, [string] args):
    file = File.Reader(args[0])
    input = String.fromASCII(file.read())

    if(|args| == 0):
        sys.out.println("no parameter provided!")
    else:
        try:
            env = {"$"->0} 
            st = {pos: 0, input: input}
            while st.pos < |st.input|:
                s,st = parse(st)
                r = evaluate(s.rhs,env)
                if s is Set:
                    env[s.lhs] = r
                else:
                    sys.out.println(r)
                st = parseWhiteSpace(st)
        catch(SyntaxError e2):
            sys.out.println("syntax error: " + e2.msg)
        catch(RuntimeError e1):
            sys.out.println("runtime error: " + e1.msg)
