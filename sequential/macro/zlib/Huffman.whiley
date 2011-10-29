// Provide data types and functions for manipulating Huffman codes, 
// according to RFD1951.  This includes the notion of a tree for
// encoding/deciding them efficiently.

import * from whiley.lang.System
import whiley.lang.*
import Error from whiley.lang.Errors

// A code is s list of bits
define Code as [bool]

// Define the binary to hold Huffman codes
public define Literal as int
public define Pair as {int distance, int length}
public define Leaf as Pair | Literal
public define Node as {Tree one, Tree zero}
public define Tree as Leaf | Node | null

public Tree Empty():
    return null // empty tree

// Map a given code to a given value
public Tree put(Tree tree, Code code, Leaf value) throws Error:
    return put(tree, code, value, |code|)

// helper
Tree put(Tree tree, [bool] bits, Leaf value, int index) throws Error:
    if index == 0:
        return value
    else:
        index = index - 1
        bit = bits[index]
        if tree is Leaf:
            throw Error("invalid tree")
        else if tree is Node:
            if bit:
                tree.one = put(tree.one,bits,value,index)
            else:
                tree.zero = put(tree.zero,bits,value,index)
            return tree
        else:
            // empty tree
            if bit:
                one = put(null,bits,value,index)
                zero = null
            else:
                one = null
                zero = put(null,bits,value,index)
            return {one: one, zero: zero}

Tree get(Tree tree, bool bit) throws Error:
    if tree is Node:
        if bit:
            return tree.one
        else:
            return tree.zero
    else:
        throw Error("error")

// return the number of code,symbol mappings
public int size(Tree tree):
    if tree == null:
        return 0
    else if tree is Leaf:
        return 1
    else:
        // tree is Node
        return size(tree.one) + size(tree.zero)
    
// Generate the Huffman codes using a given sequence of code lengths.
// To understand what this method does, you really need to consult
// rfc1951.
[Code|null] generate([int] codeLengths):
    // (1) Count the number of codes for each code length.
    bl_count = []
    for clen in codeLengths:
        while |bl_count| <= clen:
            bl_count = bl_count + [0]
        bl_count[clen] = bl_count[clen] + 1
    // 2) Find the numerical value of the smallest code for each 
    //    code length: 
    code = 0
    bl_count[0] = 0
    next_code = [0]
    max_code = 0
    for bits in 0 .. |bl_count|:
        code = (code + bl_count[bits]) * 2        
        next_code = next_code + [code]
        max_code = Math.max(max_code,code)    
    // 3) Assign numerical values to all codes, using consecutive 
    //    values for all codes of the same length with the base
    //    values determined at step 2. Codes that are never used  
    //    (which have a bit length of zero) must not be assigned 
    //    a value. 
    codes = []
    for n in 0 .. |codeLengths|:
        len = codeLengths[n]
        if len != 0:
            code = construct(next_code[len],len)
            codes = codes + [code]
            next_code[len] = next_code[len] + 1
        else:
            codes = codes + [null]
    // done
    return codes

// convert an integer into a code value of a given length.
Code construct(int code, int len):
    r = []
    for i in 0 .. len:
        if (code % 2) == 1:
            r = r + [true]
        else:
            r = r + [false]
        code = code / 2
    return r

public void ::main(System sys, [string] args):
    //codes = generate([2,1,3,3])
    codes = generate([3,3,3,3,3,2,4,4])
    // first, print generated codes
    for i in 0..|codes|:
        sys.out.print(i + " : ")
        code = codes[i]
        if code == null:
            sys.out.println("")
        else:
            for j in |code| .. 0:
                if code[j-1]:
                    sys.out.print("1")
                else:
                    sys.out.print("0")
            sys.out.println("")
    // second, construct corresponding binary tree
    try:
        tree = Empty()
        for i in 0..|codes|:
            code = codes[i]
            if code != null:
                tree = put(tree,code,i)
        sys.out.println(tree)
    catch(Error e):
         sys.out.println("error")
            
