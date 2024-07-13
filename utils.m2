swap = (l, i, j) -> l / (k -> if k == i then j else if k == j then i else k);
swapTable = (tbl, i, j) -> applyTable(tbl, (k -> if k == i then j else if k == j then i else k));

--get degree of vrt in cplx
--cplx can be 2 dimensional if closed surface, otherewise should be a graph
dgr = (cplx, vrt) -> number(cplx, i -> member(vrt, i));


kSkeleton = (l,k) -> (result = {};
     for i from 0 to #l - 1 do (result = join(result, subsets(l_i,k)););
     toList set (result / (i -> sort i))
	 );
	 
getEdges = cplx -> kSkeleton(cplx, 2);
getVertices = cplx -> toList set flatten cplx; --kSkeleton(cplx, 1) also works

getBoundaryEdges = surface -> (
	edges := getEdges surface;
	select(edges, e -> 1 == #select(surface, f -> isSubset(e, f)))
);
	 
eulerCharSrfc = surface -> (			--assume surface only contains triangles
	#surface + #(getVertices surface) - #(getEdges surface)
);

is4prime = complex -> (
	deg4 := select(getVertices complex, v -> (dgr(complex, v) == 4));
	prs := subsets(deg4, 2);
	all(prs, p -> (all(complex, f -> (not isSubset(p, f)))))
);

isConnected = cplx -> (
	verts := getVertices cplx;
	componentVerts := set {verts_0};
	unprocessedVerts := componentVerts;
	currentV := -1;
	neighbors := set {};
	while #unprocessedVerts > 0 do (
		currentV = (toList unprocessedVerts)_0;
		unprocessedVerts = unprocessedVerts - (set {currentV});
		neighbors = set flatten select(cplx, s -> member(currentV,s));
		neighbors = neighbors - componentVerts;
		componentVerts = componentVerts + neighbors;
		unprocessedVerts = unprocessedVerts + neighbors;		
	);
	#verts == #componentVerts
);

isCycle = graph -> (
	(isConnected graph) and all(getVertices graph, v -> 2 == degreeOfVertex(graph, v))
);

isPinchedDiskBdry = graph -> (
    (isConnected graph) and
    all(getVertices graph, v -> member(degreeOfVertex(graph, v), {2,4})) and
    1 == numberOfVerticesWithDegree(graph, 4)
);

degreeOfVertex = (graph, v) -> #select(graph, e -> member(v,e));
numberOfVerticesWithDegree = (graph, deg) -> #select(getVertices graph, v -> (deg == degreeOfVertex(graph, v)));

--returns vertices that make a missing triangle with edge
findEdgeMissingTriangles = (srfc, edge) -> (
	edge = sort edge;
	srfc = srfc / (t -> sort t);
	verts := getVertices srfc;
	edges := getEdges srfc;
	select(verts, v -> ((not member(v, edge)) and (not member(sort append(edge, v), srfc)) and all(edge, ev -> member(sort {v, ev}, edges))))
);

findEdgesWithOneMissingTriangle = srfc -> (
	edges := getEdges srfc;
	select(edges, e -> 1 == #(findEdgeMissingTriangles(srfc, e)))
);

outputListToFile = (l, fName) -> (
    outf := fName << "{" << l_0 << endl;
    for i from 1 to #l - 1 do (outf << "," << l_i << endl);
    outf << "}" << close;
);