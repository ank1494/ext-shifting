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
assert(instance(result.critRegions, Set))
assert(instance(result.nextSplits, List))
assert(#result.critRegions > 0)
-- Each element of critRegions is a HashTable with the expected keys and types.
firstRegion := (toList result.critRegions)_0;
assert(instance(firstRegion, HashTable))
assert(instance(firstRegion#"regionShape", String))
assert(instance(firstRegion#"boundaryVertexCount", ZZ))
assert(instance(firstRegion#"innerVertexCount", ZZ))

print "criticalRegions-kb: PASSED"
