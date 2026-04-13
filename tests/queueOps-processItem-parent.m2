-- Test: splits produced by processQueueItem have parent set to the source item filename
-- Moved from queueOps.m2 TEST block: fails under check runner's 400 MB GC heap cap
-- because extShiftLex on 9-vertex vertex-split complexes (from irredTori_0)
-- triggers a 36x36 exteriorPower determinant. Run this script directly in M2:
--   load "tests/queueOps-processItem-parent.m2"
load "libs.m2";

tmpBase := temporaryFileName();
mkdir tmpBase;
pendingDir := concatenate(tmpBase, "/pending");
doneDir := concatenate(tmpBase, "/done");
mkdir pendingDir;
mkdir doneDir;
toriAll := value get "data/surface triangulations/irredTori.m2";
tri := toriAll_0;
writeQueueItem(concatenate(pendingDir, "/0001"), "seed", 0, 1, tri);
processQueueItem(pendingDir, doneDir);
splitFiles := sort select(readDirectory pendingDir, f -> f != "." and f != "..");
for fName in splitFiles do (
    splitItem := readQueueItem concatenate(pendingDir, "/", fName);
    assert(splitItem#"parent" === "0001");
    assert(splitItem#"depth" === 1);
);

print "queueOps-processItem-parent: PASSED"
