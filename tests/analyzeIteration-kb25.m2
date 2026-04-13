-- Test: analyzeIteration with kbExemptSplits does not log bad splits for irredKb_25
-- Moved from analyzeIteration.m2 TEST block: fails under check runner's 400 MB GC
-- heap cap because extShiftLex on 11-vertex vertex-split complexes triggers a
-- 55x55 exteriorPower determinant. Run this script directly in M2:
--   load "tests/analyzeIteration-kb25.m2"
load "libs.m2";

irredKb := value get "data/surface triangulations/irredKb.m2";
kbExempts := value get "data/surface triangulations/kbExemptSplits.m2";
badSplitLogged := false;
logException = (cplx, msg) -> ( badSplitLogged = true );
result := analyzeIteration({irredKb_25}, exemptions => kbExempts);
assert(instance(result, Sequence))
assert(not badSplitLogged)
logException = (cplx, msg) -> null;

print "analyzeIteration-kb25: PASSED"
