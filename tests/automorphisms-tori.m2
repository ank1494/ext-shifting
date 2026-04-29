load "libs.m2";
irredTori := value get "data/surface triangulations/irredTori.m2";
toriExempts := value get "data/surface triangulations/toriExemptSplits.m2";
toriAuts := value get "data/surface triangulations/toriAutomorphisms.m2";

splitPairs = tri -> toList apply(nonTrivialVertexSplits tri, s -> {(s_1)#base, (s_1)#neighbors});

-- Lex less-than on equal-length integer lists.
lexLt = (a, b) -> (
    pos := select(0..#a-1, i -> a_i != b_i);
    if #pos == 0 then false else a_(pos_0) < b_(pos_0)
);

expectedOrders := hashTable {
    irredTori_0 => 42,
    irredTori_1 => 32,
    irredTori_2 => 4,
    irredTori_3 => 6,
    irredTori_4 => 4
};

for tri in {irredTori_0, irredTori_1, irredTori_2, irredTori_3, irredTori_4} do (
    gens := toriAuts#tri;
    grp := groupClosure gens;

    -- 1. Correct group order
    assert(#grp == expectedOrders#tri);

    -- 2. Every group element is an automorphism
    assert(all(grp, g -> isAutomorphism(g, tri)));

    -- 3. Exemption table has no violations
    allSplts := splitPairs tri;
    exemptSplts := toriExempts#tri;
    assert(isExemptionValid(tri, gens, exemptSplts, allSplts) === {});

    -- 4. Every non-exempt split at an automorphism-covered base is the lex-minimum of its orbit.
    -- Bases absent from the exemption table (e.g. retained for degree/topology reasons, not
    -- automorphism reasons) are excluded from this check.
    nonExempt := toList(set allSplts - set exemptSplts);
    exemptBases := set apply(exemptSplts, e -> e_0);
    assert(all(select(nonExempt, r -> member(r_0, exemptBases)), r -> (
        fr := {r_0} | r_1;
        all(grp, g -> not lexLt({(applyPermutationToSplit(g,r))_0} | (applyPermutationToSplit(g,r))_1, fr))
    )));

    print("automorphisms-tori: PASSED for " | toString tri);
);

print "ALL automorphisms-tori TESTS PASSED"
