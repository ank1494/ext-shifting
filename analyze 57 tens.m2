exceptionFile = "analysis of critical triangulations with 10 vertices/Exceptions Log 57.txt" << "";
logFile = "analysis of critical triangulations with 10 vertices/Analysis Log 57.txt" << "";
exceptionalCplxFile = "analysis of critical triangulations with 10 vertices/exceptions 57.txt" << "";
elevensFile = "analysis of critical triangulations with 10 vertices/elevens to analyze 57.txt" << "";

triangulations = value get "critical triangulations for analysis/five seven.m2";

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

for trIdx from 0 to #triangulations -1 do (
	logFile << "analyzing complex: " << toString triangulations_trIdx << endl;
	mcp = analyzeCritRegions(triangulations_trIdx, {5,7});
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