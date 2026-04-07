-- Initializes the queue environment for iterative analysis.
-- Replaces initAnalysisEnv.m2.
--
-- Expects globals set by the caller (e.g. runItem.m2 or a config file):
--   analysisName      -- string: name of this analysis run
--   analysisInputFile -- string: absolute path to the initial triangulations file
--
-- Sets global used by subsequent scripts:
--   outputDirPath -- string: path to the run output directory

ANALYSIS'OUTPUT'FOLDER = "analysis output";
try mkdir ANALYSIS'OUTPUT'FOLDER;
outputDirPath = concatenate(ANALYSIS'OUTPUT'FOLDER, "/", analysisName);
if not isDirectory outputDirPath then mkdir outputDirPath;

initQueue(outputDirPath, analysisInputFile);
