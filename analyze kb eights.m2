BATCHSIZE = 510; --dividing analysis to 10 batches
batchNum = 1;
folderName = "analysis klein bottle/eight/";

exceptionFile = concatenate(folderName, "Exceptions Log.txt") << "";
logFile = concatenate(folderName, "Analysis Log.txt") << "";
exceptionalCplxFile = concatenate(folderName, "exceptions.txt") << "";
elevensFile = concatenate(folderName, "tens from nine to analyze.txt") << "";

--triangulations = value get "torus triangs for analysis v2/nines.m2";
load "klein bottle.m2";

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

finalEdge = {5,7}; --ADJUST THIS ACCORDING TO CASE!

maxCriticalPolygon = 0;

--for trIdx from BATCHSIZE*(batchNum - 1) to min(BATCHSIZE*batchNum, #triangulations) - 1 do (
for i from 0 to 5 do (
	--logFile << "analyzing complex: " << toString triangulations_trIdx << endl;
	--mcp = analyzeCritRegions(triangulations_trIdx, finalEdge);
	logFile << "analyzing KB_" << toString i << endl;
	mcp = analyzeCritRegions(KB_i, finalEdge);
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