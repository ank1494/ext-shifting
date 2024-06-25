load "klein bottle.m2";
load "aaron libraries.m2";
file = "kb triangs/tens from Kc1.txt" << "";
logfile = "kb triangs/tens from Kc1.log" << "";
tens = nonTrivSplits KBC_0;
baseVs = {0,1,2}; -- these are the vertices on the gluing between the projective planes
half = {3,5,6}; -- these vertices are on one side of the gluing
--only want splits that lengthen 0,1,2 cycle
tens = select(tens, s -> member(s_1_SPLITBASE, baseVs) and (not member(s_1_SPLITNEIGHBORS_0, baseVs)) and (not member(s_1_SPLITNEIGHBORS_1, baseVs)) and (member(s_1_SPLITNEIGHBORS_0, half) xor member(s_1_SPLITNEIGHBORS_1, half)));
for tenIndex from 0 to #tens - 1 do (
	shft1 = extShiftLex getEdges tens_tenIndex_0;
	shft2 = extShiftLex getEdges tens_tenIndex_0;
	if (not member({5,7},shft1) or not member({5,7},shft2)) and member({5,6},shft1) and member({5,6},shft2) then (
		logfile << concatenate("base triangulation: KBC_0, split: ", toString tens_tenIndex) << endl;
		file << tens_tenIndex_0 << endl;
	) 
);
print "done with KBC_0";
file << close;
logfile << close;