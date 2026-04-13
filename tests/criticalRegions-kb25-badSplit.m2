-- Test: getCritRegions on irredKb_25 logs bad-split exceptions without exemptions
-- Moved from criticalRegions.m2 TEST block: fails under check runner's 400 MB GC
-- heap cap because extShiftLex on 11-vertex vertex-split complexes triggers a
-- 55x55 exteriorPower determinant. Run this script directly in M2:
--   load "tests/criticalRegions-kb25-badSplit.m2"
load "libs.m2";

-- irredKb_25 (10-vertex Klein bottle, connected sum of two RP^2 triangulations at
-- vertices 0, 1, 2) produces three false-positive "bad split" exceptions without
-- exemptions. This regression test confirms that broken behavior exists and is
-- preserved as the baseline that kbExemptSplits.m2 is designed to fix.
irredKb := value get "data/surface triangulations/irredKb.m2";
tri := irredKb_25;
finalE := finalEdgeOfShift tri;
badSplitLogged := false;
logException = (cplx, msg) -> ( badSplitLogged = true );
result := getCritRegions(tri, finalE);
assert(instance(result, CritRegionsResult))
assert(badSplitLogged)
logException = (cplx, msg) -> null;

print "criticalRegions-kb25-badSplit: PASSED"
