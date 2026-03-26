-- Returns a canonical string identifier for a critical region.
-- regionType: "disk" (eulerChar=1) or "mobius" (eulerChar=0)
-- boundarySize: number of boundary vertices
-- innerSize: number of inner vertices
getCritRegionString = (regionType, boundarySize, innerSize) ->
    concatenate(regionType, ",", toString boundarySize, ",", toString innerSize);

-- Helper: returns true if both neighbors are on the same side of critEdge
-- relative to bdyVertex in the given surface with boundary.
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

-- Analyzes the critical regions of a complex with respect to a final shift edge.
-- Returns {set of critical region strings, list of vertex-split complexes for next iteration}.
getCritRegions = (complex, finalEdge) -> (
    critRegionStrings := set {};
    splitsToReturn := {};

    -- Compute non-trivial vertex splits and annotate each with shift data.
    splits := nonTrivSplits complex;
    splitsWithShiftData := {};
    for i from 0 to #splits - 1 do (
        shift1 := extShiftLex getEdges splits_i_0;
        shift2 := extShiftLex getEdges splits_i_0;
        data := {splits_i_1, (finalEdge == shift1_-1) and (finalEdge == shift2_-1), splits_i_0};
        splitsWithShiftData = append(splitsWithShiftData, data);
    );

    -- Identify critical vertices: those where every non-trivial split preserves the final edge.
    remainingSplits := set splitsWithShiftData;
    vertices := getVertices complex;
    critVertices := set {};
    for i from 0 to #vertices - 1 do (
        v := vertices_i;
        splitsFromV := select(splitsWithShiftData, d -> d_0_SPLITBASE == v);
        if all(splitsFromV, s -> s_1) then (
            critVertices = critVertices + set {v};
            remainingSplits = remainingSplits - (set splitsFromV);
        );
    );
    remainingSplits = toList remainingSplits;

    if #critVertices == #vertices then (
        print "uh oh - all vertices are critical!";
        logException(complex, "all vertices are critical")
    ) else (
        remainingCritVertices := critVertices;
        regionsCount := 0;
        while 0 < #remainingCritVertices do (
            -- Grow a connected region of critical vertices.
            unprocessedVsForRegion := set {(toList remainingCritVertices)_0};
            remainingCritVertices = remainingCritVertices - unprocessedVsForRegion;
            regionTriangles := set {};
            inners := set {};
            while 0 < #unprocessedVsForRegion do (
                currentV := (toList unprocessedVsForRegion)_0;
                unprocessedVsForRegion = unprocessedVsForRegion - (set {currentV});
                inners = inners + set {currentV};
                trianglesWithCurrentV := select(complex, t -> member(currentV, t));
                regionTriangles = regionTriangles + set trianglesWithCurrentV;
                neighbors := (set flatten trianglesWithCurrentV) - inners;
                critNeighbors := neighbors * remainingCritVertices;
                unprocessedVsForRegion = unprocessedVsForRegion + critNeighbors;
                remainingCritVertices = remainingCritVertices - critNeighbors;
            );

            regionTriangles = toList regionTriangles;
            regionEdges := getEdges regionTriangles;
            boundaryEdges := getBoundaryEdges regionTriangles;
            boundary := set getVertices boundaryEdges;
            innerEdges := select(regionEdges, e -> not isSubset(e, boundary));
            separatingEdges := toList ((set regionEdges) - ((set boundaryEdges) + (set innerEdges)));

            eulerChar := eulerCharSrfc regionTriangles;
            regionType := if eulerChar == 1 then "disk" else "mobius";
            critRegionStrings = critRegionStrings + set {getCritRegionString(regionType, #boundary, #inners)};

            logInfo(concatenate("critical region- inner vertices: ", toString inners,
                ", boundary: ", toString boundaryEdges,
                ", euler characteristic: ", toString eulerChar));
            regionDetailStr := concatenate("inners: ", toString inners,
                ", boundary: ", toString boundaryEdges,
                ", region: ", toString regionTriangles);

            if not isConnected boundaryEdges then (
                print "uh oh! region boundary is not connected";
                logException(complex, concatenate("critical region boundary is not connected, ", regionDetailStr));
            ) else if not isCycle boundaryEdges then (
                print "uh oh! region boundary is not a cycle";
                logException(complex, concatenate("critical region boundary is not a cycle, ", regionDetailStr));
            );

            if 1 != eulerChar and 0 != eulerChar then (
                print "uh oh! region is not a disk or a mobius strip!";
                logException(complex, concatenate("critical region is not a disk or mobius strip, ", regionDetailStr));
            );

            if (4 * #inners < #innerEdges) then (
                print "uh oh! few inner edges";
                logException(complex, concatenate("critical region has few inner edges, ", regionDetailStr));
            );

            -- Remove splits that belong to this critical region.
            outerSplits := select(remainingSplits, s ->
                not (member(sort {s_0_SPLITBASE, s_0_SPLITNEIGHBORS_0}, regionEdges)
                    and member(sort {s_0_SPLITBASE, s_0_SPLITNEIGHBORS_1}, regionEdges)));
            suspectedInnerSplits := toList (set remainingSplits) - (set outerSplits);
            suspectVerts := getVertices separatingEdges;
            for i from 0 to #suspectVerts - 1 do (
                sv := suspectVerts_i;
                critEdges := select(separatingEdges, e -> member(sv, e));
                foundSplits := select(suspectedInnerSplits, s -> s_0_SPLITBASE == sv);
                foundSplits = select(foundSplits, s ->
                    all(critEdges, e -> not isSameSideSplit(regionTriangles, sv, s_0_SPLITNEIGHBORS, e)));
                outerSplits = outerSplits | foundSplits;
            );

            remainingSplits = outerSplits;
            regionsCount = regionsCount + 1;
        );

        logInfo concatenate("regions count: ", toString regionsCount);

        -- Splits outside critical regions that still have the same final edge
        -- need to be processed in the next iteration.
        badSplits := select(remainingSplits, s -> s_1);
        if #badSplits > 0 then (
            print "uh oh! bad split outside critical regions";
            logException(complex, concatenate("bad splits outside critical regions: ",
                toString (badSplits / (s -> concatenate("base: ", toString s_0_SPLITBASE,
                    ", neighbors: ", toString s_0_SPLITNEIGHBORS)))));
            splitsToReturn = join(splitsToReturn, badSplits / (s -> s_2));
        );
    );

    {critRegionStrings, splitsToReturn}
);
