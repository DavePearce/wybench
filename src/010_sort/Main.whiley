import whiley.lang.*
import whiley.io.*
import whiley.io.File
import whiley.lang.System

import wybench.Parser

type sortedList is (int[] xs) 
where |xs| <= 1 || all { i in 0 .. |xs|-1 | xs[i] <= xs[i+1] }

/**
 * Sort a given list of items into ascending order, producing a sorted
 * list.
 */
function sort(int[] items, int start, int end) -> sortedList:
    if (start+1) < end:
        int pivot = (end + start) / 2
        int[] lhs = sort(items,start,pivot)
        int[] rhs = sort(items,pivot,end)
        int l, int r, int i = (start,pivot,start)
        while i < end && l < pivot && r < end where l >= 0 && r >= 0 && i >= 0:
            if lhs[l] <= rhs[r]:
                items[i] = lhs[l] 
                l=l+1
            else:
                items[i] = rhs[r] 
                r=r+1
            i=i+1
        while l < pivot:
            items[i] = lhs[l]
            i=i+1 
            l=l+1
        while r < end:
            items[i] = rhs[r] 
            i=i+1 
            r=r+1
    return items

/**
 * Perform a classical binary search on a sorted list to determine the
 * index of a given item (if it is contained) or null (otherwise).
 */
function search(sortedList list, int item) -> null|int:
    int lower = 0
    int upper = |list| // 1 past last element considered
    while lower < upper:
        int pivot = (lower + upper) / 2
        int candidate = list[pivot]
        if candidate == item:
            return pivot
        else if candidate < item:
            lower = pivot + 1
        else:
            upper = pivot
    // failed to find it
    return null

method lookFor(System.Console console, sortedList list, int item):
    int|null index = search(list,item)
    if index != null:
        console.out.print_s("FOUND: ")
        console.out.print_s(Int.toString(item))
        console.out.print_s(" in ")
        console.out.print_s(Any.toString(list))
        console.out.print_s(" @ ")
        console.out.println_s(Int.toString(index))
    else:
        console.out.print_s("NOT FOUND: ")
        console.out.print_s(Int.toString(item))
        console.out.print_s(" in ")
        console.out.print_s(Any.toString(list))

constant searchTerms is [1,2,3,4,5,6,7,8,9]

method main(System.Console sys):
    // first, read data
    File.Reader file = File.Reader(sys.args[0])
    ASCII.string input = ASCII.fromBytes(file.readAll())
    int[]|null data = Parser.parseInts(input)
    // second, sort data
    if data != null:
        data = sort(data,0,|data|)
        // third, print output
        sys.out.print_s("SORTED: ") 
        sys.out.println(Any.toString(data))
        int i = 0
        while i < |searchTerms|:
            lookFor(sys,data,i)
            i = i + 1
    else:
        sys.out.println_s("Error parsing input")

