load "libs.m2";

T := {{1,3,4},{1,2,4},{2,4,5},{2,3,5},{3,5,6},{3,4,6},{0,4,5},{0,1,5},{1,2,6},{1,5,6},{0,2,6},{0,4,6},{0,1,7},{1,3,7},{2,3,7},{0,2,7}};

-- Step 1: final edge of the original complex
finalE := finalEdgeOfShift getEdges T;
print("finalEdge of T: " | toString finalE);

-- Step 2: all non-trivial vertex splits
splits := nonTrivSplits T;
print("number of non-trivial splits: " | toString(#splits));

-- Step 3: for each split, check if it preserves the final edge (both random trials)
splitsWithShiftData := {};
for i from 0 to #splits - 1 do (
    shift1 := extShiftLex getEdges splits_i_0;
    shift2 := extShiftLex getEdges splits_i_0;
    preserves := (finalE == shift1_-1) and (finalE == shift2_-1);
    data := {splits_i_1, preserves, splits_i_0};
    splitsWithShiftData = append(splitsWithShiftData, data);
    print("split " | toString i | ": base=" | toString(splits_i_1_SPLITBASE)
        | " neighbors=" | toString(splits_i_1_SPLITNEIGHBORS)
        | " preservesFinalEdge=" | toString preserves);
);

-- Step 4: which vertices are critical?
vertices := getVertices T;
critVertices := set {};
for i from 0 to #vertices - 1 do (
    v := vertices_i;
    splitsFromV := select(splitsWithShiftData, d -> d_0_SPLITBASE == v);
    allPreserve := all(splitsFromV, s -> s_1);
    print("vertex " | toString v | ": " | toString(#splitsFromV)
        | " splits, allPreserveFinalEdge=" | toString allPreserve);
    if allPreserve then critVertices = critVertices + set {v};
);
print("critVertices: " | toString critVertices);
print("all vertices critical? " | toString(#critVertices == #vertices));
