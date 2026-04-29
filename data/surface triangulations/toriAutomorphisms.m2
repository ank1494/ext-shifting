-- Automorphism group generators for the irreducible tori with non-trivial automorphism groups.
-- Covers irredTori_0 through irredTori_4.
-- Permutations are in index-based list form: position i holds the image of vertex i.
-- Cycle-notation comments above each generator are for human readability.
-- Non-generating group elements are omitted; groupClosure computes the full group at runtime.

irredTori := value get "data/surface triangulations/irredTori.m2";
new HashTable from {

    -- irredTori_0: 7-vertex minimal torus. Automorphism group order 42.
    irredTori_0 => {
        -- (0 1 6 3 2 4)
        {1,6,4,2,0,5,3},
        -- (0 2 1 5 3 4)
        {2,5,1,4,0,3,6}
    },

    -- irredTori_1: 8-vertex torus. Automorphism group order 32.
    irredTori_1 => {
        -- (2 4)(3 6)
        {0,1,4,6,2,5,3,7},
        -- (1 7)(2 3)(4 6)
        {0,7,3,2,6,5,4,1},
        -- (0 2 7 6 5 4 1 3)
        {2,3,7,0,1,4,5,6}
    },

    -- irredTori_2: 8-vertex torus. Automorphism group order 4 (Klein four-group).
    irredTori_2 => {
        -- (1 3)(2 6)
        {0,3,6,1,4,5,2,7},
        -- (0 5)(1 3)(4 7)
        {5,3,2,1,7,0,6,4}
    },

    -- irredTori_3: 8-vertex torus. Automorphism group order 6.
    irredTori_3 => {
        -- (0 5)(1 4)(3 6)
        {5,4,2,6,1,0,3,7},
        -- (0 7 5)(1 2 4)
        {7,2,4,3,1,0,6,5}
    },

    -- irredTori_4: 8-vertex torus. Automorphism group order 4 (Klein four-group).
    irredTori_4 => {
        -- (1 3)(2 4)
        {0,3,4,1,2,5,6,7},
        -- (1 2)(3 4)(5 7)
        {0,2,1,4,3,7,6,5}
    }

}
