-- "vertex split" is shortened to "split" throughout this file and callers.

-- Typed record for the geometry of a non-trivial vertex split.
-- Fields: base (the split vertex), neighbors (the two boundary neighbors that define the split arc),
--         ratio (sorted pair of triangle counts on each side of the split, smaller first),
--         intermediateVertices (pair of intermediate vertex lists, smaller list first, mirroring ratio).
VertexSplitData = new Type of HashTable

doc ///
  Key
    VertexSplitData
  Headline
    typed record for the geometry of a non-trivial vertex split
  Usage
    new VertexSplitData from { base => v, neighbors => {a,b}, ratio => {p,q} }
  Description
    Example
      new VertexSplitData from { base => 0, neighbors => {1,3}, ratio => {2,4} }
///

-- Enumerates all vertex splits of vertex 0 in a closed surface (including trivial splits).
-- Orders the triangles containing 0 in a cycle, then generates every arc decomposition
-- of that cycle — each arc gives a new vertex and a pair of new edges closing off the two sides.
allSplitsAtVertex0 = cplx -> (
	newVertex := 1 + max flatten cplx;
	--get triangles containing 0
	unsortedTriangles := select(cplx, i -> member(0,i));
	nextTriangle := unsortedTriangles_0;
	triangles := {nextTriangle};
	--order triangles in cycle
	while (#unsortedTriangles > 1) do (
		unsortedTriangles = delete(nextTriangle, unsortedTriangles);
		nextTriangle = (select(unsortedTriangles, i -> (#((set i)*(set nextTriangle)) > 1)))_0;
		triangles = append(triangles, nextTriangle);
	);
	--get vertex cycle: for each triangle, the vertex not shared with the next triangle
	trianglesLength := #triangles;
	vertexCycle := (toList (0..(trianglesLength - 1))) / (i -> (toList ((set triangles_i) - (set triangles_((i + 1) % trianglesLength))))_0);

	--generate splits
	splits := {};
	for i from 0 to (trianglesLength - 2) do (
		startVertex := vertexCycle_i;
		tempCplx := append(cplx, {0, startVertex, newVertex});
		for j from i to (trianglesLength - 2) do (
			endVertex := vertexCycle_((j + 1) % trianglesLength);
			tempCplx = delete(triangles_j, tempCplx);
			newTriangle := append(delete(0, triangles_j), newVertex);
			tempCplx = append(tempCplx, newTriangle);
			splits = append(splits, append(tempCplx, {0, endVertex, newVertex}));
		);
	);
	--return all vertex splits
	splits
);

doc ///
  Key
    allSplitsAtVertex0
  Headline
    enumerate all vertex splits of vertex 0 in a closed triangulated surface
  Usage
    allSplitsAtVertex0 cplx
  Description
    Example
      allSplitsAtVertex0 {{0,1,2},{0,2,3},{0,3,4},{0,4,1},{1,2,3},{1,3,4}}
///

-- Non-trivial vertex splits only: splits where each arc of the link of 0 has at least 2 triangles.
-- Trivial splits (separating a single triangle) are excluded because they do not change the
-- topological type of the complex in a meaningful way for the shifting analysis.
-- Returns pairs {resultComplex, VertexSplitData}.
-- splitInfoString and splitInfoList are set as callbacks by nonTrivialVertexSplits before each call.
nonTrivialSplitsAtVertex0 = cplx -> (
	newVertex := 1 + max flatten cplx;

	--get triangles containing 0
	unsortedTriangles := select(cplx, i -> member(0,i));
	nextTriangle := unsortedTriangles_0;
	triangles := {nextTriangle};

	--order triangles in cycle
	while (#unsortedTriangles > 1) do (
		unsortedTriangles = delete(nextTriangle, unsortedTriangles);
		nextTriangle = (select(unsortedTriangles, i -> (#((set i)*(set nextTriangle)) > 1)))_0;
		triangles = append(triangles, nextTriangle);
	);

	--get vertex cycle
	trianglesLength := #triangles;
	vertexCycle := (toList (0..(trianglesLength - 1))) / (i -> (toList ((set triangles_i) - (set triangles_((i + 1) % trianglesLength))))_0);

	--generate splits: inner loop ensures at least 2 triangles on each side
	splits := {};
	for i from 0 to (trianglesLength - 2) do (
		startVertex := vertexCycle_i;
		tempCplx := append(cplx, {0, startVertex, newVertex});
		tempCplx = delete(triangles_i, tempCplx);
		newTriangle := append(delete(0, triangles_i), newVertex);
		tempCplx = append(tempCplx, newTriangle);
		triangleCount := 1;
		for j from i + 1 to min(trianglesLength - 2, i + trianglesLength - 3) do (
			triangleCount = 1 + triangleCount;
			endVertex := vertexCycle_((j + 1) % trianglesLength);
			tempCplx = delete(triangles_j, tempCplx);
			newTriangle = append(delete(0, triangles_j), newVertex);
			tempCplx = append(tempCplx, newTriangle);
			toAdd := append(tempCplx, {0, endVertex, newVertex});
			-- Intermediate vertices on each side (excluding base and the two boundary neighbors).
			-- Arc side: positions i+1..j; complement side: positions j+2..(i-1) wrapping.
			complLen := trianglesLength - triangleCount - 1;
			arcIntermediates := apply(j - i, k -> vertexCycle_(i + 1 + k));
			complementIntermediates := apply(complLen, k -> vertexCycle_((j + 2 + k) % trianglesLength));
			intermediates := if triangleCount <= trianglesLength - triangleCount
			    then {arcIntermediates, complementIntermediates}
			    else {complementIntermediates, arcIntermediates};
			infoString := splitInfoString(startVertex, endVertex, triangleCount, trianglesLength - triangleCount, intermediates);
			infoList := splitInfoList(startVertex, endVertex, triangleCount, trianglesLength - triangleCount, intermediates);
			splits = append(splits, toList {toAdd, infoList});
		);
	);

	--return all non-trivial vertex splits
	splits
);

doc ///
  Key
    nonTrivialSplitsAtVertex0
  Headline
    enumerate non-trivial vertex splits of vertex 0 in a closed triangulated surface
  Usage
    nonTrivialSplitsAtVertex0 cplx
  Description
    Example
      nonTrivialSplitsAtVertex0 {{0,1,2},{0,2,3},{0,3,4},{0,4,5},{0,5,1},{1,2,3},{1,3,4},{1,4,5}}
///

-- Enumerates all non-trivial vertex splits at every vertex of complex by swapping each vertex
-- to position 0, calling nonTrivialSplitsAtVertex0, then swapping back.
-- Returns a list of {resultComplex, VertexSplitData} pairs in original vertex coordinates.
nonTrivialVertexSplits = complex -> (
	currentSplitBase := 0;
	splitInfoString = (startV, endV, side1, side2, intermediates) -> (
		startV = if startV == currentSplitBase then 0 else startV;
		endV = if endV == currentSplitBase then 0 else endV;
		concatenate("base:", toString currentSplitBase, ", neighbors:", toString {startV, endV}, ", triangle ratio:", toString sort {side1, side2})
	);
	splitInfoList = (startV, endV, side1, side2, intermediates) -> (
		startV = if startV == currentSplitBase then 0 else startV;
		endV = if endV == currentSplitBase then 0 else endV;
		-- Swap the base vertex label back in intermediate vertex lists (base was relabeled to 0).
		intermediates = intermediates / (lst -> lst / (v -> if v == currentSplitBase then 0 else v));
		new VertexSplitData from { base => currentSplitBase, neighbors => sort {startV, endV}, ratio => sort {side1, side2}, intermediateVertices => intermediates }
	);
	result := {};
	vertices := getVertices complex;
	for i from 0 to #vertices - 1 do (
		currentSplitBase = vertices_i;
		newSplits := (nonTrivialSplitsAtVertex0 swapTable(complex, 0, vertices_i));
		result = join(result, newSplits / (splt -> {(swapTable(splt_0, 0, vertices_i) / (face -> sort face)), splt_1}));
	);
	result
);

doc ///
  Key
    nonTrivialVertexSplits
  Headline
    enumerate all non-trivial vertex splits across all vertices of a triangulated surface
  Usage
    nonTrivialVertexSplits complex
  Description
    Example
      nonTrivialVertexSplits {{1,2,3},{1,3,4},{1,4,5},{1,5,6},{1,6,2},{2,3,4},{2,4,5},{2,5,6}}
///

-- Replaces each triangle with three new triangles by inserting a new vertex at its center.
-- (Barycentric subdivision restricted to one triangle at a time.)
triangleSplits = cplx -> (
	newVertex := 1 + max flatten cplx;
	rslt := {};
	for i from 0 to #cplx - 1 do (
		newTrgls := (subsets(cplx_i, 2) / (x -> sort x)) / (x -> append(x, newVertex));
		split := join(drop(cplx,{i,i}), newTrgls);
		rslt = append(rslt, split);
	);
	rslt
);

doc ///
  Key
    triangleSplits
  Headline
    enumerate all single-triangle stellar subdivisions of a triangulated complex
  Usage
    triangleSplits cplx
  Description
    Example
      triangleSplits {{0,1,2},{1,2,3}}
///

-- Performs a simultaneous stellar subdivision of every triangle, introducing one new vertex per triangle.
splitAllTriangles = cplx -> (
	maxVertex := 1 + max flatten cplx;
	split := {};
	for i from 0 to #cplx - 1 do (
		split = join(split, (subsets(cplx_i, 2) / (x -> sort x)) / (x -> append(x, maxVertex + i)));
	);
	split
);

doc ///
  Key
    splitAllTriangles
  Headline
    perform a simultaneous stellar subdivision of all triangles
  Usage
    splitAllTriangles cplx
  Description
    Example
      splitAllTriangles {{0,1,2},{1,2,3}}
///

-- An edge is contractible if contracting it reduces the edge count by exactly 3
-- (removes the edge itself and its two flanking triangles, merging their opposite vertices).
contractibles = surface -> (
	edges := getEdges surface;
	select(edges, edge -> 3 == #edges - #(contractCplx(edges, edge)))
);

doc ///
  Key
    contractibles
  Headline
    find all contractible edges in a triangulated surface
  Usage
    contractibles surface
  Description
    Example
      contractibles {{0,1,2},{0,2,3},{0,3,1},{1,2,3}}
///

-- Contracts edge by merging its second endpoint into its first throughout the complex,
-- then removing duplicate faces.
contractCplx = (cplx, edge) -> (
	sEdge := sort edge;
	--remove faces containing edge
	sCplx := select(cplx / (i -> sort i), i -> not isSubset(sEdge, i));
	ctrctd := applyTable(sCplx, (i -> if i == sEdge_1 then sEdge_0 else i));
	unique(ctrctd / (i -> sort i))
);

doc ///
  Key
    contractCplx
  Headline
    contract an edge in a simplicial complex
  Usage
    contractCplx(cplx, edge)
  Description
    Example
      contractCplx({{0,1,2},{0,2,3}}, {0,1})
///

TEST ///
  -- Fan triangulation: hub vertex 1, rim 2..n. Vertex 1's cycle is [2,3,...,n].
  n := 6;
  fanTriangles := join(apply(toList(2..(n-1)), i -> {1,i,i+1}), {{1,2,n}});
  splits := nonTrivialVertexSplits fanTriangles;
  splitsAtV1 := select(splits, pair -> (pair_1).base == 1);
  -- intermediateVertices sizes mirror ratio: iv_0 has ratio_0-1 elements, iv_1 has ratio_1-1
  assert(all(splitsAtV1, pair -> (
    iv := (pair_1).intermediateVertices;
    r := (pair_1).ratio;
    #iv == 2 and #(iv_0) == r_0 - 1 and #(iv_1) == r_1 - 1
  )));
  -- intermediateVertices cover exactly the non-neighbor rim vertices
  assert(all(splitsAtV1, pair -> (
    data := pair_1;
    iv := data.intermediateVertices;
    nbrs := set data.neighbors;
    allIntermediates := set join(iv_0, iv_1);
    rimVerts := set toList(2..n);
    allIntermediates === rimVerts - nbrs
  )))
///

TEST ///
  irredTori := value get "data/surface triangulations/irredTori.m2";
  tri := irredTori_0;
  splits := nonTrivialVertexSplits tri;
  -- Minimal 7-vertex torus: all 7 vertices have degree 6.
  -- Per degree-6 vertex, the inner loop (min(4, i+3) upper bound) gives
  -- 3+3+2+1 = 9 non-trivial splits, so 7 × 9 = 63 total.
  assert(#splits == 63)
  -- Vertex splits preserve Euler characteristic.
  chiTri := eulerCharSrfc tri;
  assert(all(splits, split -> eulerCharSrfc(split_0) == chiTri))
///
