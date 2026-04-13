-- Test: runQueue with itemCap=1 processes exactly 1 item then returns "paused"
-- Moved from queueOps.m2 TEST block: fails under check runner's 400 MB GC heap cap
-- because extShiftLex on 9-vertex vertex-split complexes triggers a 36x36
-- exteriorPower determinant. Run this script directly in M2:
--   load "tests/queueOps-runQueue-itemCap.m2"
load "libs.m2";

tmpBase := temporaryFileName();
mkdir tmpBase;
pendingDir := concatenate(tmpBase, "/pending");
doneDir := concatenate(tmpBase, "/done");
mkdir pendingDir;
mkdir doneDir;
toriAll := value get "data/surface triangulations/irredTori.m2";
for i from 0 to 2 do
    writeQueueItem(concatenate(pendingDir, "/", queueSeqStr(i+1, 4)), "seed", 0, i+1, toriAll_i);
result := runQueue(pendingDir, doneDir, itemCap => 1);
assert(result === "paused")
doneFiles := select(readDirectory doneDir, f -> f != "." and f != "..");
assert(#doneFiles == 1)

print "queueOps-runQueue-itemCap: PASSED"
