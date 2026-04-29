-- Automorphism group generators for the irreducible Klein bottles with non-trivial automorphism groups.
-- Covers irredKb_0 through irredKb_4 and irredKb_25.
-- irredKb_5 has a trivial automorphism group and is absent from this table.
-- Permutations are in index-based list form: position i holds the image of vertex i.
-- Cycle-notation comments above each generator are for human readability.
-- Non-generating group elements are omitted; groupClosure computes the full group at runtime.

irredKb := value get "data/surface triangulations/irredKb.m2";
new HashTable from {

    -- irredKb_0: 8-vertex Klein bottle. Automorphism group order 2.
    irredKb_0 => {
        -- (0 6)(1 5)(2 3)(4 7)
        {6,5,3,2,7,1,0,4}
    },

    -- irredKb_1: 8-vertex Klein bottle. Automorphism group order 2.
    irredKb_1 => {
        -- (0 2)(3 6)(4 7)
        {2,1,0,6,7,5,3,4}
    },

    -- irredKb_2: 8-vertex Klein bottle. Automorphism group order 8.
    irredKb_2 => {
        -- (2 7)(3 4)
        {0,1,7,4,3,5,6,2},
        -- (0 1)(3 4)(5 6)
        {1,0,2,4,3,6,5,7},
        -- (0 5)(1 6)(2 3 7 4)
        {5,6,3,7,2,0,1,4}
    },

    -- irredKb_3: 8-vertex Klein bottle. Automorphism group order 2.
    irredKb_3 => {
        -- (1 2)(4 6)(5 7)
        {0,2,1,3,6,7,4,5}
    },

    -- irredKb_4: 8-vertex Klein bottle. Automorphism group order 2.
    irredKb_4 => {
        -- (0 1)(3 7)(4 5)
        {1,0,2,7,5,4,6,3}
    },

    -- irredKb_25: 10-vertex Klein bottle. Automorphism group order 6.
    irredKb_25 => {
        -- (0 1 2)(3 5 6)(4 7 8)
        {1,2,0,5,7,6,3,8,4,9},
        -- (3 4)(5 7)(6 8)
        {0,1,2,4,3,7,8,5,6,9}
    }

}
