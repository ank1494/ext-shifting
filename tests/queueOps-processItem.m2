-- Absorbs: queueOps-processItem-moves.m2, queueOps-processItem-parent.m2,
--          queueOps-processItem-splitFrom.m2, queueOps-processItem-critRegions.m2
-- Moved from queueOps.m2 TEST block: fails under check runner's 400 MB GC heap cap
-- because extShiftLex on 9-vertex vertex-split complexes (from irredTori_0)
-- triggers a 36x36 exteriorPower determinant. Run from m2/ext-shifting/ in M2:
--   load "tests/queueOps-processItem.m2"
load "libs.m2";

-- === Part 1: irredTori_0 (7-vertex minimal torus) ===
-- Tests: moves, parent, splitFrom
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

-- moves: item moved from pending/ to done/
doneFiles := select(readDirectory doneDir, f -> f != "." and f != "..");
assert(#doneFiles == 1)
pendingFilenames := select(readDirectory pendingDir, f -> f != "." and f != "..");
assert(not member("0001", pendingFilenames))

-- parent: split files carry parent="0001" and depth=1
splitFiles := sort select(readDirectory pendingDir, f -> f != "." and f != "..");
for fName in splitFiles do (
    splitItem := readQueueItem concatenate(pendingDir, "/", fName);
    assert(splitItem#"parent" === "0001");
    assert(splitItem#"depth" === 1);
);

-- splitFrom: every split file has a splitFrom field with the expected shape
assert(#splitFiles > 0)
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

-- splitFrom: seed done file must NOT have a splitFrom field
doneItem := readQueueItem concatenate(doneDir, "/", doneFiles_0);
assert(not doneItem#?"splitFrom")

-- splitFrom round-trip: process a split file and verify its done file carries splitFrom
firstSplitName := splitFiles_0;
firstSplitPath := concatenate(pendingDir, "/", firstSplitName);
firstSplitItem := readQueueItem firstSplitPath;
pendingSplitFrom := firstSplitItem#"splitFrom";
processQueueItem(pendingDir, doneDir);
roundTripDonePath := concatenate(doneDir, "/", firstSplitName);
assert(fileExists roundTripDonePath)
roundTripDone := readQueueItem roundTripDonePath;
assert(roundTripDone#?"splitFrom")
doneSf := roundTripDone#"splitFrom";
assert(doneSf#"vertex" === pendingSplitFrom#"vertex")
assert(doneSf#"neighbors" === pendingSplitFrom#"neighbors")

print "queueOps-processItem (moves, parent, splitFrom): PASSED"

-- === Part 2: irredTori_4 (8-vertex torus with a degree-4 vertex) ===
-- Test: critRegions — done file carries a critRegions field with the correct structure
tmpBase2 := temporaryFileName();
mkdir tmpBase2;
pendingDir2 := concatenate(tmpBase2, "/pending");
doneDir2 := concatenate(tmpBase2, "/done");
mkdir pendingDir2;
mkdir doneDir2;
tri4 := toriAll_4;
writeQueueItem(concatenate(pendingDir2, "/0001"), "seed", 0, 1, tri4);
processQueueItem(pendingDir2, doneDir2);

doneFiles2 := select(readDirectory doneDir2, f -> f != "." and f != "..");
assert(#doneFiles2 == 1)
doneItem2 := readQueueItem concatenate(doneDir2, "/", doneFiles2_0);
assert(instance(doneItem2, HashTable))
assert(doneItem2#?"critRegions")
assert(instance(doneItem2#"critRegions", List))
assert(#(doneItem2#"critRegions") > 0)
firstRegion2 := (doneItem2#"critRegions")_0;
assert(instance(firstRegion2, HashTable))
assert(instance(firstRegion2#"regionShape", String))
assert(instance(firstRegion2#"boundaryVertexCount", ZZ))
assert(instance(firstRegion2#"innerVertexCount", ZZ))

print "queueOps-processItem (critRegions): PASSED"
