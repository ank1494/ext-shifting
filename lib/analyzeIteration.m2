-- analyzeIteration: pure per-iteration mathematical logic, no file I/O.
-- Takes a list of triangulations; returns (foundCritRegions, splitsForNextCalc, largestNonPrefixVertices).
analyzeIteration = triangulations -> (
    splits := {};
    largest := 0;
    critRegions := set {getCritRegionString("disk",3,0)};

    for trIdx from 0 to #triangulations - 1 do (
        finalE := finalEdgeOfShift triangulations_trIdx;
        if not member(4, finalE) then (
            cplxSize := #(getVertices triangulations_trIdx);
            largest = max(largest, cplxSize);
            critRegCalculation := getCritRegions(triangulations_trIdx, finalE);
            critRegions = critRegions + critRegCalculation_0;
            if 0 < #critRegCalculation_1 then (
                largest = max(largest, 1 + cplxSize);
                splits = splits | critRegCalculation_1;
            );
        );
        collectGarbage();
    );

    (critRegions, splits, largest)
);
