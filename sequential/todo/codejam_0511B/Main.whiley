import whiley.lang.*
import * from whiley.lang.*
import * from whiley.io.File

// ===============================================
// Definitions
// ===============================================

define Combinarion as (char,char)

define Test as {
    //{Combinarion->char} combines,
    {void} combines,
    {Combinarion} opposes,
    [char] sequence
}

// ===============================================
// Parser
// ===============================================

[Test] parseFile(string input) throws SyntaxError:
    ntests,pos = parseInt(0,input)
    tests = []
    while ntests > 0:
        t,pos = parseTest(pos,input)
        tests = tests + [t]
        ntests = ntests - 1
    return tests

(Test,int) parseTest(int pos, string input) throws SyntaxError:
    combines = {}
    opposes = {}
    sequence = []
    ncombs,pos = parseInt(pos,input)
    while ncombs > 0:
        pos = skipWhiteSpace(pos,input)
        c1 = input[pos]
        c2 = input[pos+1]
        c3 = input[pos+2]
        pos = pos + 3
        //combines[(c1,c2)] = c3
        ncombs = ncombs - 1
    nopps,pos = parseInt(pos,input)
    while nopps > 0:
        pos = skipWhiteSpace(pos,input)
        c1 = input[pos]
        c2 = input[pos+1]
        pos = pos + 2
        opposes = opposes + {(c1,c2)}
        nopps = nopps - 1
    nseqs,pos = parseInt(pos,input)
    pos = skipWhiteSpace(pos,input)
    while nseqs > 0:
        sequence = sequence + [input[pos]]
        pos = pos + 1
        nseqs = nseqs - 1
    pos = skipWhiteSpace(pos,input)
    test = { combines: combines,
            opposes: opposes,
            sequence: sequence }
    return test,pos        

(int,int) parseInt(int pos, string input) throws SyntaxError:
    pos = skipWhiteSpace(pos,input)
    start = pos
    while pos < |input| && Char.isDigit(input[pos]):
        pos = pos + 1
    if pos == start:
        throw SyntaxError("Missing number",pos,pos)
    return Int.parse(input[start..pos]),pos

int skipWhiteSpace(int index, string input):
    while index < |input| && isWhiteSpace(input[index]):
        index = index + 1
    return index

bool isWhiteSpace(char c):
    return c == ' ' || c == '\t' || c == '\n'


// ===============================================
// Main Computation
// ===============================================

void ::main(System sys, [string] args):
    file = File.Reader(args[0])
    input = String.fromASCII(file.read())
    try:
        tests = parseFile(input)
        sys.out.println("PARSED: " + |tests| + " tests")
    catch(SyntaxError e):
        sys.out.println("error - " + e.msg)
