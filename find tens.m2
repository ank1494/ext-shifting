load "tori.m2";
load "eight vertices.m2";
load "aaron libraries.m2";
file56 = "critical triangulations of torus 2/five six.txt" << "";
file57 = "critical triangulations of torus 2/five seven.txt" << "";
log56 = "critical triangulations of torus 2/five six.log" << "";
log57 = "critical triangulations of torus 2/five seven.log" << "";
for eightIndex from 0 to #TEight - 1 do (
	nines = nonTrivSplits TEight_eightIndex;
	for nineIndex from 0 to #nines - 1 do (
		tenSplits = nonTrivSplits nines_nineIndex_0;
		for ts from 0 to #tenSplits - 1 do (
			shft = extShiftLex(kSkeleton(tenSplits_ts_0, 2));
			if member({5,7},shft) then (
				file57 << tenSplits_ts_0 << endl;
				log57 << concatenate("base triangulation: TEight_", toString eightIndex, ", 1st split: ", toString nines_nineIndex, ", 2nd split: ", toString tenSplits_ts) << endl;
			)
			else if member({5,6},shft) then (
				file56 << tenSplits_ts_0 << endl;
				log56 << concatenate("base triangulation: TEight_", toString eightIndex, ", 1st split: ", toString nines_nineIndex, ", 2nd split: ", toString tenSplits_ts) << endl;
			)
			else null;
		);
	);
	print concatenate("done with TEight_", toString eightIndex);
);
print "done";
file56 << close;
file57 << close;
log56 << close;
log57 << close;