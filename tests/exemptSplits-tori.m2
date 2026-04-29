load "libs.m2";
irredTori := value get "data/surface triangulations/irredTori.m2";
toriExempts := value get "data/surface triangulations/toriExemptSplits.m2";

assert(instance(toriExempts, HashTable));
print "exemptSplits-tori (load): PASSED";

for i in {0,1,2,3,4} do assert(toriExempts#?(irredTori_i));
print "exemptSplits-tori (keys): PASSED";

splitPairs = tri -> set apply(nonTrivialVertexSplits tri, s -> {(s_1)#base, (s_1)#neighbors});
allSplitsAtBase = (tri, b) -> apply(select(nonTrivialVertexSplits tri, s -> (s_1)#base == b), s -> {(s_1)#base, (s_1)#neighbors});

for i in {0,1,2,3,4} do (
    tri := irredTori_i;
    allPairs := splitPairs tri;
    for e in toriExempts#tri do assert(member(e, allPairs));
);
print "exemptSplits-tori (smoke/subset): PASSED";

checkReps = (tri, expectedReps) -> (
    exempts := toriExempts#tri;
    actual := toList(splitPairs(tri) - set exempts);
    assert(set actual === set expectedReps)
);

-- T0: transitive group (order 42); only vertex 0 needed; 2 reps (one ratio-2,4 and one ratio-3,3)
checkReps(irredTori_0, {{0, {1, 2}}, {0, {1, 6}}});
print "exemptSplits-tori (reps/T0): PASSED";

-- T1: transitive group; 4 reps at vertex 0 (one per orbit of link pairs)
checkReps(irredTori_1, {{0, {1, 2}}, {0, {1, 7}}, {0, {2, 4}}, {0, {2, 6}}});
print "exemptSplits-tori (reps/T1): PASSED";

-- T2: group of order 4; reps at bases 0, 1, 2, 4
checkReps(irredTori_2, {
    {0,{1,2}},{0,{1,4}},{0,{2,6}},
    {1,{0,2}},{1,{0,4}},{1,{0,5}},{1,{0,7}},{1,{2,3}},{1,{2,6}},{1,{2,7}},{1,{3,4}},
    {2,{0,1}},{2,{0,5}},{2,{0,7}},{2,{1,3}},{2,{1,7}},{2,{4,7}},
    {4,{0,1}},{4,{0,7}},{4,{1,3}},{4,{1,6}},{4,{2,6}},{4,{2,7}}});
print "exemptSplits-tori (reps/T2): PASSED";

-- T3: group of order 6; reps at bases 0, 1, 3
checkReps(irredTori_3, {
    {0,{1,2}},{0,{2,6}},{0,{3,6}},
    {1,{0,2}},{1,{0,5}},{1,{2,3}},{1,{2,6}},{1,{2,7}},{1,{3,6}},{1,{3,7}},{1,{5,7}},
    {3,{0,4}},{3,{0,5}},{3,{1,2}}});
print "exemptSplits-tori (reps/T3): PASSED";

-- T4: group of order 4; bases 0 and 1 retain all splits (trivial stabilizer / low degree);
-- bases 5 and 6 retain specific reps; bases 2, 3, 4, 7 fully exempt
checkReps(irredTori_4, join(
    allSplitsAtBase(irredTori_4, 0),
    allSplitsAtBase(irredTori_4, 1),
    {{5,{1,4}},{5,{1,6}},{5,{2,4}},
     {6,{1,2}},{6,{1,3}},{6,{1,5}},{6,{5,7}}}));
print "exemptSplits-tori (reps/T4): PASSED";

print "ALL exemptSplits-tori TESTS PASSED"
