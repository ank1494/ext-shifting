load "libs.m2";

T := {{1,3,4},{1,2,4},{2,4,5},{2,3,5},{3,5,6},{3,4,6},{0,4,5},{0,1,5},{1,2,6},{1,5,6},{0,2,6},{0,4,6},{0,1,7},{1,3,7},{2,3,7},{0,2,7}};

finalE := finalEdgeOfShift T;
print("finalEdge: " | toString finalE);

-- Build splitsWithShiftData (same as getCritRegions does internally)
splits := nonTrivSplits T;
splitsWithShiftData := {};
for i from 0 to #splits - 1 do (
    shift1 := extShiftLex getEdges splits_i_0;
    shift2 := extShiftLex getEdges splits_i_0;
    preserves := (finalE == shift1_-1) and (finalE == shift2_-1);
    data := {splits_i_1, preserves, splits_i_0};
    splitsWithShiftData = append(splitsWithShiftData, data);
);

preservingCount := #select(splitsWithShiftData, s -> s_1);
print("splits that preserve finalEdge: " | toString preservingCount | " of " | toString(#splits));

-- Identify critical vertices
vertices := getVertices T;
critVertices := set {};
remainingSplits := set splitsWithShiftData;
for i from 0 to #vertices - 1 do (
    v := vertices_i;
    splitsFromV := select(splitsWithShiftData, d -> d_0_SPLITBASE == v);
    if all(splitsFromV, s -> s_1) then (
        critVertices = critVertices + set {v};
        remainingSplits = remainingSplits - (set splitsFromV);
    );
);
remainingSplits = toList remainingSplits;
print("critVertices: " | toString toList critVertices);
print("remainingSplits count after removing critical vertices: " | toString(#remainingSplits));
print("of those, how many preserve finalEdge: " | toString(#select(remainingSplits, s -> s_1)));

-- Walk through each critical region, same logic as getCritRegions
remainingCritVertices := critVertices;
regionsCount := 0;
while 0 < #remainingCritVertices do (
    regionsCount = regionsCount + 1;
    print("--- processing region " | toString regionsCount | " ---");

    unprocessedVsForRegion := set {(toList remainingCritVertices)_0};
    remainingCritVertices = remainingCritVertices - unprocessedVsForRegion;
    regionTriangles := set {};
    inners := set {};
    while 0 < #unprocessedVsForRegion do (
        currentV := (toList unprocessedVsForRegion)_0;
        unprocessedVsForRegion = unprocessedVsForRegion - (set {currentV});
        inners = inners + set {currentV};
        trianglesWithCurrentV := select(T, t -> member(currentV, t));
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

    print("  inners: " | toString toList inners);
    print("  boundary vertices: " | toString toList boundary);
    print("  separatingEdges: " | toString separatingEdges);
    print("  eulerChar: " | toString eulerChar | " => " | regionType);
    print("  regionEdges count: " | toString(#regionEdges));

    -- Filter: splits where BOTH neighbor-edges are inside regionEdges are "suspected inner"
    outerSplits := select(remainingSplits, s ->
        not (member(sort {s_0_SPLITBASE, s_0_SPLITNEIGHBORS_0}, regionEdges)
            and member(sort {s_0_SPLITBASE, s_0_SPLITNEIGHBORS_1}, regionEdges)));
    suspectedInnerSplits := toList (set remainingSplits) - (set outerSplits);
    print("  suspectedInnerSplits (removed by edge-membership filter): " | toString(#suspectedInnerSplits));
    for s in suspectedInnerSplits do (
        print("    base=" | toString(s_0_SPLITBASE)
            | " neighbors=" | toString(s_0_SPLITNEIGHBORS)
            | " preserves=" | toString(s_1));
    );

    -- isSameSideSplit check: add back splits that cross a separating edge
    suspectVerts := getVertices separatingEdges;
    addedBack := {};
    for i from 0 to #suspectVerts - 1 do (
        sv := suspectVerts_i;
        critEdges := select(separatingEdges, e -> member(sv, e));
        foundSplits := select(suspectedInnerSplits, s -> s_0_SPLITBASE == sv);
        foundSplits = select(foundSplits, s ->
            all(critEdges, e -> not isSameSideSplit(regionTriangles, sv, s_0_SPLITNEIGHBORS, e)));
        addedBack = addedBack | foundSplits;
        outerSplits = outerSplits | foundSplits;
    );
    print("  splits added back via isSameSideSplit: " | toString(#addedBack));

    remainingSplits = outerSplits;
    print("  remainingSplits after this region: " | toString(#remainingSplits)
        | " (preserving finalEdge: " | toString(#select(remainingSplits, s -> s_1)) | ")");
);

print("=== FINAL RESULTS ===");
print("remainingSplits: " | toString(#remainingSplits));
badSplits := select(remainingSplits, s -> s_1);
print("badSplits (outside crit regions, preserve finalEdge): " | toString(#badSplits));
for s in badSplits do (
    print("  base=" | toString(s_0_SPLITBASE)
        | " neighbors=" | toString(s_0_SPLITNEIGHBORS));
);
