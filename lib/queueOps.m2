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

-- Returns the next available sequence number across pending/ and done/.
-- Scans both directories and returns max existing seq number + 1.
nextQueueSeq = (pendingDir, doneDir) -> (
    pendingFiles := select(readDirectory pendingDir, f -> f != "." and f != "..");
    doneFiles := select(readDirectory doneDir, f -> f != "." and f != "..");
    allFiles := join(pendingFiles, doneFiles);
    if #allFiles == 0 then 1
    else max(apply(allFiles, f -> value f)) + 1
);

-- Emits a structured item_started event to stdout.
emitItemStarted = (itemName, depth, parent) -> (
    stdio << "EVENT:{\"type\":\"item_started\",\"item\":\"" | itemName |
        "\",\"depth\":" | toString depth |
        ",\"parent\":\"" | parent | "\"}" << endl;
);

-- Emits a structured item_done event to stdout.
emitItemDone = (itemName, splitCount) -> (
    stdio << "EVENT:{\"type\":\"item_done\",\"item\":\"" | itemName |
        "\",\"splits\":" | toString splitCount | "}" << endl;
);

-- Processes the next item from pending/:
--   reads the front item, runs analyzeIteration, enqueues resulting splits
--   with provenance metadata, then moves the item to done/.
-- Item is only moved to done/ after all split writes succeed.
-- Optional: exemptions => HashTable of exempt splits (passed to analyzeIteration).
-- Returns the number of splits produced.
processQueueItem = {exemptions => new HashTable from {}} >> opts -> (pendingDir, doneDir) -> (
    pendingFiles := sort select(readDirectory pendingDir, f -> f != "." and f != "..");
    if #pendingFiles == 0 then return 0;
    itemName := pendingFiles_0;
    itemPath := concatenate(pendingDir, "/", itemName);
    item := readQueueItem itemPath;
    tri := item#"triangulation";
    depth := item#"depth";
    parent := item#"parent";

    emitItemStarted(itemName, depth, parent);

    (critRegions, splits, largest) := analyzeIteration({tri}, exemptions => opts.exemptions);

    nextSeq := nextQueueSeq(pendingDir, doneDir);
    for i from 0 to #splits - 1 do (
        seq := nextSeq + i;
        fname := concatenate(pendingDir, "/", queueSeqStr(seq, 4));
        writeQueueItem(fname, itemName, depth + 1, seq, splits_i);
    );

    donePath := concatenate(doneDir, "/", itemName);
    copyFile(itemPath, donePath);
    removeFile itemPath;

    emitItemDone(itemName, #splits);
    #splits
);

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

TEST ///
  -- processQueueItem moves the processed item from pending/ to done/
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
///

TEST ///
  -- splits produced by processQueueItem have parent set to the source item filename
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
///
