load "klein bottle.m2";
load "aaron libraries.m2";
file = "kb triangs/nines.txt" << "";
logfile = "kb triangs/nines.log" << "";
for eightIndex from 0 to 5 do (
	nines = nonTrivSplits KB_eightIndex;
	for nineIndex from 0 to #nines - 1 do (
		shft1 = extShiftLex getEdges nines_nineIndex_0;
		shft2 = extShiftLex getEdges nines_nineIndex_0;
		if (not member({5,7},shft1) or not member({5,7},shft2)) and member({5,6},shft1) and member({5,6},shft2) then (
			logfile << concatenate("base triangulation: KB_", toString eightIndex, ", split: ", toString nines_nineIndex) << endl;
			file << nines_nineIndex_0 << endl;
		) 
	);
	print concatenate("done with KB_", toString eightIndex);
);
print "done with splits from 8";
file << close;
logfile << close;