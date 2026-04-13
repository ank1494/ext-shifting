-- Test: processQueueItem moves the processed item from pending/ to done/
-- Moved from queueOps.m2 TEST block: fails under check runner's 400 MB GC heap cap
-- because extShiftLex on 9-vertex vertex-split complexes (from irredTori_0)
-- triggers a 36x36 exteriorPower determinant. Run this script directly in M2:
--   load "tests/queueOps-processItem-moves.m2"
load "libs.m2";

tmpBase := temporaryFileName();
mkdir tmpBase;
pendingDir := concatenate(tmpBase, "/pending");
doneDir := concatenate(tmpBase, "/done");
mkdir pendingDir;
mkdir doneDir;
tri := (value get "data/surface triangulations/irredTori.m2")_0;
writeQueueItem(concatenate(pendingDir, "/0001"), "seed", 0, 1, tri);
processQueueItem(pendingDir, doneDir);
doneFiles := select(readDirectory doneDir, f -> f != "." and f != "..");
assert(#doneFiles == 1)
pendingFilenames := select(readDirectory pendingDir, f -> f != "." and f != "..");
assert(not member("0001", pendingFilenames))

print "queueOps-processItem-moves: PASSED"
