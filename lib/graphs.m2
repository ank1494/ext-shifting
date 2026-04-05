-- Returns the complete bipartite graph K_{m,n} with vertices {0..m-1} on one side
-- and {m..m+n-1} on the other.
completeBipartite = (m, n) -> (
    graph := {};
    for i from 0 to m - 1 do
        for j from m to m + n - 1 do
            graph = append(graph, {i, j});
    graph)

doc ///
  Key
    completeBipartite
  Headline
    construct the complete bipartite graph K_{m,n}
  Usage
    completeBipartite(m, n)
  Description
    Example
      completeBipartite(2, 3)
///
