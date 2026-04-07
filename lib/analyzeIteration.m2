-- Runs one iteration of the shifting analysis over a list of triangulations.
-- For each triangulation whose final shift edge does not involve vertex 4 (the "prefix" condition),
-- computes the critical regions and collects vertex-split complexes for the next iteration.
-- Returns a triple: (accumulated critical region strings, complexes for next iteration, largest complex size seen).
-- The initial critRegions set includes the trivial "disk,3,0" region (the base triangulation K_4).
-- Optional exemptions: HashTable mapping triangulations to lists of {base, neighbors} pairs to exempt.
analyzeIteration = {exemptions => new HashTable from {}} >> opts -> triangulations -> (
    splits := {};
    largest := 0;
    critRegions := set {getCritRegionString("disk",3,0)};

    for trIdx from 0 to #triangulations - 1 do (
        tri := triangulations_trIdx;
        finalE := finalEdgeOfShift tri;
        if not member(4, finalE) then (
            cplxSize := #(getVertices tri);
            largest = max(largest, cplxSize);
            exemptSplitsForTri := if opts.exemptions#?tri then opts.exemptions#tri else {};
            critRegCalculation := getCritRegions(tri, finalE, exemptSplits => exemptSplitsForTri);
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
    analyzeIteration(triangulations, exemptions => table)
  Description
    Example
      analyzeIteration { {{1,2,3},{1,3,4},{1,4,2},{2,3,4}} }
///

TEST ///
  -- analyzeIteration with the kbExemptSplits HashTable does not log bad splits for irredKb_25.
  irredKb := value get "data/surface triangulations/irredKb.m2";
  kbExempts := value get "data/surface triangulations/kbExemptSplits.m2";
  badSplitLogged := false;
  logException = (cplx, msg) -> ( badSplitLogged = true );
  result := analyzeIteration({irredKb_25}, exemptions => kbExempts);
  assert(instance(result, Sequence))
  assert(not badSplitLogged)
  logException = (cplx, msg) -> null;
///
