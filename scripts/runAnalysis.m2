--init analysis environment
load "scripts/initAnalysisEnv.m2";

outputListToFile = (l, fName) -> (
    outf := fName << "{" << l_0 << endl;
    for i from 1 to #l - 1 do (outf << "," << l_i << endl);
    outf << "}" << close;
);

calcFinishedStr = "CALCULATION FINISHED, NO MORE SPLITS FOR CALCULATION";
exceptionFile = concatenate(iterationOutputDir, "/Exceptions Log.txt") << "";
logFile = concatenate(iterationOutputDir, "/Analysis Log.txt") << "";
summaryFile = concatenate(iterationOutputDir, "/Analysis Summary.txt") << "";

printLive concatenate("reading input file: ", inputFilePath);
triangulations = value get inputFilePath;
printLive concatenate("loaded ", toString #triangulations, " triangulations");

printLive "loading libraries...";
load "libs.m2";
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
    if 0 == #splitsForNextCalc then (--calculation is done
        printLive calcFinishedStr;
        summaryFile << calcFinishedStr << endl;
        logFile << calcFinishedStr << endl;
        nextCalcInputPath << splitsForNextCalc << close;
    ) else (
        outputListToFile(splitsForNextCalc, nextCalcInputPath);
    );
    iterationCounterPath << iterationCounter << close;
) else (
    printLive "no more splits to calculate";
);
exceptionFile << close;
logFile << close;
summaryFile << close;
