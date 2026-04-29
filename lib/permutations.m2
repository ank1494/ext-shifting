-- Permutation algebra for automorphism verification of simplicial complex exemptions.
-- Permutations are represented as index-based lists: position i holds the image of vertex i.

-- Relabels every vertex in every face by perm; returns a canonically sorted triangulation.
applyPermutation = (perm, complex) -> sort apply(complex, face -> sort apply(face, v -> perm#v));

doc ///
  Key
    applyPermutation
  Headline
    apply an index-based permutation to a simplicial complex
  Usage
    applyPermutation(perm, complex)
  Description
    Example
      applyPermutation({1,0,2}, {{0,1,2},{0,2,3}})
///

TEST ///
  assert(applyPermutation({1,0,2,3}, {{0,1,2},{0,2,3}}) === {{0,1,2},{1,2,3}})
  assert(applyPermutation({0,1,2,3}, {{0,2,3},{0,1,2}}) === {{0,1,2},{0,2,3}})
  assert(applyPermutation({1,2,0}, {{0,1,2}}) === {{0,1,2}})
///

-- Returns true iff applyPermutation(perm, complex) equals the canonical form of complex.
isAutomorphism = (perm, complex) -> (
    applyPermutation(perm, complex) === sort apply(complex, face -> sort face)
);

doc ///
  Key
    isAutomorphism
  Headline
    test whether a permutation is an automorphism of a simplicial complex
  Usage
    isAutomorphism(perm, complex)
  Description
    Example
      isAutomorphism({1,2,0}, {{0,1,2}})
///

TEST ///
  twotri := {{0,1,2},{0,2,3}};
  assert(isAutomorphism({1,2,0}, {{0,1,2}}))
  assert(not isAutomorphism({1,0,2,3}, twotri))
  assert(isAutomorphism({0,1,2,3}, twotri))
///

-- BFS group closure: returns all group elements reachable from generators (always includes identity).
groupClosure = generators -> (
    n := #(generators_0);
    identity := toList(0..n-1);
    compose := (p, q) -> apply(n, i -> p#(q#i));
    grp := set {identity};
    for gen in generators do grp = grp + set {gen};
    changed := true;
    while changed do (
        changed = false;
        for g in toList grp do (
            for gen in generators do (
                gh := compose(g, gen);
                if not member(gh, grp) then (
                    grp = grp + set {gh};
                    changed = true;
                );
            );
        );
    );
    toList grp
);

doc ///
  Key
    groupClosure
  Headline
    compute the full permutation group from a list of generators
  Usage
    groupClosure generators
  Description
    Example
      groupClosure {{1,0,2}}
///

TEST ///
  assert(#groupClosure({{0,1,2}}) == 1)
  grp2 := groupClosure({{1,0,2}});
  assert(#grp2 == 2)
  assert(member({0,1,2}, set grp2))
  assert(#groupClosure({{1,0,2},{0,2,1}}) == 6)
///

-- Maps split {base, {a,b}} to {perm#base, sort {perm#a, perm#b}}.
applyPermutationToSplit = (perm, split) -> (
    {perm#(split_0), sort apply(split_1, v -> perm#v)}
);

doc ///
  Key
    applyPermutationToSplit
  Headline
    apply an index-based permutation to a vertex split
  Usage
    applyPermutationToSplit(perm, split)
  Description
    Example
      applyPermutationToSplit({1,2,0}, {0, {1,2}})
///

TEST ///
  assert(applyPermutationToSplit({1,2,0}, {0, {1,2}}) === {1, {0,2}})
  assert(applyPermutationToSplit({1,0,2,3}, {0, {1,2}}) === {1, {0,2}})
  assert(applyPermutationToSplit({2,1,0}, {1, {0,2}}) === {1, {0,2}})
///

-- Returns exempt splits for which no group element maps them to a non-exempt split (violations).
-- An empty return list confirms the exemption table is valid.
isExemptionValid = (complex, generators, exemptSplits, allSplits) -> (
    grp := groupClosure generators;
    nonExemptSet := set allSplits - set exemptSplits;
    select(exemptSplits, e -> not any(grp, g -> member(applyPermutationToSplit(g, e), nonExemptSet)))
);

doc ///
  Key
    isExemptionValid
  Headline
    verify that every exempt split is orbit-equivalent to some non-exempt representative
  Usage
    isExemptionValid(complex, generators, exemptSplits, allSplits)
  Description
    Example
      isExemptionValid({{0,1,2}}, {{1,2,0}}, {{1,{0,2}},{2,{0,1}}}, {{0,{1,2}},{1,{0,2}},{2,{0,1}}})
///

TEST ///
  gens := {{1,2,0}};
  allSplts := {{0,{1,2}}, {1,{0,2}}, {2,{0,1}}};
  assert(isExemptionValid({{0,1,2}}, gens, {{1,{0,2}},{2,{0,1}}}, allSplts) === {})
  assert(#isExemptionValid({{0,1,2}}, gens, allSplts, allSplts) == 3)
///