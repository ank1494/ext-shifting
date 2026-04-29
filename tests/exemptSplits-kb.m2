load "libs.m2";
irredKb := value get "data/surface triangulations/irredKb.m2";
kbExempts := value get "data/surface triangulations/kbExemptSplits.m2";

assert(instance(kbExempts, HashTable));
print "exemptSplits-kb (load): PASSED";

-- KB0–KB5 automorphism exemptions + KB25 union of automorphism and connected-sum exemptions
for i in {0,1,2,3,4,25} do assert(kbExempts#?(irredKb_i));
-- KB5 has a trivial automorphism group — no entry expected
assert(not kbExempts#?(irredKb_5));
print "exemptSplits-kb (keys): PASSED";

splitPairs = tri -> set apply(nonTrivialVertexSplits tri, s -> {(s_1)#base, (s_1)#neighbors});
allSplitsAtBase = (tri, b) -> apply(select(nonTrivialVertexSplits tri, s -> (s_1)#base == b), s -> {(s_1)#base, (s_1)#neighbors});

for i in {0,1,2,3,4,25} do (
    tri := irredKb_i;
    allPairs := splitPairs tri;
    for e in kbExempts#tri do assert(member(e, allPairs));
);
print "exemptSplits-kb (smoke/subset): PASSED";

checkReps = (tri, expectedReps) -> (
    exempts := kbExempts#tri;
    actual := toList(splitPairs(tri) - set exempts);
    assert(set actual === set expectedReps)
);

-- KB0: automorphism (0 6)(1 5)(2 3)(4 7); all splits at bases 3,5,6,7 exempt
checkReps(irredKb_0, join(
    allSplitsAtBase(irredKb_0, 0),
    allSplitsAtBase(irredKb_0, 1),
    allSplitsAtBase(irredKb_0, 2),
    allSplitsAtBase(irredKb_0, 4)));
print "exemptSplits-kb (reps/KB0): PASSED";

-- KB1: automorphism (0 2)(3 6)(4 7); fully exempt bases 2,6,7; partial at 1 and 5
checkReps(irredKb_1, join(
    allSplitsAtBase(irredKb_1, 0),
    {{1,{0,2}},{1,{0,7}},{1,{4,5}}},
    allSplitsAtBase(irredKb_1, 3),
    allSplitsAtBase(irredKb_1, 4),
    {{5,{0,2}},{5,{0,4}},{5,{0,6}},{5,{0,7}},{5,{1,3}},{5,{1,4}},{5,{3,6}},{5,{3,7}}}));
print "exemptSplits-kb (reps/KB1): PASSED";

-- KB2: group order 8, orbits of 4 vertices each; reps at bases 0 and 2 only
checkReps(irredKb_2, {
    {0,{1,2}},{0,{2,3}},{0,{3,4}},
    {2,{0,1}},{2,{0,3}},{2,{0,5}},{2,{0,6}},{2,{3,4}},{2,{3,6}},{2,{3,7}},{2,{5,7}}});
print "exemptSplits-kb (reps/KB2): PASSED";

-- KB3: automorphism (1 2)(4 6)(5 7); fully exempt bases 2,6,7; partial at 0 and 3
checkReps(irredKb_3, join(
    {{0,{1,2}},{0,{1,6}},{0,{3,4}}},
    allSplitsAtBase(irredKb_3, 1),
    {{3,{0,4}},{3,{0,5}},{3,{1,2}},{3,{1,4}},{3,{1,6}},{3,{1,7}},{3,{4,7}},{3,{5,7}}},
    allSplitsAtBase(irredKb_3, 4),
    allSplitsAtBase(irredKb_3, 5)));
print "exemptSplits-kb (reps/KB3): PASSED";

-- KB4: automorphism (0 1)(3 7)(4 5); fully exempt bases 1,5,7; partial at 2 and 6; all at 0,3,4
checkReps(irredKb_4, join(
    allSplitsAtBase(irredKb_4, 0),
    {{2,{0,1}},{2,{0,5}},{2,{0,6}},{2,{0,7}},{2,{3,4}},{2,{3,5}},{2,{3,6}},{2,{4,5}}},
    allSplitsAtBase(irredKb_4, 3),
    allSplitsAtBase(irredKb_4, 4),
    {{6,{2,3}},{6,{3,5}},{6,{4,5}}}));
print "exemptSplits-kb (reps/KB4): PASSED";

-- KB25: group order 6 (automorphism-based) unioned with connected-sum seam exemptions.
-- Automorphism orbit {0,1,2}: reps at bases 0 and 3 only.
-- Connected-sum adds {0,{1,2}} (a rep in the automorphism analysis but a false positive here).
checkReps(irredKb_25, join(
    {{0,{1,3}},{0,{1,5}},{0,{2,3}},{0,{2,6}},{0,{3,4}},{0,{3,7}},{0,{3,8}},{0,{5,6}},{0,{5,7}},{0,{5,8}},{0,{6,8}}},
    allSplitsAtBase(irredKb_25, 3)));
print "exemptSplits-kb (reps/KB25): PASSED";

print "ALL exemptSplits-kb TESTS PASSED"
