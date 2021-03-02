import std::ascii
import std::array

import uint from std::integer

public property sorted(int[] xs, int start, int end) 
where start >= end || all { i in start .. (end-1) | xs[i] <= xs[i+1] }

// ===================================================================
// Merge sort
// ===================================================================

/**
 * Sort a given list of items into ascending order, producing a sorted
 * list.
 */
public function merge_sort(int[] items) -> (int[] rs)
// Output is permutation of input
ensures |items| == |rs|
// Output is sorted
ensures sorted(rs,0,|rs|):
    //
    return merge_sort(items,0,|items|)

/**
 * Perform a merge sort a given slice of an array.  Specifically, all
 * items from start upto (but not including) end are sorted at the end:
 *
 *     start --++          ++-- end
 *             ||          ||
 *             VV          VV
 *   +--+--+--+--+--+--+--+--+--+--+--+
 *   | ... |11|05|10|03|21|22|24| ... |
 *   +--+--+--+--+--+--+--+--+--+--+--+
 *
 *            |           |
 *            |           |
 *            V           V
 *
 *   +--+--+--+--+--+--+--+--+--+--+--+
 *   | ... |11|03|05|10|21|22|24| ... |
 *   +--+--+--+--+--+--+--+--+--+--+--+
 *
 * Everything outside the specified region is untouched.
 */ 
function merge_sort(int[] items, uint start, uint end) -> (int[] nitems)
// Require 
requires start <= end && end <= |items|
// Array return has same size
ensures |items| == |nitems|
// Everything outside region untouched
ensures array::equals(items,nitems,0,start) && array::equals(items,nitems,end,|items|)
// Region has been sorted
ensures sorted(nitems,start,end):
    //
    if (start+1) < end:
        uint pivot = (end + start) / 2
        // recursively sort left region
        items = merge_sort(items,start,pivot)
        // recursively sort right region
        items = merge_sort(items,pivot,end)
        // merge subregions
        items = merge(items,start,pivot,end)
    // Done
    return items

/**
 * Merge two sorted partitions of an array into one sorted partition.
 * The first partiaion goes from start upto (but not including) pivot,
 * whilst the second goes from pivot upto (but not including) end:
 *
 *  start --++  pivot --++       ++-- end
 *          ||          ||       ||
 *          VV          VV       VV
 *   +--+--+--+--+--+--+--+--+--+--+--+--+
 *   | ... |05|10|11|20|03|21|22|24| ... |
 *   +--+--+--+--+--+--+--+--+--+--+--+--+
 *
 *            |              |
 *            |              |
 *            V              V
 *
 *   +--+--+--+--+--+--+--+--+--+--+--+--+
 *   | ... |03|05|10|11|20|21|22|24| ... |
 *   +--+--+--+--+--+--+--+--+--+--+--+--+
 *
 *
 * Everything outside the specified region is untouched.
 */
function merge(int[] items, uint start, uint pivot, uint end) -> (int[] nitems)
// Partitions must make sense
requires start <= pivot && pivot <= end && end <= |items|
// Everything in first & second partition must be sorted
requires sorted(items,start,pivot) && sorted(items,pivot,end)
// Everything in the final partiaion is sorted
ensures sorted(nitems,start,end)
// Everything outside region untouched
ensures array::equals(items,nitems,0,start) && array::equals(items,nitems,end,|items|):
    // TODO: in-place merge should be preferred!
    int[] rs = items
    //
    uint l = start
    uint r = pivot
    uint i = start
    while l < pivot && r < end
    // Sizes unchanged
    where |rs| == |items| && start <= l && pivot <= r
    // Parts outside parition unchanged
    where array::equals(items,rs,0,start) && array::equals(items,rs,end,|items|)
    // Balancing between variables
    where (i-start) == (l-start) + (r-pivot):
        if items[l] <= items[r]:
            rs[i] = items[l] 
            l = l + 1
        else:
            rs[i] = items[r] 
            r = r + 1
        i = i + 1
    // Finish off left partition
    rs = array::copy(items,l,rs,i,pivot - l)
    // Finish off right partition    
    rs = array::copy(items,r,rs,i,end - r)
    // Done 
    return rs

function to_string(int[] items) -> ascii::string:
    //
    ascii::string s = "["
    //
    for i in 0..|items|:
        if i != 0:
            s = array::append(s,",")
        s = array::append(s,ascii::to_string(items[i]))
    //
    return array::append(s,"]")

// ===================================================================
// Binary Search
// ===================================================================

/**
 * Perform a classical binary search on a sorted list to determine the
 * index of a given item (if it is contained) or null (otherwise).
 */
function search(int[] list, int item) -> null|int
requires sorted(list,0,|list|):
    uint lower = 0
    uint upper = |list| // 1 past last element considered
    while lower < upper where upper <= |list|:
        uint pivot = (lower + upper) / 2
        int candidate = list[pivot]
        if candidate == item:
            return pivot
        else if candidate < item:
            lower = pivot + 1
        else:
            upper = pivot
    // failed to find it
    return null

// ============================================
// Tests
// ============================================

public method test_01():
    int[] items = merge_sort([])
    assume items == []
    assume search(items,-1) == null
    assume search(items,0) == null
    assume search(items,1) == null
    assume search(items,2) == null

public method test_02():
    int[] items = merge_sort([0])
    assume items == [0]
    assume search(items,-1) == null
    assume search(items,0) == 0
    assume search(items,1) == null
    assume search(items,2) == null

public method test_03():
    int[] items = merge_sort([1,0])
    assume items == [0,1]
    assume search(items,-1) == null
    assume search(items,0) == 0
    assume search(items,1) == 1
    assume search(items,2) == null
