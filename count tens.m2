load "tori.m2";
load "eight vertices.m2";
load "aaron libraries.m2";
goodCount = 0;
badCount = 0;
for eightIndex from 0 to #TEight - 1 do (
	nines = nonTrivSplits TEight_eightIndex;
	for nineIndex from 0 to #nines - 1 do (
		if is4prime nines_nineIndex_0 then (
			tenSplits = nonTrivSplits nines_nineIndex_0;
			for ts from 0 to #tenSplits - 1 do (
				shft = extShiftLex(kSkeleton(tenSplits_ts_0, 2));
				if member({5,6},shft) then (badCount = badCount + 1; null)
				else (goodCount = goodCount + 1; null);
			);
		);
	);
	print concatenate("done with TEight_", toString eightIndex, " - current tally: goodCount=",goodCount," badCount=",badCount);
);
print concatenate("done, final tally: goodCount=",goodCount," badCount=",badCount);