-- lib/queueOps.m2
-- Queue file I/O for the persistent analysis queue.
-- The queue lives in pending/ and done/ subdirectories under a run output directory.
-- Each file encodes one triangulation plus provenance metadata as an M2 HashTable.

-- Returns a zero-padded decimal string of integer n to the given width.
-- Example: queueSeqStr(3, 4) => "0003"
queueSeqStr = (n, width) -> (
    s := toString n;
    concatenate(apply(max(0, width - #s), j -> "0"), s)
);

-- Writes a queue item file at path.
-- File content is a readable M2 HashTable with keys:
--   "parent"        => parent filename (or "seed" for items from the initial input)
--   "depth"         => integer depth in the split tree (0 for seeds)
--   "seq"           => integer sequence number
--   "triangulation" => list of faces (list of vertex lists)
writeQueueItem = (path, parent, depth, seq, tri) -> (
    f := path << "new HashTable from {" << endl;
    f << "  \"parent\" => " << toExternalString parent << "," << endl;
    f << "  \"depth\" => " << toExternalString depth << "," << endl;
    f << "  \"seq\" => " << toExternalString seq << "," << endl;
    f << "  \"triangulation\" => " << toExternalString tri << endl;
    f << "}" << close;
);

-- Reads a queue item file and returns the encoded HashTable.
readQueueItem = path -> value get path;

-- Initializes the queue directory structure under outputDir.
-- First run: creates pending/ and done/, seeds pending/ with one file per
--   triangulation from inputFile (zero-padded sequence filenames, depth 0, parent "seed").
-- Resume: no-op if pending/ already exists.
initQueue = (outputDir, inputFile) -> (
    pendingDir := concatenate(outputDir, "/pending");
    doneDir := concatenate(outputDir, "/done");
    if isDirectory pendingDir then return;
    mkdir pendingDir;
    mkdir doneDir;
    triangulations := value get inputFile;
    for i from 0 to #triangulations - 1 do (
        fname := concatenate(pendingDir, "/", queueSeqStr(i + 1, 4));
        writeQueueItem(fname, "seed", 0, i + 1, triangulations_i);
    );
);

TEST ///
  -- initQueue creates pending/ and done/ subdirectories on first run
  tmpBase := temporaryFileName();
  mkdir tmpBase;
  initQueue(tmpBase, "data/surface triangulations/irredTori.m2");
  assert(isDirectory concatenate(tmpBase, "/pending"))
  assert(isDirectory concatenate(tmpBase, "/done"))
///

TEST ///
  -- initQueue seeds pending/ with one file per triangulation from input
  tmpBase := temporaryFileName();
  mkdir tmpBase;
  inputFile := "data/surface triangulations/irredTori.m2";
  triangulations := value get inputFile;
  initQueue(tmpBase, inputFile);
  pendingDir := concatenate(tmpBase, "/pending");
  pendingFiles := select(readDirectory pendingDir, f -> f != "." and f != "..");
  assert(#pendingFiles == #triangulations)
///

TEST ///
  -- initQueue is a no-op on resume: pending/ already exists, no re-seeding
  tmpBase := temporaryFileName();
  mkdir tmpBase;
  pendingDir := concatenate(tmpBase, "/pending");
  mkdir pendingDir;
  concatenate(pendingDir, "/0001") << "dummy" << close;
  initQueue(tmpBase, "data/surface triangulations/irredTori.m2");
  pendingFiles := select(readDirectory pendingDir, f -> f != "." and f != "..");
  assert(#pendingFiles == 1)
///

TEST ///
  -- each seeded file is a readable HashTable with parent, depth, seq, triangulation
  tmpBase := temporaryFileName();
  mkdir tmpBase;
  inputFile := "data/surface triangulations/irredTori.m2";
  initQueue(tmpBase, inputFile);
  pendingDir := concatenate(tmpBase, "/pending");
  files := sort select(readDirectory pendingDir, f -> f != "." and f != "..");
  item := readQueueItem concatenate(pendingDir, "/", files_0);
  assert(instance(item, HashTable))
  assert(item#?"parent")
  assert(item#?"depth")
  assert(item#?"seq")
  assert(item#?"triangulation")
  assert(item#"parent" === "seed")
  assert(item#"depth" === 0)
  assert(item#"seq" === 1)
///
