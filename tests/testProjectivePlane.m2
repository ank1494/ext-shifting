-- Test: analyzeIteration on both irreducible projective plane triangulations returns empty splits.
-- The projective plane has exactly 2 irreducible triangulations (6 vertices each).
-- Both should produce zero splits from analyzeIteration, confirming immediate termination.
-- Run from m2/ext-shifting/ in an M2 terminal:
--   load "tests/testProjectivePlane.m2"
load "libs.m2";

irredPp := value get "data/surface triangulations/irredPp.m2";

result0 := analyzeIteration({irredPp_0});
assert(#(result0#1) == 0)

result1 := analyzeIteration({irredPp_1});
assert(#(result1#1) == 0)

print "testProjectivePlane: PASSED"
