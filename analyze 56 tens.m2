BATCHSIZE = 510; --dividing analysis to 10 batches
batchNum = 10;

exceptionFile = concatenate("analysis of critical triangulations with 10 vertices/Exceptions Log 56 part ", toString batchNum, ".txt") << "";
logFile = concatenate("analysis of critical triangulations with 10 vertices/Analysis Log 56 part ", toString batchNum, ".txt") << "";
exceptionalCplxFile = concatenate("analysis of critical triangulations with 10 vertices/exceptions 56 part ", toString batchNum, ".txt") << "";
elevensFile = concatenate("analysis of critical triangulations with 10 vertices/elevens to analyze 56 part ", toString batchNum, ".txt") << "";


triangulations = value get "critical triangulations for analysis/five six.m2";

saveSplitToAnalyze = cplx -> elevensFile << toString cplx << endl;

logException = (cplx, msg) -> (
	logFile << "exception found" << endl;
	exceptionFile << "complex: " << toString cplx << endl << "reason: "<< msg << endl << endl;
	exceptionalCplxFile << toString cplx << endl;
);

logInfo = msg -> (
	logFile << msg << endl;
);

load "aaron libraries.m2";

maxCriticalPolygon = 0;

for trIdx from BATCHSIZE*(batchNum - 1) to min(BATCHSIZE*batchNum, #triangulations) - 1 do (
	logFile << "analyzing complex: " << toString triangulations_trIdx << endl;
	mcp = analyzeCritRegions(triangulations_trIdx, {5,6});
	logFile << "done analysis, max critical polygon size: " << mcp << endl;
	maxCriticalPolygon = max(mcp, maxCriticalPolygon);
	collectGarbage();
);

print concatenate("done, largest critical polygon size: ", toString maxCriticalPolygon);
logFile << concatenate("done, largest critical polygon size: ", toString maxCriticalPolygon) << endl;

exceptionFile << close;
logFile << close;
exceptionalCplxFile << close;
elevensFile << close;