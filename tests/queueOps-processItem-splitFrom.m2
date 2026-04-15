-- Test: split files written by processQueueItem carry a correct splitFrom field;
--       done file splitFrom round-trips what was in the pending file.
-- Uses irredTori_0 (7-vertex minimal torus) which produces splits.
-- Moved to tests/ because extShiftLex on 9-vertex vertex-split complexes
-- triggers a 36x36 exteriorPower determinant.
-- Run from m2/ext-shifting/ in an M2 terminal:
--   load "tests/queueOps-processItem-splitFrom.m2"
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

splitFiles := sort select(readDirectory pendingDir, f -> f != "." and f != "..");
assert(#splitFiles > 0)

-- Every split file must have a splitFrom field with "vertex" and "neighbors" keys.
for fName in splitFiles do (
    splitItem := readQueueItem concatenate(pendingDir, "/", fName);
    assert(splitItem#?"splitFrom");
    sf := splitItem#"splitFrom";
    assert(sf#?"vertex");
    assert(sf#?"neighbors");
    assert(instance(sf#"vertex", ZZ));
    assert(instance(sf#"neighbors", List));
    assert(#(sf#"neighbors") == 2);
    -- triangulation must be a proper list of faces, not a {complex, splitData} pair
    assert(instance(splitItem#"triangulation", List));
    assert(instance((splitItem#"triangulation")_0, List));
);

-- Done file must NOT have a splitFrom field (it was a seed).
doneFiles := select(readDirectory doneDir, f -> f != "." and f != "..");
assert(#doneFiles == 1)
doneItem := readQueueItem concatenate(doneDir, "/", doneFiles_0);
assert(not doneItem#?"splitFrom")

-- Round-trip: process a split file and verify the done file's splitFrom matches.
firstSplitName := splitFiles_0;
firstSplitPath := concatenate(pendingDir, "/", firstSplitName);
firstSplitItem := readQueueItem firstSplitPath;
pendingSplitFrom := firstSplitItem#"splitFrom";
processQueueItem(pendingDir, doneDir);
-- The first split file is now in done/.
roundTripDonePath := concatenate(doneDir, "/", firstSplitName);
assert(fileExists roundTripDonePath)
roundTripDone := readQueueItem roundTripDonePath;
assert(roundTripDone#?"splitFrom")
doneSf := roundTripDone#"splitFrom";
assert(doneSf#"vertex" === pendingSplitFrom#"vertex")
assert(doneSf#"neighbors" === pendingSplitFrom#"neighbors")

print "queueOps-processItem-splitFrom: PASSED"
