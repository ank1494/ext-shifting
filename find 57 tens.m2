load "tori.m2";
load "eight vertices.m2";
load "aaron libraries.m2";
file = "bad 57 tens.txt" << endl;
for eightIndex from 0 to #TEight - 1 do (
	nines = nonTrivSplits TEight_eightIndex;
	for nineIndex from 0 to #nines - 1 do (
		tenSplits = nonTrivSplits nines_nineIndex_0;
		for ts from 0 to #tenSplits - 1 do (
			shft = extShiftLex(kSkeleton(tenSplits_ts_0, 2));
			if member({5,7},shft) then (
				file << concatenate("base triangulation: TEight_", toString eightIndex, ", first split: ", toString nines_nineIndex, ", next split: ", toString tenSplits_ts) << endl;
			)
			else print "good split";
		);
	);
	print concatenate("done with TEight_", toString eightIndex);
);
print "done with splits from 8";
	for nineIndex from 5 to 19 do (
		tenSplits = nonTrivSplits T_nineIndex;
		for ts from 0 to #tenSplits - 1 do (
			shft = extShiftLex(kSkeleton(tenSplits_ts_0, 2));
			if member({5,7},shft) then (
				file << concatenate("base triangulation: T_", toString nineIndex, ", split: ", toString tenSplits_ts) << endl;
			)
			else print "good split";
		);
		print concatenate("done with T_", toString nineIndex);
	);
print "done with splits from 9";
file << close;