-- Absorbs: criticalRegions-kb25-badSplit.m2, criticalRegions-kb25-exemptSplits.m2
-- irredKb_25 (10-vertex Klein bottle) triggers a 55x55 exteriorPower determinant.
-- Moved from criticalRegions.m2 TEST block: fails under check runner's 400 MB GC heap cap.
-- Run from m2/ext-shifting/ in M2:
--   load "tests/criticalRegions-kb25.m2"
load "libs.m2";

irredKb := value get "data/surface triangulations/irredKb.m2";
tri := irredKb_25;
finalE := finalEdgeOfShift tri;

-- badSplit: without exemptions, irredKb_25 produces three false-positive "bad split"
-- exceptions. This confirms the baseline broken behavior that kbExemptSplits.m2 fixes.
badSplitLogged := false;
logException = (cplx, msg) -> ( badSplitLogged = true );
result := getCritRegions(tri, finalE);
assert(instance(result, CritRegionsResult))
assert(badSplitLogged)
logException = (cplx, msg) -> null;

print "criticalRegions-kb25 (badSplit): PASSED"

-- exemptSplits: with the exemption list, no bad-split exception is logged
kbExempts := value get "data/surface triangulations/kbExemptSplits.m2";
exempts := if kbExempts#?tri then kbExempts#tri else {};
badSplitLogged2 := false;
logException = (cplx, msg) -> ( badSplitLogged2 = true );
result2 := getCritRegions(tri, finalE, exemptSplits => exempts);
assert(instance(result2, CritRegionsResult))
assert(not badSplitLogged2)
logException = (cplx, msg) -> null;

print "criticalRegions-kb25 (exemptSplits): PASSED"
