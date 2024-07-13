--init analysis environment
load "init analysis env.m2";

CALC'FINISHED'STR = "CALCULATION FINISHED, NO MORE SPLITS FOR CALCULATION";
exceptionFile = concatenate(iterationOutputDir, "/Exceptions Log.txt") << "";
logFile = concatenate(iterationOutputDir, "/Analysis Log.txt") << "";
summaryFile = concatenate(iterationOutputDir, "/Analysis Summary.txt") << "";
--exceptionalCplxFile = concatenate(iterationOutputDir, "/exceptions.txt") << "";

triangulations = value get inputFilePath;

saveSplitToAnalyze = cplx -> ();

logException = (cplx, msg) -> (
	logFile << "exception found" << endl;
	exceptionFile << "complex: " << toString cplx << endl << "reason: "<< msg << endl << endl;
	--exceptionalCplxFile << toString cplx << endl;
);

logInfo = msg -> (
	logFile << msg << endl;
);

load "libs.m2";

splitsForNextCalc = {};
largestNonPrefixTriangulation = 0;
foundCritRegions = set {getCritRegionString("disk",3,0)};

if #triangulations > 0 then (
    --todo: limit size of calculation, and output leftovers along with calculated splits
    print concatenate("begin calculation, ", toString(#triangulations), " triangulations to analyze");
    for trIdx from 0 to #triangulations - 1 do (
        print concatenate("analyzing ", toString (trIdx + 1), " of ", toString(#triangulations));
	    logFile << "analyzing complex: " << toString triangulations_trIdx << endl;
        finalE = finalEdgeOfShift triangulations_trIdx;
        logInfo concatenate("final edge of shift: ", toString finalE);
        if not member(4, finalE) then (
            cplxSize = #(getVertices triangulations_trIdx);
            largestNonPrefixTriangulation = max(largestNonPrefixTriangulation, cplxSize);
	        critRegCalculation = getCritRegions(triangulations_trIdx, finalE);
	        logFile << "done analyzing complex, critical regions found: " << toString toList critRegCalculation_0 << endl;
	        foundCritRegions = foundCritRegions + critRegCalculation_0;
	        if 0 < #critRegCalculation_1 then (
	            --vertex splits have 1 more vertex
                largestNonPrefixTriangulation = max(largestNonPrefixTriangulation, 1 + cplxSize);
                splitsForNextCalc = splitsForNextCalc | critRegCalculation_1;
	            --todo: filter out splits from crosscap kb that we don't pick up
	        );
        );

	    collectGarbage();
    );

    --output summary
    critRegionsSummary = concatenate("the following critical regions were found: ", toString toList foundCritRegions);
    cplxSizeSummary = concatenate("largest triangulation with shifting not a prefix had ", toString largestNonPrefixTriangulation, " vertices");
    print "iteration done, summary:";
    print critRegionsSummary;
    print cplxSizeSummary;
    summaryFile << critRegionsSummary << endl;
    summaryFile << cplxSizeSummary << endl;

    --output splits for next calculation, and update iteration counter
    iterationCounter = 1 + iterationCounter;
    nextCalcInputPath = concatenate(inputDirPath, "/input_", toString iterationCounter);
    if 0 == #splitsForNextCalc then (--calculation is done
        print CALC'FINISHED'STR;
        summaryFile << CALC'FINISHED'STR << endl;
        logFile << CALC'FINISHED'STR << endl;
        nextCalcInputPath << splitsForNextCalc << close;
    ) else (
        outputListToFile(splitsForNextCalc, nextCalcInputPath);
    );
    iterationCounterPath << iterationCounter << close;
) else (
    print "no more splits to calculate";
);
exceptionFile << close;
logFile << close;
summaryFile << close;
--exceptionalCplxFile << close;