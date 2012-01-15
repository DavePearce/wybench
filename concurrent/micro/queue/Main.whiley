import whiley.lang.*
import * from whiley.lang.System
import * from whiley.io.File
import * from whiley.lang.Errors

// ========================================================
// Benchmark
// ========================================================

define Queue as ref { [int] items }
	 
int Queue::get():
    item = this->items[0]
    this->items = this->items[1..]
    return item
	 
void Queue::put(int item):
    this->items = this->items + [item]

bool Queue::isEmpty():
    return |this->items| == 0

Queue ::Queue():
    return new { items: [] }

// ========================================================
// Parser
// ========================================================

(int,int) parseInt(int pos, string input) throws SyntaxError:
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
    return c == ' ' || c == '\t' || c == '\n' || c == '\r'

// ========================================================
// Main
// ========================================================

void ::main(System.Console sys):
    try:
        file = File.Reader(sys.args[0])
        input = String.fromASCII(file.read())
        pos = 0
        data = []
        pos = skipWhiteSpace(pos,input)
        // first, read data
        while pos < |input|:
            i,pos = parseInt(pos,input)
            data = data + [i]
            pos = skipWhiteSpace(pos,input)
        // second, run the benchmark
        queue = Queue()
        for d in data:
            queue.put(d)
        while !queue.isEmpty():
            sys.out.println(queue.get())
    catch(SyntaxError e):
        sys.out.println("syntax error")

    
