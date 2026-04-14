-- Runs one iteration of the shifting analysis over a list of triangulations.
-- For each triangulation whose final shift edge does not involve vertex 4 (the "prefix" condition),
-- computes the critical regions and collects vertex-split complexes for the next iteration.
-- Returns a triple: (accumulated critical region HashTable objects, complexes for next iteration, largest complex size seen).
-- The initial critRegions set includes the trivial disk region (the base triangulation K_4).
-- Optional exemptions: HashTable mapping triangulations to lists of {base, neighbors} pairs to exempt.
analyzeIteration = {exemptions => new HashTable from {}} >> opts -> triangulations -> (
    splits := {};
    largest := 0;
    critRegions := set {makeCritRegion("disk",3,0)};

    for trIdx from 0 to #triangulations - 1 do (
        tri := triangulations_trIdx;
        finalE := finalEdgeOfShift tri;
        if not member(4, finalE) then (
            cplxSize := #(getVertices tri);
            largest = max(largest, cplxSize);
            exemptSplitsForTri := if opts.exemptions#?tri then opts.exemptions#tri else {};
            critRegCalculation := getCritRegions(tri, finalE, exemptSplits => exemptSplitsForTri);
            critRegions = critRegions + critRegCalculation.critRegions;
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
    analyzeIteration(triangulations, exemptions => table)
  Description
    Example
      analyzeIteration { {{1,2,3},{1,3,4},{1,4,2},{2,3,4}} }
///

-- Test for analyzeIteration on irredKb_25 (10-vertex Klein bottle) has been moved to
-- tests/analyzeIteration-kb25.m2. It exceeds the check runner's 400 MB GC heap cap
-- because extShiftLex on 11-vertex vertex-split complexes computes a 55x55
-- exteriorPower determinant.
