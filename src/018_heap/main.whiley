type Heap is {
    int[] data,
    int length
} 
// Items on left branch are below their parent's item
where all { i in 0..length | (2*i)+1 < length ==> data[i] > data[(2*i)+1] }
// Items on right branch are below their parent's item
where all { i in 0..length | (2*i)+2 < length ==> data[i] > data[(2*i)+2] }

function insert(Heap heap, int item) -> Heap:
    //
    int i = heap.length
    int parent = (i-1)/2
    // First, add item to end of heap
    heap.data[i] = item
    // Second, swap item up to restore invariant
    while i > 0 && heap.data[parent] < item:
        // perform a swap
        heap.data[i] = heap.data[parent]
        heap.data[i] = item
        // update indices
        i = parent
        parent = (i-1)/2
    //
    return heap