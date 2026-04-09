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

-- Emits a run_paused event to stderr (unbuffered; cap hit before queue emptied).
emitRunPaused = () -> (
    stderr << "EVENT:{\"type\":\"run_paused\"}" << endl;
);

-- Emits a run_complete event to stderr (unbuffered; queue emptied naturally).
emitRunComplete = () -> (
    stderr << "EVENT:{\"type\":\"run_complete\"}" << endl;
);

-- Runs the queue loop until pending/ is empty or a batch cap is hit.
-- Optional caps (all nullable — null means uncapped):
--   itemCap        => ZZ    : stop after processing this many items
--   maxVertexCount => ZZ    : stop before processing an item whose triangulation
--                             has more vertices than this threshold
--   timeoutSeconds => ZZ    : wall-clock timeout in seconds (soft — never mid-item)
--   exemptions     => HashTable : passed through to processQueueItem
-- Returns "complete" if queue emptied, "paused" if a cap stopped the run.
runQueue = {
    itemCap => null,
    maxVertexCount => null,
    timeoutSeconds => null,
    exemptions => new HashTable from {}
} >> opts -> (pendingDir, doneDir) -> (
    startTime := currentTime();
    itemsProcessed := 0;
    status := "complete";
    running := true;
    while running do (
        pendingFiles := sort select(readDirectory pendingDir, f -> f != "." and f != "..");
        if #pendingFiles == 0 then (
            running = false;
        ) else (
            shouldPause := false;
            if opts.itemCap =!= null and itemsProcessed >= opts.itemCap then (
                shouldPause = true;
            ) else if opts.timeoutSeconds =!= null and currentTime() - startTime >= opts.timeoutSeconds then (
                shouldPause = true;
            ) else if opts.maxVertexCount =!= null then (
                nextItem := readQueueItem concatenate(pendingDir, "/", pendingFiles_0);
                if #(getVertices nextItem#"triangulation") > opts.maxVertexCount then
                    shouldPause = true;
            );
            if shouldPause then (
                status = "paused";
                running = false;
            ) else (
                processQueueItem(pendingDir, doneDir, exemptions => opts.exemptions);
                itemsProcessed = itemsProcessed + 1;
            );
        );
    );
    if status === "complete" then emitRunComplete() else emitRunPaused();
    status
);

-- Emits a structured item_started event to stderr (unbuffered).
emitItemStarted = (itemName, depth, parent) -> (
    stderr << "EVENT:{\"type\":\"item_started\",\"item\":\"" | itemName |
        "\",\"depth\":" | toString depth |
        ",\"parent\":\"" | parent | "\"}" << endl;
);

-- Emits a structured item_done event to stderr (unbuffered).
emitItemDone = (itemName, splitCount) -> (
    stderr << "EVENT:{\"type\":\"item_done\",\"item\":\"" | itemName |
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

TEST ///
  -- runQueue with itemCap=1 processes exactly 1 item then returns "paused"
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
///

TEST ///
  -- runQueue runs to convergence: pending/ empties and returns "complete"
  -- Uses the 10-vertex irreducible torus (index 21), which converges quickly.
  tmpBase := temporaryFileName();
  mkdir tmpBase;
  pendingDir := concatenate(tmpBase, "/pending");
  doneDir := concatenate(tmpBase, "/done");
  mkdir pendingDir;
  mkdir doneDir;
  tri10v := (value get "data/surface triangulations/irredTori.m2")_20;
  writeQueueItem(concatenate(pendingDir, "/0001"), "seed", 0, 1, tri10v);
  result := runQueue(pendingDir, doneDir);
  assert(result === "complete")
  assert(0 == #select(readDirectory pendingDir, f -> f != "." and f != ".."))
///

TEST ///
  -- runQueue accepts all four options without error when cap variables are
  -- given distinct names that do not shadow the option symbols.
  -- Guards against the bug where := bindings named itemCap / maxVertexCount /
  -- timeoutSeconds shadow those symbols, causing null => null options and an
  -- "unknown key or option" error at the call site.
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
///

TEST ///
  -- initQueueEnv uses analysisOutputDir (absolute path) as outputDirPath
  -- This guards against the relative-path bug where M2 and C# disagree on
  -- where pending/ and done/ live.
  tmpBase := temporaryFileName();
  analysisOutputDir = tmpBase;
  analysisName = "test-run";
  analysisInputFile = "data/surface triangulations/irredTori.m2";
  load "scripts/initQueueEnv.m2";
  assert(outputDirPath === tmpBase)
  assert(isDirectory concatenate(tmpBase, "/pending"))
  assert(isDirectory concatenate(tmpBase, "/done"))
///
