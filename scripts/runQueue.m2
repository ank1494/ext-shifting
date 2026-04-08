-- Queue orchestrator: processes items from the analysis queue until empty or a cap is hit.
-- Usage: M2 --script scripts/runQueue.m2 /absolute/path/to/config.m2 [itemCap] [maxVertexCount] [timeoutSeconds]
--
-- Config file must set:
--   analysisName      -- string: name of this analysis run
--   analysisInputFile -- string: absolute path to initial triangulations file
--
-- Batch cap arguments (positional, pass "null" to skip a cap):
--   itemCap        -- integer: max items to process this invocation
--   maxVertexCount -- integer: stop before processing items with more vertices than this
--   timeoutSeconds -- integer: wall-clock timeout in seconds (soft — never mid-item)

load (scriptCommandLine)_1;

libsLoaded := false;
try (load "libs.m2"; libsLoaded = true);
if not libsLoaded then (stderr << "error: failed to load libs.m2" << endl; exit 2);

envLoaded := false;
try (load "scripts/initQueueEnv.m2"; envLoaded = true);
if not envLoaded then (stderr << "error: failed to initialize queue environment" << endl; exit 2);

kbExemptSplits := value get "data/surface triangulations/kbExemptSplits.m2";

parseCapArg = argIdx -> (
    if #scriptCommandLine <= argIdx then null
    else if (scriptCommandLine)_argIdx == "null" then null
    else value((scriptCommandLine)_argIdx)
);

capItem     := parseCapArg 2;
capMaxVerts := parseCapArg 3;
capTimeout  := parseCapArg 4;

pendingDir := concatenate(outputDirPath, "/pending");
doneDir    := concatenate(outputDirPath, "/done");

runQueue(pendingDir, doneDir,
    itemCap        => capItem,
    maxVertexCount => capMaxVerts,
    timeoutSeconds => capTimeout,
    exemptions     => kbExemptSplits);

exit 0;
