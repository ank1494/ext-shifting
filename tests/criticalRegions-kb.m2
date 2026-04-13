-- Test: getCritRegions on 8-vertex irreducible Klein bottle (irredKb_5)
-- Moved from criticalRegions.m2 TEST block: fails under check runner's 400 MB GC
-- heap cap because extShiftLex on 9-vertex vertex-split complexes triggers a
-- 36x36 exteriorPower determinant. Run this script directly in M2:
--   load "tests/criticalRegions-kb.m2"
load "libs.m2";

-- irredKb_5 is an 8-vertex irreducible Klein bottle triangulation with a
-- degree-4 vertex (vertex 0), so getCritRegions is expected to find at least
-- one critical region.
irredKb := value get "data/surface triangulations/irredKb.m2";
result := getCritRegions(irredKb_5, finalEdgeOfShift irredKb_5);
assert(instance(result, CritRegionsResult))
assert(instance(result.critRegionStrings, Set))
assert(instance(result.nextComplexes, List))
assert(#result.critRegionStrings > 0)

print "criticalRegions-kb: PASSED"
