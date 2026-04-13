-- Test: getCritRegions on irredKb_25 with exemptSplits suppresses bad-split exceptions
-- Moved from criticalRegions.m2 TEST block: fails under check runner's 400 MB GC
-- heap cap because extShiftLex on 11-vertex vertex-split complexes triggers a
-- 55x55 exteriorPower determinant. Run this script directly in M2:
--   load "tests/criticalRegions-kb25-exemptSplits.m2"
load "libs.m2";

-- getCritRegions with exemptSplits filters out the three hidden-trivial splits on
-- irredKb_25 before shift computation, so no "bad split" exception is logged.
irredKb := value get "data/surface triangulations/irredKb.m2";
kbExempts := value get "data/surface triangulations/kbExemptSplits.m2";
tri := irredKb_25;
finalE := finalEdgeOfShift tri;
exempts := if kbExempts#?tri then kbExempts#tri else {};
badSplitLogged := false;
logException = (cplx, msg) -> ( badSplitLogged = true );
result := getCritRegions(tri, finalE, exemptSplits => exempts);
assert(instance(result, CritRegionsResult))
assert(not badSplitLogged)
logException = (cplx, msg) -> null;

print "criticalRegions-kb25-exemptSplits: PASSED"
