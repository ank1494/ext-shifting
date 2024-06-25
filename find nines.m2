load "tori.m2";
load "eight vertices.m2";
load "aaron libraries.m2";
file = "torus triangs for analysis v2/nines.txt" << "";
logfile = "torus triangs for analysis v2/nines.log" << "";
for eightIndex from 0 to #TEight - 1 do (
	nines = nonTrivSplits TEight_eightIndex;
	for nineIndex from 0 to #nines - 1 do (
		shft = extShiftLex getEdges nines_nineIndex_0;
		if not member({5,7},shft) then (
			logfile << concatenate("base triangulation: TEight_", toString eightIndex, ", split: ", toString nines_nineIndex) << endl;
			file << nines_nineIndex_0 << endl;
		) 
	);
	print concatenate("done with TEight_", toString eightIndex);
);
print "done with splits from 8";
file << close;
logfile << close;