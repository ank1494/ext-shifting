exceptionFile = "Exceptional Splits Log.txt" << "";
logFile = "Splits Analysis Log.txt" << "";
exceptionalCplxFile = "Exceptional Complexes.txt" << "";

logException = (cplx, msg) -> (
	logFile << "exception found" << endl;
	exceptionFile << "complex: " << toString cplx << endl << "reason: "<< msg << endl << endl;
	exceptionalCplxFile << toString cplx << endl;
);

logInfo = msg -> (
	logFile << msg << endl;
);

load "libs.m2";
load "tori.m2";
load "eight vertices.m2";

maxCriticalPolygon = 0;

for nineIndex from 5 to 19 do (
	logFile << concatenate("starting T_", toString nineIndex) << endl;
	tenSplits = nonTrivSplits T_nineIndex;
	for ts from 0 to #tenSplits - 1 do (
		shft = extShiftLex(kSkeleton(tenSplits_ts_0, 2));
		if member({5,6},shft) then (
			logFile << "analyzing complex: " << toString tenSplits_ts_0 << endl;
			logFile << "split path: start from T_" << toString nineIndex << ", split base: " << tenSplits_ts_1_SPLITBASE << ", neighbors: " << tenSplits_ts_1_SPLITNEIGHBORS << endl;
			mcp = analyzeCritRegions(tenSplits_ts_0, shft_-1);
			logFile << "done analysis, max critical polygon size: " << mcp;
			maxCriticalPolygon = max(mcp, maxCriticalPolygon);
			collectGarbage();
		);
	);
	logFile << concatenate("done with T_", toString nineIndex) << endl;
	print concatenate("done with T_", toString nineIndex);
);
print "done with splits from 9";

for eightIndex from 0 to #TEight - 1 do (
	logFile << concatenate("starting TEight_", toString eightIndex) << endl;
	nines = nonTrivSplits TEight_eightIndex;
	for nineIndex from 0 to #nines - 1 do (
		tenSplits = nonTrivSplits nines_nineIndex_0;
		for ts from 0 to #tenSplits - 1 do (
			shft = extShiftLex(kSkeleton(tenSplits_ts_0, 2));
			if member({5,6},shft) then (
				logFile << "analyzing complex: " << toString tenSplits_ts_0 << endl;
				logFile << "final edge in shift: " << toString shft_-1 << endl;
				logFile << "split path: start from TEight_" << toString eightIndex << ", 1st split base: " << nines_nineIndex_1_SPLITBASE << ", neighbors: " << nines_nineIndex_1_SPLITNEIGHBORS << ", 2st split base: " << tenSplits_ts_1_SPLITBASE << ", neighbors: " << tenSplits_ts_1_SPLITNEIGHBORS << endl;
				mcp = analyzeCritRegions(tenSplits_ts_0, shft_-1);
				logFile << "done analysis, max critical polygon size: " << mcp << endl;
				maxCriticalPolygon = max(mcp, maxCriticalPolygon);
				collectGarbage();
			);
		);
	);
	logFile << concatenate("done with TEight_", toString eightIndex) << endl;
	print concatenate("done with TEight_", toString eightIndex);
);
print "done with splits from 8";

print concatenate("done, largest critical polygon size: ", toString maxCriticalPolygon);
logFile << concatenate("done, largest critical polygon size: ", toString maxCriticalPolygon) << endl;

exceptionFile << close;
logFile << close;
exceptionalCplxFile << close;