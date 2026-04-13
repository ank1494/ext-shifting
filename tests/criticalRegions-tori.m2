-- Test: getCritRegions on 8-vertex irreducible torus (irredTori_4)
-- Moved from criticalRegions.m2 TEST block: fails under check runner's 400 MB GC
-- heap cap because extShiftLex on 9-vertex vertex-split complexes triggers a
-- 36x36 exteriorPower determinant. Run this script directly in M2:
--   load "tests/criticalRegions-tori.m2"
load "libs.m2";

irredTori := value get "data/surface triangulations/irredTori.m2";
-- 10-vertex irreducible torus (irredTori_20): the exterior shift of its edges
-- is non-trivial (1-skeleton is not complete), so the final edge is a meaningful
-- regression value: {4,10} (1-indexed).
assert(finalEdgeOfShift (irredTori_20) == {4,10})
-- irredTori_4 is an 8-vertex torus with a degree-4 vertex (vertex 0), so
-- getCritRegions is expected to find at least one critical region.
result := getCritRegions(irredTori_4, finalEdgeOfShift irredTori_4);
assert(instance(result, CritRegionsResult))
assert(instance(result.critRegionStrings, Set))
assert(instance(result.nextComplexes, List))
assert(#result.critRegionStrings > 0)

print "criticalRegions-tori: PASSED"
