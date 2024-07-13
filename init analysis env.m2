--todo - add logging or output to console?
load "analysis config.m2";
ANALYSIS'OUTPUT'FOLDER = "analysis output";
INPUT'FOLDER'NAME = ".INPUT_FOLDER_DO_NOT_TOUCH";
ITERATION'COUNTER'FILENAME = "ITERATION_COUNTER";
try mkdir ANALYSIS'OUTPUT'FOLDER;
outputDirPath = concatenate(ANALYSIS'OUTPUT'FOLDER, "/", analysisName);
inputDirPath = concatenate(outputDirPath, "/", INPUT'FOLDER'NAME);
iterationCounterPath = concatenate(inputDirPath, "/", ITERATION'COUNTER'FILENAME);
iterationCounter = 0;
needsInputInit = false;
if not isDirectory outputDirPath then (
    print concatenate("creating analysis directory: ", outputDirPath);
    mkdir outputDirPath;
    needsInputInit = true;
) else (
    if fileExists iterationCounterPath then (
        iterationCounter = value get iterationCounterPath;
        print "loaded iteration counter from file";
    ) else (
        needsInputInit = true;
    );
);

print concatenate("iteration number: ", toString iterationCounter);
inputFilePath = concatenate(inputDirPath, "/input_", toString iterationCounter);
print concatenate("inputFilePath: ", inputFilePath);

if needsInputInit then (
    if not isDirectory inputDirPath then (
        print "creating input directory";
        mkdir inputDirPath;
    );
    print "creating iteration counter";
    iterationCounterPath << iterationCounter << close;
    print "copying input file";
    copyFile(analysisInputFile, inputFilePath, Verbose=>true);
);

iterationOutputDir = concatenate(outputDirPath, "/", "iteration_", toString(iterationCounter + 1));
mkdir iterationOutputDir;

