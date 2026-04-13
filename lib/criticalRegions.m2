-- Internal typed record annotating a vertex split with shift analysis data.
-- Fields: splitData (VertexSplitData), preservesFinalEdge (bool), noVertex4 (bool), complex (list of faces).
ShiftAnnotatedSplit = new Type of HashTable

-- Typed return value of getCritRegions.
-- Fields: critRegionStrings (set of canonical region strings), nextComplexes (list of complexes for next iteration).
CritRegionsResult = new Type of HashTable

doc ///
  Key
    CritRegionsResult
  Headline
    typed return value of getCritRegions
  Usage
    result = getCritRegions(complex, finalEdge); result.critRegionStrings; result.nextComplexes
  Description
    Example
      getCritRegions({{1,2,3},{1,3,4},{1,4,2},{2,3,4}}, {1,2})
///

-- Returns a canonical string identifier for a critical region of the form "type,boundary,inner".
-- regionType: "disk" (eulerChar=1) or "mobius" (eulerChar=0)
-- boundarySize: number of boundary vertices; innerSize: number of inner vertices.
getCritRegionString = (regionType, boundarySize, innerSize) ->
    concatenate(regionType, ",", toString boundarySize, ",", toString innerSize);

doc ///
  Key
    getCritRegionString
  Headline
    produce a canonical string identifier for a critical region
  Usage
    getCritRegionString(regionType, boundarySize, innerSize)
  Description
    Example
      getCritRegionString("disk", 3, 0)
///

-- Returns true if both neighbors lie on the same side of critEdge in the triangle fan around bdyVertex.
-- Traverses the fan starting from a triangle containing critEdge, toggling a boolean each time
-- the traversal crosses one of the two neighbors. Returns true if the boolean ends unchanged (same side).
-- Short-circuits to true if a neighbor coincides with critEdge or if the three points form a triangle.
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

doc ///
  Key
    isSameSideSplit
  Headline
    test whether two neighbors lie on the same side of an edge in a surface with boundary
  Usage
    isSameSideSplit(surface, bdyVertex, neighbors, critEdge)
  Description
    Example
      isSameSideSplit({{0,1,2},{0,2,3},{0,3,4}}, 0, {1,3}, {0,2})
///

-- Analyzes the critical regions of a complex with respect to a final shift edge.
-- A vertex is critical if every non-trivial vertex split at it preserves the final edge of the shift.
-- Critical vertices are grouped into connected regions; each region is classified as disk (Euler
-- characteristic 1) or Möbius strip (Euler characteristic 0) by eulerCharSrfc. A non-cycle boundary
-- is treated as an error condition. Vertex splits outside critical regions whose final edge is
-- non-prefix (no vertex 4) are passed to the next iteration via nextComplexes.
-- Optional exemptSplits: list of {base, neighbors} pairs to exclude before shift computation.
-- Returns a CritRegionsResult.
getCritRegions = {exemptSplits => {}} >> opts -> (srfc, finalEdge) -> (
    -- Use distinct accumulator names to avoid shadowing the HashTable key symbols.
    critRegStrs := set {};
    nextCplxes := {};

    -- Compute non-trivial vertex splits; filter exempt splits before shift computation.
    rawSplits := nonTrivialVertexSplits srfc;
    rawSplits = select(rawSplits, pair -> (vsd := pair_1; not member({vsd.base, vsd.neighbors}, opts.exemptSplits)));
    splits := {};
    for i from 0 to #rawSplits - 1 do (
        splitComplex := rawSplits_i_0;
        vSplitData := rawSplits_i_1;
        shift1 := extShiftLex getEdges splitComplex;
        shift2 := extShiftLex getEdges splitComplex;
        collectGarbage();
        splits = append(splits, new ShiftAnnotatedSplit from {
            splitData => vSplitData,
            preservesFinalEdge => (finalEdge == shift1_-1) and (finalEdge == shift2_-1),
            noVertex4 => (not member(4, shift1_-1)) and (not member(4, shift2_-1)),
            complex => splitComplex
        });
    );

    -- Identify critical vertices: those where every non-trivial vertex split preserves the final edge.
    remainingSplits := set splits;
    vertices := getVertices srfc;
    critVertices := set {};
    for i from 0 to #vertices - 1 do (
        vertex := vertices_i;
        splitsFromV := select(splits, split -> split.splitData.base == vertex);
        if all(splitsFromV, split -> split.preservesFinalEdge) then (
            critVertices = critVertices + set {vertex};
            remainingSplits = remainingSplits - (set splitsFromV);
        );
    );
    remainingSplits = toList remainingSplits;

    if #critVertices == #vertices then (
        print "uh oh - all vertices are critical!";
        logException(srfc, "all vertices are critical")
    ) else (
        remainingCritVertices := critVertices;
        regionsCount := 0;
        while 0 < #remainingCritVertices do (
            -- Grow a connected region of critical vertices using BFS.
            unprocessedVsForRegion := set {(toList remainingCritVertices)_0};
            remainingCritVertices = remainingCritVertices - unprocessedVsForRegion;
            regionTriangles := set {};
            inners := set {};
            while 0 < #unprocessedVsForRegion do (
                currentV := (toList unprocessedVsForRegion)_0;
                unprocessedVsForRegion = unprocessedVsForRegion - (set {currentV});
                inners = inners + set {currentV};
                trianglesWithCurrentV := select(srfc, t -> member(currentV, t));
                regionTriangles = regionTriangles + set trianglesWithCurrentV;
                vertexNeighbors := (set flatten trianglesWithCurrentV) - inners;
                critNeighbors := vertexNeighbors * remainingCritVertices;
                unprocessedVsForRegion = unprocessedVsForRegion + critNeighbors;
                remainingCritVertices = remainingCritVertices - critNeighbors;
            );

            regionTriangles = toList regionTriangles;
            regionEdges := getEdges regionTriangles;
            boundaryEdges := getBoundaryEdges regionTriangles;
            boundary := set getVertices boundaryEdges;
            -- Separating edges: region edges that are neither boundary nor strictly interior.
            innerEdges := select(regionEdges, edge -> not isSubset(edge, boundary));
            separatingEdges := toList ((set regionEdges) - ((set boundaryEdges) + (set innerEdges)));

            eulerChar := eulerCharSrfc regionTriangles;
            regionType := if eulerChar == 1 then "disk" else "mobius";
            critRegStrs = critRegStrs + set {getCritRegionString(regionType, #boundary, #inners)};

            logInfo(concatenate("critical region- inner vertices: ", toString inners,
                ", boundary: ", toString boundaryEdges,
                ", euler characteristic: ", toString eulerChar));
            regionDetailStr := concatenate("inners: ", toString inners,
                ", boundary: ", toString boundaryEdges,
                ", region: ", toString regionTriangles);

            if not isConnected boundaryEdges then (
                print "uh oh! region boundary is not connected";
                logException(srfc, concatenate("critical region boundary is not connected, ", regionDetailStr));
            ) else if not isCycle boundaryEdges then (
                print "uh oh! region boundary is not a cycle";
                logException(srfc, concatenate("critical region boundary is not a cycle, ", regionDetailStr));
            );

            if 1 != eulerChar and 0 != eulerChar then (
                print "uh oh! region is not a disk or a mobius strip!";
                logException(srfc, concatenate("critical region is not a disk or mobius strip, ", regionDetailStr));
            );

            if (4 * #inners < #innerEdges) then (
                print "uh oh! few inner edges";
                logException(srfc, concatenate("critical region has few inner edges, ", regionDetailStr));
            );

            -- Remove vertex splits that belong to this critical region.
            outerSplits := select(remainingSplits, split ->
                not (member(sort {split.splitData.base, (split.splitData.neighbors)_0}, regionEdges)
                    and member(sort {split.splitData.base, (split.splitData.neighbors)_1}, regionEdges)));
            suspectedInnerSplits := toList (set remainingSplits) - (set outerSplits);
            suspectVerts := getVertices separatingEdges;
            for i from 0 to #suspectVerts - 1 do (
                suspectVertex := suspectVerts_i;
                critEdges := select(separatingEdges, edge -> member(suspectVertex, edge));
                foundSplits := select(suspectedInnerSplits, split -> split.splitData.base == suspectVertex);
                foundSplits = select(foundSplits, split ->
                    all(critEdges, edge -> not isSameSideSplit(regionTriangles, suspectVertex, split.splitData.neighbors, edge)));
                outerSplits = outerSplits | foundSplits;
            );

            remainingSplits = outerSplits;
            regionsCount = regionsCount + 1;
        );

        logInfo concatenate("regions count: ", toString regionsCount);

        -- Vertex splits outside critical regions that still have the same final edge
        -- need to be processed in the next iteration.
        badSplits := select(remainingSplits, split -> split.preservesFinalEdge);
        if #badSplits > 0 then (
            print "uh oh! bad split outside critical regions";
            logException(srfc, concatenate("bad splits outside critical regions: ",
                toString (badSplits / (split -> concatenate("base: ", toString split.splitData.base,
                    ", neighbors: ", toString split.splitData.neighbors)))));
        );
        nextCplxes = join(nextCplxes, (select(remainingSplits, split -> split.noVertex4)) / (split -> split.complex));
    );

    new CritRegionsResult from { critRegionStrings => critRegStrs, nextComplexes => nextCplxes }
);

doc ///
  Key
    getCritRegions
  Headline
    identify critical regions of a triangulated surface relative to its final shift edge
  Usage
    getCritRegions(complex, finalEdge)
    getCritRegions(complex, finalEdge, exemptSplits => splits)
  Description
    Example
      getCritRegions({{1,2,3},{1,3,4},{1,4,5},{1,5,2},{2,3,4},{2,4,5}}, {1,2})
///

-- Tests for getCritRegions on large triangulations (8-vertex torus, 8-vertex Klein
-- bottle) have been moved to tests/criticalRegions-tori.m2 and
-- tests/criticalRegions-kb.m2. They exceed the check runner's 400 MB GC heap cap
-- because extShiftLex on their 9-vertex vertex-split complexes computes a 36x36
-- exteriorPower determinant.

TEST ///
  -- Minimal 6-vertex RP² (irredPp_0): 1-skeleton is K6 (10 triangles × 3 / 2 = 15 = C(6,2)),
  -- so finalEdgeOfShift is the last 1-indexed edge of K6 in lex order: {5,6}.
  -- No projective plane triangulation has a critical region.
  irredPp := value get "data/surface triangulations/irredPp.m2";
  tri := irredPp_0;
  assert(finalEdgeOfShift tri == {5,6})
  result := getCritRegions(tri, finalEdgeOfShift tri);
  assert(instance(result, CritRegionsResult))
  assert(instance(result.critRegionStrings, Set))
  assert(instance(result.nextComplexes, List))
  assert(#result.critRegionStrings == 0)
///

-- Tests for getCritRegions on irredKb_25 (10-vertex Klein bottle) have been moved to
-- tests/criticalRegions-kb25-badSplit.m2 and tests/criticalRegions-kb25-exemptSplits.m2.
-- They exceed the check runner's 400 MB GC heap cap because extShiftLex on 11-vertex
-- vertex-split complexes computes a 55x55 exteriorPower determinant.
