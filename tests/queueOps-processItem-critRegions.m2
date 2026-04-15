-- Test: done file written by processQueueItem contains a critRegions field
-- Uses irredTori_4 (8-vertex torus with a degree-4 vertex) which is known to
-- produce at least one critical region. Moved to tests/ because extShiftLex on
-- 9-vertex vertex-split complexes triggers a 36x36 exteriorPower determinant.
-- Run this script directly in M2:
--   load "tests/queueOps-processItem-critRegions.m2"
load "libs.m2";

tmpBase := temporaryFileName();
mkdir tmpBase;
pendingDir := concatenate(tmpBase, "/pending");
doneDir := concatenate(tmpBase, "/done");
mkdir pendingDir;
mkdir doneDir;
tri := (value get "data/surface triangulations/irredTori.m2")_4;
writeQueueItem(concatenate(pendingDir, "/0001"), "seed", 0, 1, tri);
processQueueItem(pendingDir, doneDir);

-- Done file must exist and be a readable HashTable.
doneFiles := select(readDirectory doneDir, f -> f != "." and f != "..");
assert(#doneFiles == 1)
doneItem := readQueueItem concatenate(doneDir, "/", doneFiles_0);
assert(instance(doneItem, HashTable))

-- Done file must carry the critRegions field as a list of HashTable objects.
assert(doneItem#?"critRegions")
assert(instance(doneItem#"critRegions", List))
assert(#(doneItem#"critRegions") > 0)
firstRegion := (doneItem#"critRegions")_0;
assert(instance(firstRegion, HashTable))
assert(instance(firstRegion#"regionShape", String))
assert(instance(firstRegion#"boundaryVertexCount", ZZ))
assert(instance(firstRegion#"innerVertexCount", ZZ))

print "queueOps-processItem-critRegions: PASSED"
