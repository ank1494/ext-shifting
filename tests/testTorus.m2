-- Test: iterative analysis on a random irreducible torus triangulation never exceeds 10 vertices.
-- Performs a sampled walk of up to 10 steps from a random seed triangulation.
-- N = 10 confirmed by prior manual runs.
-- Run from m2/ext-shifting/ in an M2 terminal:
--   load "tests/testTorus.m2"
load "libs.m2";

irredTori := value get "data/surface triangulations/irredTori.m2";
current := irredTori_(random(#irredTori));

for i from 0 to 9 do (
    result := analyzeIteration({current});
    largest := result#2;
    splits := result#1;
    assert(largest <= 10);
    if #splits == 0 then break;
    current = splits_(random(#splits));
);

print "testTorus: PASSED"
