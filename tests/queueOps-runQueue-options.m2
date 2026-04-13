-- Test: runQueue accepts all four options without error when cap variables are
-- given distinct names that do not shadow the option symbols.
-- Guards against the bug where := bindings named itemCap / maxVertexCount /
-- timeoutSeconds shadow those symbols, causing null => null options and an
-- "unknown key or option" error at the call site.
-- Moved from queueOps.m2 TEST block: fails under check runner's 400 MB GC heap cap
-- because extShiftLex on 9-vertex vertex-split complexes triggers a 36x36
-- exteriorPower determinant. Run this script directly in M2:
--   load "tests/queueOps-runQueue-options.m2"
load "libs.m2";

tmpBase := temporaryFileName();
mkdir tmpBase;
testPendingDir := concatenate(tmpBase, "/pending");
testDoneDir    := concatenate(tmpBase, "/done");
mkdir testPendingDir; mkdir testDoneDir;
toriAll := value get "data/surface triangulations/irredTori.m2";
writeQueueItem(concatenate(testPendingDir, "/0001"), "seed", 0, 1, toriAll_0);
capItem := 1;
capMaxVerts := null;
capTimeout := null;
result := runQueue(testPendingDir, testDoneDir,
    itemCap => capItem, maxVertexCount => capMaxVerts,
    timeoutSeconds => capTimeout, exemptions => new HashTable from {});
assert(result === "paused")

print "queueOps-runQueue-options: PASSED"
