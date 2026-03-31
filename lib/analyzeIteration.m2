-- Runs one iteration of the shifting analysis over a list of triangulations.
-- For each triangulation whose final shift edge does not involve vertex 4 (the "prefix" condition),
-- computes the critical regions and collects vertex-split complexes for the next iteration.
-- Returns a triple: (accumulated critical region strings, complexes for next iteration, largest complex size seen).
-- The initial critRegions set includes the trivial "disk,3,0" region (the base triangulation K_4).
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
            critRegions = critRegions + critRegCalculation.critRegionStrings;
            if 0 < #critRegCalculation.nextComplexes then (
                largest = max(largest, 1 + cplxSize);
                splits = splits | critRegCalculation.nextComplexes;
            );
        );
        collectGarbage();
    );

    (critRegions, splits, largest)
);

doc ///
  Key
    analyzeIteration
  Headline
    run one iteration of the shifting analysis over a list of triangulations
  Usage
    analyzeIteration triangulations
  Description
    Example
      analyzeIteration { {{1,2,3},{1,3,4},{1,4,2},{2,3,4}} }
///
