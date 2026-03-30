--init analysis environment
envLoaded := false;
try (load "scripts/initAnalysisEnv.m2"; envLoaded = true);
if not envLoaded then (stderr << "error: failed to initialize analysis environment" << endl; exit 2);

outputListToFile = (l, fName) -> (
    outf := fName << "{" << l_0 << endl;
    for i from 1 to #l - 1 do (outf << "," << l_i << endl);
    outf << "}" << close;
);

exceptionFile = concatenate(iterationOutputDir, "/Exceptions Log.txt") << "";
logFile = concatenate(iterationOutputDir, "/Analysis Log.txt") << "";
summaryFile = concatenate(iterationOutputDir, "/Analysis Summary.txt") << "";

logException = (cplx, msg) -> (
    logFile << "exception found" << endl;
    exceptionFile << "complex: " << toString cplx << endl << "reason: " << msg << endl << endl;
);
logInfo = msg -> (
    logFile << msg << endl;
);

printLive concatenate("reading input file: ", inputFilePath);
triangulations := {};
inputLoaded := false;
try (triangulations = value get inputFilePath; inputLoaded = true);
if not inputLoaded then (stderr << "error: failed to read input file: " << inputFilePath << endl; exit 2);
printLive concatenate("loaded ", toString(#triangulations), " triangulations");

printLive "loading libraries...";
libsLoaded := false;
stderr << "debug: fileExists libs.m2 = " << fileExists "libs.m2" << endl;
try (load "libs.m2"; libsLoaded = true);
stderr << "debug: libsLoaded = " << libsLoaded << endl;
if not libsLoaded then (stderr << "error: failed to load libs.m2" << endl; exit 2);
printLive "libraries loaded";

if #triangulations > 0 then (
    printLive concatenate("begin calculation, ", toString(#triangulations), " triangulations to analyze");
    logFile << "begin calculation" << endl;

    (foundCritRegions, splitsForNextCalc, largestNonPrefixTriangulation) := analyzeIteration triangulations;

    --output summary
    critRegionsSummary = concatenate("the following critical regions were found: ", toString toList foundCritRegions);
    cplxSizeSummary = concatenate("largest triangulation with shifting not a prefix had ", toString largestNonPrefixTriangulation, " vertices");
    printLive "iteration done, summary:";
    printLive critRegionsSummary;
    printLive cplxSizeSummary;
    summaryFile << critRegionsSummary << endl;
    summaryFile << cplxSizeSummary << endl;

    --output splits for next calculation, and update iteration counter
    iterationCounter = 1 + iterationCounter;
    nextCalcInputPath = concatenate(inputDirPath, "/input_", toString iterationCounter);
    if 0 == #splitsForNextCalc then (
        --converged: no more splits
        summaryFile << "converged" << endl;
        logFile << "converged" << endl;
        nextCalcInputPath << splitsForNextCalc << close;
        exceptionFile << close;
        logFile << close;
        summaryFile << close;
        iterationCounterPath << iterationCounter << close;
        exit 0;
    ) else (
        --more iterations needed
        outputListToFile(splitsForNextCalc, nextCalcInputPath);
        iterationCounterPath << iterationCounter << close;
        exceptionFile << close;
        logFile << close;
        summaryFile << close;
        exit 1;
    );
) else (
    --no triangulations to process: converged
    exceptionFile << close;
    logFile << close;
    summaryFile << close;
    exit 0;
);
