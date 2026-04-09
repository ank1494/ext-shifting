-- Initializes the queue environment for iterative analysis.
-- Replaces initAnalysisEnv.m2.
--
-- Expects globals set by the caller (e.g. runItem.m2 or a config file):
--   analysisName      -- string: name of this analysis run
--   analysisOutputDir -- string: absolute path to the run output directory
--   analysisInputFile -- string: absolute path to the initial triangulations file
--
-- Sets global used by subsequent scripts:
--   outputDirPath -- string: path to the run output directory

outputDirPath = analysisOutputDir;
if not isDirectory outputDirPath then mkdir outputDirPath;

initQueue(outputDirPath, analysisInputFile);
