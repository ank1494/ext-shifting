BATCHSIZE = 510; --dividing analysis to 10 batches
batchNum = 1;
folderName = "analysis v2/eight/";

exceptionFile = concatenate(folderName, "Exceptions Log part ", toString batchNum, ".txt") << "";
logFile = concatenate(folderName, "Analysis Log part ", toString batchNum, ".txt") << "";
exceptionalCplxFile = concatenate(folderName, "exceptions part ", toString batchNum, ".txt") << "";
elevensFile = concatenate(folderName, "nines from eight to analyze part ", toString batchNum, ".txt") << "";

--triangulations = value get 

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
load "eight vertices.m2";


maxCriticalPolygon = 0;

--for trIdx from BATCHSIZE*(batchNum - 1) to min(BATCHSIZE*batchNum, #triangulations) - 1 do (
for eightIndex from 0 to #TEight - 1 do (
	logFile << "analyzing complex TEight_" << toString eightIndex << endl;
	mcp = analyzeCritRegions(TEight_eightIndex, {5,7});
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