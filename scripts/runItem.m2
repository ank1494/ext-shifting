-- Processes one item from the analysis queue.
-- Usage: M2 --script scripts/runItem.m2 /absolute/path/to/config.m2
--
-- Config file must set:
--   analysisName      -- string: name of this analysis run
--   analysisInputFile -- string: absolute path to initial triangulations file

load (scriptCommandLine)_1;

libsLoaded := false;
try (load "libs.m2"; libsLoaded = true);
if not libsLoaded then (stderr << "error: failed to load libs.m2" << endl; exit 2);

envLoaded := false;
try (load "scripts/initQueueEnv.m2"; envLoaded = true);
if not envLoaded then (stderr << "error: failed to initialize queue environment" << endl; exit 2);

kbExemptSplits := value get "data/surface triangulations/kbExemptSplits.m2";

pendingDir := concatenate(outputDirPath, "/pending");
doneDir := concatenate(outputDirPath, "/done");

pendingFiles := select(readDirectory pendingDir, f -> f != "." and f != "..");
if #pendingFiles == 0 then (
    stderr << "queue is empty" << endl;
    exit 0;
);

processQueueItem(pendingDir, doneDir, exemptions => kbExemptSplits);
exit 0;
