--assume cplx is a 2 dimensional surface without boundary
--split the 0th vertex
vertexSplit0 = cplx -> (
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

--assume cplx is a 2 dimensional surface without boundary
--split the 0th vertex
nonTrivVertexSplit0 = cplx -> (
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
	
	--generate splits
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
			infoString := splitInfoString(startVertex, endVertex, triangleCount, trianglesLength - triangleCount);
			infoList := splitInfoList(startVertex, endVertex, triangleCount, trianglesLength - triangleCount);
			splits = append(splits, toList {toAdd, infoList});
		);
	);
	
	--return all vertex splits
	splits
);

--consts for accessing split data
SPLITDATA = 1;
SPLITBASE = 0;
SPLITNEIGHBORS = 1;
SPLITRATIO = 2;

nonTrivSplits = complex -> (
	currentSplitBase := 0;
	splitInfoString = (startV, endV, side1, side2) -> (
		startV = if startV == currentSplitBase then 0 else startV;
		endV = if endV == currentSplitBase then 0 else endV;
		concatenate("base:", toString currentSplitBase, ", neighbors:", toString {startV, endV}, ", triangle ratio:", toString sort {side1, side2})
	);
	splitInfoList = (startV, endV, side1, side2) -> ( --returns {base, neighbors, ratio}
		startV = if startV == currentSplitBase then 0 else startV;
		endV = if endV == currentSplitBase then 0 else endV;
		toList {currentSplitBase, sort {startV, endV}, sort {side1, side2}}
	);
	result := {};
	vertices := getVertices complex;
	for i from 0 to #vertices - 1 do (
		currentSplitBase = vertices_i;
		newSplits := (nonTrivVertexSplit0 swapTable(complex, 0, vertices_i));
		result = join(result, newSplits / (splt -> {(swapTable(splt_0, 0, vertices_i) / (s -> sort s)), splt_1}));
	);
	result
);


--assume cplx contains only triangles
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

splitAllTriangles = cplx -> (
	maxVertex := 1 + max flatten cplx;
	split := {};
	for i from 0 to #cplx - 1 do (
		split = join(split, (subsets(cplx_i, 2) / (x -> sort x)) / (x -> append(x, maxVertex + i)));
	);
	split
);

--get contractible edges
contractibles = surface -> (
	edges := getEdges surface;
	select(edges, e -> 3 == #edges - #(contractCplx(edges, e)))
);

--edge must have exactly 2 elements
contractCplx = (cplx, edge) -> (
	sEdge := sort edge;
	--remove faces containing edge
	sCplx := select(cplx / (i -> sort i), i -> not isSubset(sEdge, i));
	ctrctd := applyTable(sCplx, (i -> if i == sEdge_1 then sEdge_0 else i));
	unique(ctrctd / (i -> sort i))
);