load "tori.m2";
load "eight vertices.m2";
load "aaron libraries.m2";
file = "bad tens 4 prime.txt" << endl;
	for nineIndex from 5 to 19 do (
		tenSplits = nonTrivSplits T_nineIndex;
		for ts from 0 to #tenSplits - 1 do (
			shft = extShiftLex(kSkeleton(tenSplits_ts_0, 2));
			if (member({5,6},shft) and (is4prime tenSplits_ts_0)) then (
				file << concatenate("base triangulation: T_", toString nineIndex, ", split: ", toString tenSplits_ts) << endl;
				print "found bad 4prime!";
			);
		);
		print concatenate("done with T_", toString nineIndex);
	);
print "done with splits from 9";
for eightIndex from 0 to #TEight - 1 do (
	nines = nonTrivSplits TEight_eightIndex;
	for nineIndex from 0 to #nines - 1 do (
		if is4prime nines_nineIndex_0 then (
			tenSplits = nonTrivSplits nines_nineIndex_0;
			for ts from 0 to #tenSplits - 1 do (
				shft = extShiftLex(kSkeleton(tenSplits_ts_0, 2));
				if (member({5,6},shft) and (is4prime tenSplits_ts_0)) then (
					file << concatenate("base triangulation: TEight_", toString eightIndex, ", first split: ", toString nines_nineIndex, ", next split: ", toString tenSplits_ts) << endl;
					print "found bad 4prime!";
				);
			);
		);
	);
	print concatenate("done with TEight_", toString eightIndex);
);
print "done with splits from 8";
file << close;