BATCHSIZE = 510; --dividing analysis to 10 batches
batchNum = 1;
folderName = "analysis v2/nine/";

exceptionFile = concatenate(folderName, "Exceptions Log irred.txt") << "";
logFile = concatenate(folderName, "Analysis Log irred.txt") << "";
exceptionalCplxFile = concatenate(folderName, "exceptions irred.txt") << "";
elevensFile = concatenate(folderName, "tens from nine to analyze irred.txt") << "";

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
load "tori.m2";


maxCriticalPolygon = 0;

--for trIdx from BATCHSIZE*(batchNum - 1) to min(BATCHSIZE*batchNum, #triangulations) - 1 do (
for nineIndex from 5 to 19 do (
	logFile << "analyzing complex T_" << toString nineIndex << endl;
	mcp = analyzeCritRegions(T_nineIndex, {5,6});
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