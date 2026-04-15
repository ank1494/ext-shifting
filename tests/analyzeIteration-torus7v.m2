-- Test: analyzeIteration on irredTori_0 (7-vertex minimal torus) finds no critical regions.
-- The 7-vertex torus is the minimal irreducible torus triangulation; its exterior shift
-- does not produce any non-trivial critical regions.
-- After removing the trivial-disk seed from analyzeIteration, the result must be empty.
-- Run from m2/ext-shifting/ in an M2 terminal:
--   load "tests/analyzeIteration-torus7v.m2"
load "libs.m2";

irredTori := value get "data/surface triangulations/irredTori.m2";
-- irredTori_0 is the 7-vertex minimal irreducible torus triangulation.
result := analyzeIteration({irredTori_0});
assert(instance(result, Sequence))
critRegions := result#0;
assert(instance(critRegions, Set))
assert(#critRegions == 0)

print "analyzeIteration-torus7v: PASSED"
