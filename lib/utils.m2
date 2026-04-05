-- applyTable is a Macaulay2 built-in: applies a function to each entry of a list of lists.

-- Returns true if every element of lst is a non-negative integer.
allNonegInts = lst -> all(lst, i -> (ZZ === class i and i >= 0));

doc ///
  Key
    allNonegInts
  Headline
    test whether all elements of a list are non-negative integers
  Usage
    allNonegInts lst
  Description
    Example
      allNonegInts {0, 1, 2}
///

-- Increments every vertex index by 1.
incrementVertices = tbl -> applyTable(tbl, x -> x + 1);

doc ///
  Key
    incrementVertices
  Headline
    increment all vertex indices in a simplicial complex by 1
  Usage
    incrementVertices tbl
  Description
    Example
      incrementVertices {{0,1},{1,2}}
///

-- Replaces vertex i with j and j with i throughout a flat list.
swap = (l, i, j) -> l / (k -> if k == i then j else if k == j then i else k);

doc ///
  Key
    swap
  Headline
    swap two vertex labels in a flat list
  Usage
    swap(l, i, j)
  Description
    Example
      swap({0,1,2,1}, 0, 2)
///

-- Replaces vertex i with j and j with i throughout a list of lists (e.g. a simplicial complex).
swapTable = (tbl, i, j) -> applyTable(tbl, (k -> if k == i then j else if k == j then i else k));

doc ///
  Key
    swapTable
  Headline
    swap two vertex labels throughout a simplicial complex
  Usage
    swapTable(tbl, i, j)
  Description
    Example
      swapTable({{0,1,2},{0,2,3}}, 0, 3)
///

-- Returns all k-element subsets across all faces in simplices, deduplicated and sorted.
kSkeleton = (simplices,k) -> (result = {};
     for i from 0 to #simplices - 1 do (result = join(result, subsets(simplices_i,k)););
     toList set (result / (i -> sort i))
	 );

doc ///
  Key
    kSkeleton
  Headline
    compute the k-skeleton of a simplicial complex
  Usage
    kSkeleton(simplices, k)
  Description
    Example
      kSkeleton({{0,1,2},{1,2,3}}, 2)
///

-- Returns all edges (2-element faces) of the complex.
getEdges = cplx -> kSkeleton(cplx, 2);

doc ///
  Key
    getEdges
  Headline
    return all edges of a simplicial complex
  Usage
    getEdges cplx
  Description
    Example
      getEdges {{0,1,2},{1,2,3}}
///

-- Returns the set of all vertices appearing in the complex.
getVertices = cplx -> toList set flatten cplx;

doc ///
  Key
    getVertices
  Headline
    return all vertices of a simplicial complex
  Usage
    getVertices cplx
  Description
    Example
      getVertices {{0,1,2},{1,2,3}}
///

-- Returns edges that belong to exactly one triangle (the topological boundary).
getBoundaryEdges = surface -> (
	edges := getEdges surface;
	select(edges, edge -> 1 == #select(surface, f -> isSubset(edge, f)))
);

doc ///
  Key
    getBoundaryEdges
  Headline
    return the boundary edges of a triangulated surface
  Usage
    getBoundaryEdges surface
  Description
    Example
      getBoundaryEdges {{0,1,2},{1,2,3}}
///

-- Euler characteristic of a triangulated surface: F - E + V (assumes all faces are triangles).
eulerCharSrfc = surface -> (
	#surface + #(getVertices surface) - #(getEdges surface)
);

doc ///
  Key
    eulerCharSrfc
  Headline
    compute the Euler characteristic of a triangulated surface
  Usage
    eulerCharSrfc surface
  Description
    Example
      eulerCharSrfc {{0,1,2},{0,2,3},{0,3,1},{1,2,3}}
///

-- Returns true if no two degree-4 vertices are adjacent (i.e. the degree-4 vertices form an independent set).
hasNoAdjacentDegree4Vertices = complex -> (
	deg4 := select(getVertices complex, vertex -> (degreeOfVertex(complex, vertex) == 4));
	prs := subsets(deg4, 2);
	all(prs, p -> (all(complex, f -> (not isSubset(p, f)))))
);

doc ///
  Key
    hasNoAdjacentDegree4Vertices
  Headline
    test whether no two degree-4 vertices are adjacent
  Usage
    hasNoAdjacentDegree4Vertices complex
  Description
    Example
      hasNoAdjacentDegree4Vertices {{0,1,2},{1,2,3},{2,3,4},{0,2,4}}
///

-- BFS connectivity check: returns true if every vertex is reachable from the first.
isConnected = cplx -> (
	verts := getVertices cplx;
	componentVerts := set {verts_0};
	unprocessedVerts := componentVerts;
	currentV := -1;
	neighbors := set {};
	while #unprocessedVerts > 0 do (
		currentV = (toList unprocessedVerts)_0;
		unprocessedVerts = unprocessedVerts - (set {currentV});
		neighbors = set flatten select(cplx, face -> member(currentV,face));
		neighbors = neighbors - componentVerts;
		componentVerts = componentVerts + neighbors;
		unprocessedVerts = unprocessedVerts + neighbors;
	);
	#verts == #componentVerts
);

doc ///
  Key
    isConnected
  Headline
    test whether a simplicial complex is connected
  Usage
    isConnected cplx
  Description
    Example
      isConnected {{0,1},{1,2}}
///

-- A graph is a cycle iff it is connected and every vertex has degree exactly 2.
isCycle = graph -> (
	(isConnected graph) and all(getVertices graph, vertex -> 2 == degreeOfVertex(graph, vertex))
);

doc ///
  Key
    isCycle
  Headline
    test whether a graph is a simple cycle
  Usage
    isCycle graph
  Description
    Example
      isCycle {{0,1},{1,2},{0,2}}
///

-- A pinched disk boundary is connected, all vertices have degree 2 or 4, and exactly one has degree 4 (the pinch point).
isPinchedDiskBdry = graph -> (
    (isConnected graph) and
    all(getVertices graph, vertex -> member(degreeOfVertex(graph, vertex), {2,4})) and
    1 == numberOfVerticesWithDegree(graph, 4)
);

doc ///
  Key
    isPinchedDiskBdry
  Headline
    test whether a graph is the boundary graph of a pinched disk
  Usage
    isPinchedDiskBdry graph
  Description
    Example
      isPinchedDiskBdry {{0,1},{1,2},{0,2},{0,3},{0,4},{3,4}}
///

-- Number of faces of graph that contain vertex.
degreeOfVertex = (graph, vertex) -> #select(graph, edge -> member(vertex, edge));

doc ///
  Key
    degreeOfVertex
  Headline
    compute the degree of a vertex in a graph
  Usage
    degreeOfVertex(graph, vertex)
  Description
    Example
      degreeOfVertex({{0,1},{1,2},{0,2}}, 0)
///

-- Number of vertices in graph whose degree equals deg.
numberOfVerticesWithDegree = (graph, deg) -> #select(getVertices graph, vertex -> (deg == degreeOfVertex(graph, vertex)));

doc ///
  Key
    numberOfVerticesWithDegree
  Headline
    count vertices of a given degree in a graph
  Usage
    numberOfVerticesWithDegree(graph, deg)
  Description
    Example
      numberOfVerticesWithDegree({{0,1},{1,2},{0,2}}, 2)
///

-- Returns vertices v not in edge such that {v, edge_0} and {v, edge_1} are present edges
-- but {v, edge_0, edge_1} is not a face — i.e. v completes a missing triangle with edge.
findEdgeMissingTriangles = (srfc, edge) -> (
	edge = sort edge;
	srfc = srfc / (t -> sort t);
	verts := getVertices srfc;
	edges := getEdges srfc;
	select(verts, vertex -> ((not member(vertex, edge)) and (not member(sort append(edge, vertex), srfc)) and all(edge, ev -> member(sort {vertex, ev}, edges))))
);

doc ///
  Key
    findEdgeMissingTriangles
  Headline
    find vertices that form a missing triangle with a given edge
  Usage
    findEdgeMissingTriangles(srfc, edge)
  Description
    Example
      findEdgeMissingTriangles({{0,1,2},{1,2,3}}, {0,2})
///

-- Returns edges that have exactly one vertex completing a missing triangle.
findEdgesWithOneMissingTriangle = srfc -> (
	edges := getEdges srfc;
	select(edges, edge -> 1 == #(findEdgeMissingTriangles(srfc, edge)))
);

doc ///
  Key
    findEdgesWithOneMissingTriangle
  Headline
    find edges with exactly one missing triangle completion
  Usage
    findEdgesWithOneMissingTriangle srfc
  Description
    Example
      findEdgesWithOneMissingTriangle {{0,1,2},{1,2,3}}
///

TEST ///
  -- Tetrahedron boundary (topological sphere): F=4, V=4, E=6 → χ = 4+4-6 = 2
  assert(eulerCharSrfc {{0,1,2},{0,1,3},{0,2,3},{1,2,3}} == 2)
  -- Minimal 7-vertex torus: F=14, V=7, E=21 → χ = 14+7-21 = 0
  irredTori := value get "data/surface triangulations/irredTori.m2";
  assert(eulerCharSrfc (irredTori_0) == 0)
  -- Minimal 6-vertex RP²: F=10, V=6, E=15 → χ = 10+6-15 = 1
  irredPp := value get "data/surface triangulations/irredPp.m2";
  assert(eulerCharSrfc (irredPp_0) == 1)
  -- Minimal 8-vertex Klein bottle: F=16, V=8, E=24 → χ = 16+8-24 = 0
  irredKb := value get "data/surface triangulations/irredKb.m2";
  assert(eulerCharSrfc (irredKb_0) == 0)
///
