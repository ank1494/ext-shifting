-- Returns the edges of the complete bipartite graph K_{m,n} as a list of pairs,
-- with vertices {0..m-1} on one side and {m..m+n-1} on the other.
-- Named "completeBipartiteEdges" to avoid conflict with M2's protected built-in
-- "completeBipartite" (which returns a Graph type from the Graphs package).
completeBipartiteEdges = (m, n) -> (
    graph := {};
    for i from 0 to m - 1 do
        for j from m to m + n - 1 do
            graph = append(graph, {i, j});
    graph)

doc ///
  Key
    completeBipartiteEdges
  Headline
    construct the edge list of the complete bipartite graph K_{m,n}
  Usage
    completeBipartiteEdges(m, n)
  Description
    Example
      completeBipartiteEdges(2, 3)
///
