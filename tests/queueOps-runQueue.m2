-- Absorbs: queueOps-runQueue-options.m2, queueOps-runQueue-itemCap.m2
-- Moved from queueOps.m2 TEST block: fails under check runner's 400 MB GC heap cap
-- because extShiftLex on 9-vertex vertex-split complexes triggers a 36x36
-- exteriorPower determinant. Run from m2/ext-shifting/ in M2:
--   load "tests/queueOps-runQueue.m2"
load "libs.m2";

toriAll := value get "data/surface triangulations/irredTori.m2";

-- options: all four options accepted without error.
-- Guards against the bug where := bindings named itemCap / maxVertexCount /
-- timeoutSeconds shadow those symbols, causing null => null options and an
-- "unknown key or option" error at the call site.
tmpBase := temporaryFileName();
mkdir tmpBase;
testPendingDir := concatenate(tmpBase, "/pending");
testDoneDir    := concatenate(tmpBase, "/done");
mkdir testPendingDir; mkdir testDoneDir;
writeQueueItem(concatenate(testPendingDir, "/0001"), "seed", 0, 1, toriAll_0);
capItem := 1;
capMaxVerts := null;
capTimeout := null;
result := runQueue(testPendingDir, testDoneDir,
    itemCap => capItem, maxVertexCount => capMaxVerts,
    timeoutSeconds => capTimeout, exemptions => new HashTable from {});
assert(result === "paused")

print "queueOps-runQueue (options): PASSED"

-- itemCap: runQueue with itemCap=1 processes exactly 1 item then returns "paused"
tmpBase2 := temporaryFileName();
mkdir tmpBase2;
pendingDir2 := concatenate(tmpBase2, "/pending");
doneDir2 := concatenate(tmpBase2, "/done");
mkdir pendingDir2;
mkdir doneDir2;
for i from 0 to 2 do
    writeQueueItem(concatenate(pendingDir2, "/", queueSeqStr(i+1, 4)), "seed", 0, i+1, toriAll_i);
result2 := runQueue(pendingDir2, doneDir2, itemCap => 1);
assert(result2 === "paused")
doneFiles2 := select(readDirectory doneDir2, f -> f != "." and f != "..");
assert(#doneFiles2 == 1)

print "queueOps-runQueue (itemCap): PASSED"
