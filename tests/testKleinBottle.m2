-- Test: iterative analysis on a random irreducible Klein bottle triangulation never exceeds 12 vertices.
-- Performs a sampled walk of up to 10 steps from a random seed triangulation.
-- N = 12 confirmed by prior manual runs.
-- Run from m2/ext-shifting/ in an M2 terminal:
--   load "tests/testKleinBottle.m2"
load "libs.m2";

irredKb := value get "data/surface triangulations/irredKb.m2";
current := irredKb_(random(#irredKb));

for i from 0 to 9 do (
    result := analyzeIteration({current});
    largest := result#2;
    splits := result#1;
    assert(largest <= 12);
    if #splits == 0 then break;
    current = splits_(random(#splits));
);

print "testKleinBottle: PASSED"
