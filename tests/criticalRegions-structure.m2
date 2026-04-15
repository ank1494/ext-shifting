-- Absorbs: criticalRegions-kb.m2, criticalRegions-tori.m2
-- Moved from criticalRegions.m2 TEST block: fails under check runner's 400 MB GC
-- heap cap because extShiftLex on 9-vertex vertex-split complexes triggers a
-- 36x36 exteriorPower determinant. Run from m2/ext-shifting/ in M2:
--   load "tests/criticalRegions-structure.m2"
load "libs.m2";

-- irredKb_5: 8-vertex irreducible Klein bottle with a degree-4 vertex
irredKb := value get "data/surface triangulations/irredKb.m2";
result := getCritRegions(irredKb_5, finalEdgeOfShift irredKb_5);
assert(instance(result, CritRegionsResult))
assert(instance(result.critRegions, Set))
assert(instance(result.nextSplits, List))
assert(#result.critRegions > 0)
firstRegion := (toList result.critRegions)_0;
assert(instance(firstRegion, HashTable))
assert(instance(firstRegion#"regionShape", String))
assert(instance(firstRegion#"boundaryVertexCount", ZZ))
assert(instance(firstRegion#"innerVertexCount", ZZ))

print "criticalRegions-structure (kb): PASSED"

-- irredTori_20: 10-vertex irreducible torus — finalEdgeOfShift regression value
irredTori := value get "data/surface triangulations/irredTori.m2";
assert(finalEdgeOfShift (irredTori_20) == {4,10})

-- irredTori_4: 8-vertex torus with a degree-4 vertex
result2 := getCritRegions(irredTori_4, finalEdgeOfShift irredTori_4);
assert(instance(result2, CritRegionsResult))
assert(instance(result2.critRegions, Set))
assert(instance(result2.nextSplits, List))
assert(#result2.critRegions > 0)
firstRegion2 := (toList result2.critRegions)_0;
assert(instance(firstRegion2, HashTable))
assert(instance(firstRegion2#"regionShape", String))
assert(instance(firstRegion2#"boundaryVertexCount", ZZ))
assert(instance(firstRegion2#"innerVertexCount", ZZ))

print "criticalRegions-structure (tori): PASSED"
