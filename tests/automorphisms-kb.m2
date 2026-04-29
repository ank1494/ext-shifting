load "libs.m2";
irredKb := value get "data/surface triangulations/irredKb.m2";
kbExempts := value get "data/surface triangulations/kbExemptSplits.m2";
kbAuts := value get "data/surface triangulations/kbAutomorphisms.m2";

splitPairs = tri -> toList apply(nonTrivialVertexSplits tri, s -> {(s_1)#base, (s_1)#neighbors});

-- Lex less-than on equal-length integer lists.
lexLt = (a, b) -> (
    pos := select(0..#a-1, i -> a_i != b_i);
    if #pos == 0 then false else a_(pos_0) < b_(pos_0)
);

expectedOrders := hashTable {
    irredKb_0  => 2,
    irredKb_1  => 2,
    irredKb_2  => 8,
    irredKb_3  => 2,
    irredKb_4  => 2,
    irredKb_25 => 6
};

for tri in {irredKb_0, irredKb_1, irredKb_2, irredKb_3, irredKb_4, irredKb_25} do (
    gens := kbAuts#tri;
    grp := groupClosure gens;

    -- 1. Correct group order
    assert(#grp == expectedOrders#tri);

    -- 2. Every group element is an automorphism
    assert(all(grp, g -> isAutomorphism(g, tri)));

    -- 3. Automorphism-based exemptions have no violations.
    -- For irredKb_25, {0,{1,2}} is exempt for topology reasons (connected-sum seam),
    -- not automorphism reasons; exclude it so the automorphism check remains clean.
    allSplts := splitPairs tri;
    exemptSplts := kbExempts#tri;
    autExemptSplts := delete({0,{1,2}}, exemptSplts);
    assert(isExemptionValid(tri, gens, autExemptSplts, allSplts) === {});

    -- 4. Every non-exempt split at an automorphism-covered base is the lex-minimum of its orbit.
    -- Bases absent from the exemption table are excluded (retained for non-automorphism reasons).
    nonExempt := toList(set allSplts - set exemptSplts);
    exemptBases := set apply(exemptSplts, e -> e_0);
    assert(all(select(nonExempt, r -> member(r_0, exemptBases)), r -> (
        fr := {r_0} | r_1;
        all(grp, g -> not lexLt({(applyPermutationToSplit(g,r))_0} | (applyPermutationToSplit(g,r))_1, fr))
    )));

    print("automorphisms-kb: PASSED for " | toString tri);
);

print "ALL automorphisms-kb TESTS PASSED"
