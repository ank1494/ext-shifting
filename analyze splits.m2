--gets surface w boundary, a vertex on the boundary, two neighbors of the vertex, and an edge connected to the vertex.
--returns true if both neighbors are on the same side of the edge
isSameSideSplit = (surface, bdyVertex, neighbors, critEdge) -> (
	if #((set critEdge) * (set neighbors)) > 0 or member(sort append(neighbors, bdyVertex), surface) then true
	else (
		triangles := select(surface, t -> member(bdyVertex, t));
		done := false;
		result := true;
		nextTriangle := (select(triangles, t -> isSubset(critEdge, t)))_0;
		prevTriangle := critEdge;
		while not done do (
			currentV := (toList (set nextTriangle) - (set prevTriangle))_0;
			if member(currentV, neighbors) then (
				result = not result;
				done = result;
			);
			if not done then (
				prevTriangle = nextTriangle;
				nextTriangle = select(triangles, t -> member(currentV, t) and t != prevTriangle);
				if #nextTriangle > 0 then nextTriangle = nextTriangle_0
				else done = true;
			);
		);
		result
	)
);


analyzeCritRegions = (complex, finalEdge) -> (--returns largest critical polygon size
	maxBdry :=0;
	splits := nonTrivSplits complex;
	splitsWithShiftData := {};
	edges := {};
	shift1 := {};
	shift2 := {};
	data := {};
	for i from 0 to #splits - 1 do (
		edges = getEdges splits_i_0;
		--shift 2 times to minimize chance of error
		shift1 = extShiftLex edges;
		shift2 = extShiftLex edges;
		data = {splits_i_1, (finalEdge == shift1_-1) and (finalEdge == shift2_-1)};
		data = append(data, splits_i_0);
		splitsWithShiftData = append(splitsWithShiftData, data);
	);
	remainingSplits := set splitsWithShiftData;
	vertices := getVertices complex;
	critVertices := set {};
	v := -1;
	splitsFromV := {};
	for i from 0 to #vertices - 1 do (
		v = vertices_i;
		splitsFromV = select(splitsWithShiftData, d -> d_0_SPLITBASE == v);
		if all(splitsFromV, s -> s_1) then (
			critVertices = critVertices + set {v};
			remainingSplits = remainingSplits - (set splitsFromV);
		);
	);
	remainingSplits = toList remainingSplits;
	if #critVertices == #vertices then (
		print "uh oh - all vertices are critical!";
		logException(complex, "all vertices are critical")) 
	else(
		remainingCritVertices := critVertices;
		unprocessedVsForRegion := set {};
		regionTriangles := set {};
		regionEdges := {};
		inners := set {};
		boundary := set {};
		boundaryEdges := {};
		innerEdges := {};
		separatingEdges := {};
		currentV := -1;
		trianglesWithCurrentV := {};
		neighbors := set {};
		critNeighbors := {};
		regionDetailStr := "";
		regionsCount := 0;
		eulerChar := 0;
		while 0 < #remainingCritVertices do (
			unprocessedVsForRegion = set {(toList remainingCritVertices)_0};
			remainingCritVertices = remainingCritVertices - unprocessedVsForRegion;
			regionTriangles = set {};
			inners = set {};
			--boundary = set {};
			while 0 < #unprocessedVsForRegion do (--find region
				currentV = (toList unprocessedVsForRegion)_0;
				unprocessedVsForRegion = unprocessedVsForRegion - (set {currentV});
				inners = inners + set {currentV};
				trianglesWithCurrentV = select(complex, t -> member(currentV, t));
				regionTriangles = regionTriangles + set trianglesWithCurrentV;
				neighbors = (set flatten trianglesWithCurrentV) - inners;
				critNeighbors = neighbors * remainingCritVertices;
				unprocessedVsForRegion = unprocessedVsForRegion + critNeighbors;
				remainingCritVertices = remainingCritVertices - critNeighbors;
				--boundary = boundary + (neighbors - critVertices);
			);
			
			regionTriangles = toList regionTriangles;
			regionEdges = getEdges regionTriangles;
			boundaryEdges = getBoundaryEdges regionTriangles;
			boundary = set getVertices boundaryEdges;
			innerEdges = select(regionEdges, e -> not isSubset(e, boundary));
			separatingEdges = toList ((set regionEdges) - ((set boundaryEdges) + (set innerEdges)));
			if #separatingEdges > 0 then (
				logInfo concatenate("separating edges: ", toString separatingEdges);
			);
			
			regionVertices = boundary + inners;
			maxBdry = max(maxBdry, #boundary);
			eulerChar = eulerCharSrfc regionTriangles;
			
			logInfo(concatenate("critical region- inner vertices: ", toString inners, ", boundary: ", toString boundaryEdges, ", euler characteristic: ", toString eulerChar));
			regionDetailStr = concatenate("inners: ", toString inners, ", boundary: ", toString boundaryEdges, ", region: ", toString regionTriangles);
			
			if not isConnected boundaryEdges then (
				print "uh oh! region boundary is not connected";
				logException(complex, concatenate("critical region boundary is not connected, ", regionDetailStr));
			) else if not isCycle boundaryEdges then (
				print "uh oh! region boundary is not a cycle";
				logException(complex, concatenate("critical region boundary is not a cycle, ", regionDetailStr));
			);
			
			--check euler characteristic of region			
			if 1 != eulerChar and 0 != eulerChar then (
				print "uh oh! region is not a disk or a mobius strip!";
				logException(complex, concatenate("critical region is not a disk or mobius strip, ", regionDetailStr));
			);
			
			--check difference between boundary and inner
			--if (#boundary - #inners > 3) then (
			--check that innerEdges is not too big
			if (4 * #inners < #innerEdges) then (
				print "uh oh! few inner edges";
				logException(complex, concatenate("critical region has few inner edges, ", regionDetailStr));
			);  
				
			--check splits inside region and remove from remainingSplits
			outerSplits := select(remainingSplits, currentSplit -> not (member(sort {currentSplit_0_SPLITBASE, currentSplit_0_SPLITNEIGHBORS_0}, regionEdges) and member(sort {currentSplit_0_SPLITBASE, currentSplit_0_SPLITNEIGHBORS_1}, regionEdges)));
			suspectedInnerSplits := toList (set remainingSplits) - (set outerSplits);
			suspectVerts := getVertices separatingEdges;
			for i from 0 to #suspectVerts - 1 do (
				critEdges := select(separatingEdges, e -> member(suspectVerts_i, e));
				foundSplits := select(suspectedInnerSplits, currentSplit -> currentSplit_0_SPLITBASE == suspectVerts_i);
				foundSplits = select(foundSplits, currentSplit -> all(critEdges, e -> not isSameSideSplit(regionTriangles, suspectVerts_i, currentSplit_0_SPLITNEIGHBORS, e)));
				outerSplits = outerSplits | foundSplits;
			);
			
			
			remainingSplits = outerSplits;
			
			regionsCount = regionsCount + 1;
		);
		logInfo concatenate("regions count: ", toString regionsCount);
		remainingSplits = select(remainingSplits, s -> s_1);
		if #remainingSplits > 0 then (
			print "uh oh! bad split outside critical regions";
			logException(complex, concatenate("bad splits outside critical regions: ", toString ((toList remainingSplits) / (s -> concatenate("base: ", toString s_0_SPLITBASE, ", neighbors: ", toString s_0_SPLITNEIGHBORS)))));
			for i from 0 to #remainingSplits - 1 do saveSplitToAnalyze remainingSplits_i_2;
		);
	);
	maxBdry
);

analyzeCritRegionsTriangle = (complex, finalTriangle) -> (--returns largest critical polygon size
	maxBdry :=0;
	splits := nonTrivSplits complex;
	splitsWithShiftData := {};
	shift1 := {};
	shift2 := {};
	data := {};
	for i from 0 to #splits - 1 do (
		--shift 2 times to minimize chance of error
		shift1 = extShiftLex splits_i_0;
		shift2 = extShiftLex splits_i_0;
		data = {splits_i_1, member(finalTriangle, shift1) and member(finalTriangle, shift2)};
		data = append(data, splits_i_0);
		splitsWithShiftData = append(splitsWithShiftData, data);
	);
	remainingSplits := set splitsWithShiftData;
	vertices := getVertices complex;
	critVertices := set {};
	v := -1;
	splitsFromV := {};
	for i from 0 to #vertices - 1 do (
		v = vertices_i;
		splitsFromV = select(splitsWithShiftData, d -> d_0_SPLITBASE == v);
		if all(splitsFromV, s -> s_1) then (
			critVertices = critVertices + set {v};
			remainingSplits = remainingSplits - (set splitsFromV);
		);
	);
	remainingSplits = toList remainingSplits;
	if #critVertices == #vertices then (
		print "uh oh - all vertices are critical!";
		logException(complex, "all vertices are critical")) 
	else(
		remainingCritVertices := critVertices;
		unprocessedVsForRegion := set {};
		regionTriangles := set {};
		regionEdges := {};
		inners := set {};
		boundary := set {};
		boundaryEdges := {};
		innerEdges := {};
		separatingEdges := {};
		currentV := -1;
		trianglesWithCurrentV := {};
		neighbors := set {};
		critNeighbors := {};
		regionDetailStr := "";
		regionsCount := 0;
		eulerChar := 0;
		while 0 < #remainingCritVertices do (
			unprocessedVsForRegion = set {(toList remainingCritVertices)_0};
			remainingCritVertices = remainingCritVertices - unprocessedVsForRegion;
			regionTriangles = set {};
			inners = set {};
			--boundary = set {};
			while 0 < #unprocessedVsForRegion do (--find region
				currentV = (toList unprocessedVsForRegion)_0;
				unprocessedVsForRegion = unprocessedVsForRegion - (set {currentV});
				inners = inners + set {currentV};
				trianglesWithCurrentV = select(complex, t -> member(currentV, t));
				regionTriangles = regionTriangles + set trianglesWithCurrentV;
				neighbors = (set flatten trianglesWithCurrentV) - inners;
				critNeighbors = neighbors * remainingCritVertices;
				unprocessedVsForRegion = unprocessedVsForRegion + critNeighbors;
				remainingCritVertices = remainingCritVertices - critNeighbors;
				--boundary = boundary + (neighbors - critVertices);
			);
			
			regionTriangles = toList regionTriangles;
			regionEdges = getEdges regionTriangles;
			boundaryEdges = getBoundaryEdges regionTriangles;
			boundary = set getVertices boundaryEdges;
			innerEdges = select(regionEdges, e -> not isSubset(e, boundary));
			separatingEdges = toList ((set regionEdges) - ((set boundaryEdges) + (set innerEdges)));
			if #separatingEdges > 0 then (
				logInfo concatenate("separating edges: ", toString separatingEdges);
			);
			
			regionVertices = boundary + inners;
			maxBdry = max(maxBdry, #boundary);
			eulerChar = eulerCharSrfc regionTriangles;
			
			logInfo(concatenate("critical region- inner vertices: ", toString inners, ", boundary: ", toString boundaryEdges, ", euler characteristic: ", toString eulerChar));
			regionDetailStr = concatenate("inners: ", toString inners, ", boundary: ", toString boundaryEdges, ", region: ", toString regionTriangles);
			
			if not isConnected boundaryEdges then (
				print "uh oh! region boundary is not connected";
				logException(complex, concatenate("critical region boundary is not connected, ", regionDetailStr));
			) else if not isCycle boundaryEdges then (
				print "uh oh! region boundary is not a cycle";
				logException(complex, concatenate("critical region boundary is not a cycle, ", regionDetailStr));
			);
			
			--check euler characteristic of region			
			if 1 != eulerChar and 0 != eulerChar then (
				print "uh oh! region is not a disk or a mobius strip!";
				logException(complex, concatenate("critical region is not a disk or mobius strip, ", regionDetailStr));
			);
			
			--check difference between boundary and inner
			--if (#boundary - #inners > 3) then (
			--check that innerEdges is not too big
			if (4 * #inners < #innerEdges) then (
				print "uh oh! few inner edges";
				logException(complex, concatenate("critical region has few inner edges, ", regionDetailStr));
			);  
				
			--check splits inside region and remove from remainingSplits
			outerSplits := select(remainingSplits, currentSplit -> not (member(sort {currentSplit_0_SPLITBASE, currentSplit_0_SPLITNEIGHBORS_0}, regionEdges) and member(sort {currentSplit_0_SPLITBASE, currentSplit_0_SPLITNEIGHBORS_1}, regionEdges)));
			suspectedInnerSplits := toList (set remainingSplits) - (set outerSplits);
			suspectVerts := getVertices separatingEdges;
			for i from 0 to #suspectVerts - 1 do (
				critEdges := select(separatingEdges, e -> member(suspectVerts_i, e));
				foundSplits := select(suspectedInnerSplits, currentSplit -> currentSplit_0_SPLITBASE == suspectVerts_i);
				foundSplits = select(foundSplits, currentSplit -> all(critEdges, e -> not isSameSideSplit(regionTriangles, suspectVerts_i, currentSplit_0_SPLITNEIGHBORS, e)));
				outerSplits = outerSplits | foundSplits;
			);
			
			
			remainingSplits = outerSplits;
			
			regionsCount = regionsCount + 1;
		);
		logInfo concatenate("regions count: ", toString regionsCount);
		remainingSplits = select(remainingSplits, s -> s_1);
		if #remainingSplits > 0 then (
			print "uh oh! bad split outside critical regions";
			logException(complex, concatenate("bad splits outside critical regions: ", toString ((toList remainingSplits) / (s -> concatenate("base: ", toString s_0_SPLITBASE, ", neighbors: ", toString s_0_SPLITNEIGHBORS)))));
			for i from 0 to #remainingSplits - 1 do saveSplitToAnalyze remainingSplits_i_2;
		);
	);
	maxBdry
);