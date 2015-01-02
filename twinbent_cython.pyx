cdef base(int digits, int n, int b):
    nbaseb = [0] * digits
    cdef int nvalue = n
    cdef int k
    for k in xrange(digits):
        nbaseb[k] = nvalue % b
        nvalue //= b
    return nbaseb

cdef base4(int digits, int n):
    return base(digits, n, 4)

cdef classify(int level, int n):
    nbase4 = base4(level, n)
    cdef int nbr1 = nbase4.count(1)
    cdef int nbr2 = nbase4.count(2)
    if nbr1 + nbr2 == 0:
        return 0
    else:
        return (-1) ** nbr1

cdef is_flip(int level, phi):
    if phi == None:
        return False
    cdef int nbrnodes = 4 ** level
    cdef int k
    for k in xrange(nbrnodes):
        if classify(level, phi[k]) != -classify(level, k):
            return False
    return True

cdef is_biflip(int level, phi):
    if phi == None:
        return False
    if not is_flip(level, phi):
        return False
    cdef int nbrnodes = 4 ** level
    cdef int k
    cdef int l
    for k in xrange(nbrnodes):
        for l in xrange(nbrnodes):
            if classify(level, phi[k ^ l]) != classify(level, phi[k] ^ phi[l]):
                return False
    return True

cdef classified_graph(level):
    cdef int max_nbr_nodes = 4 ** level
    cdef int node
    cdef int nbr_source_nodes
    cdef int max_nbr_edges
    cdef int try_source
    cdef int nbr_edges
    cdef int source = 0
    source_nodes = [0]
    edge_colours = {0:0}
    for nbr_source_nodes in xrange(1, max_nbr_nodes):
        max_nbr_edges = 0
        not_yet_source_nodes = [node for node in xrange(1, max_nbr_nodes) if node not in source_nodes]
        for try_source in not_yet_source_nodes:
            try_edge_colour = {}
            for node in source_nodes:
                try_edge_colour[node] = classify(level, try_source ^ node)
            adjacent_nodes = [node for node in try_edge_colour if try_edge_colour[node] != 0]
            nbr_edges = len(adjacent_nodes)
            if nbr_edges > max_nbr_edges:
                max_nbr_edges = nbr_edges
                source = try_source
                edge_colour = try_edge_colour
        source_nodes.append(source)
        edge_colours[source] = edge_colour
    return source_nodes, edge_colours

cpdef complete_mapping(level, mapping, source_nodes=None, edge_colours=None):
    cdef int max_nbr_nodes = 4 ** level
    if len(mapping) == max_nbr_nodes:
        return mapping
    if source_nodes == None:
        source_nodes, edge_colours = classified_graph(level)
    source = source_nodes[len(mapping)]
    edge_colour = edge_colours[source]
    cdef int target
    cdef int match
    cdef int node
    target_nodes = [node for node in xrange(max_nbr_nodes) if node not in mapping.values()]
    for target in target_nodes:
        match = True
        for node in mapping:
            match = classify(level, target ^ mapping[node]) == -edge_colour[node]
            if not match:
                break
        if match:
            mapping[source] = target
            returned_mapping = complete_mapping(level, mapping, source_nodes, edge_colours)
            if returned_mapping != None:
                return returned_mapping
            else:
                del mapping[source]
    return None

def check_mapping_at_level(level):
    from time import time
    tic = time()
    phi = complete_mapping(level, {0:0})
    toc = time() - tic
    print level, toc
    print phi
    print is_biflip(level, phi)
