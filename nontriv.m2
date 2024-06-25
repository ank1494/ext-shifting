checkNontriv = (v,d) -> (nontrivs = {};
     allSimps = LexOrder(v,d);
     for n from 3 to #allSimps - 3 do (
     inds = LexOrder(#allSimps,n);
     --Cmplxs = apply(LexOrder(#allSimps,n), ind -> allSimps_ind);
                    for j from 0 to #inds - 1 do (
			cpx = allSimps_(inds_j);
			if v > #(set flatten cpx) then continue;
     if (n < #partialShift(cpx)) then nontrivs = append(nontrivs, cpx););
     );
     nontrivs)
 
  findBigNontriv = (v,d,n) -> (bignontrivs = {};
     allSimps = LexOrder(v,d);
     inds = LexOrder(#allSimps,n);
     --Cmplxs = apply(LexOrder(#allSimps,n), ind -> allSimps_ind);
                    for j from 0 to #inds - 1 do (
			cpx = allSimps_(inds_j);
			if v > #(set flatten cpx) then continue;
                 pshftd = partialShift(cpx);
     if (n < #pshftd) then (if (#pshftd > #((extShiftLex cpx) + (extShiftRevLex cpx))) then  bignontrivs = append(bignontrivs, cpx);););
     bignontrivs)
    


findFirstBigNontriv = (v,d,n) -> (
    allSimps = LexOrder(v,d);
    inds = LexOrder(#allSimps,n);
    for j from 0 to #inds - 1 do (
	ind = inds_j;
    	cpx = allSimps_ind;
	if v > #(set flatten cpx) then continue;
	pshftd = partialShift(cpx);
	if (n < #pshftd) then (
	    lshft =extShiftLex cpx;
	    rlshft = extShiftRevLex cpx;
	    if (#pshftd > #(lshft + rlshft)) then  (
		print "found complex:";
		print cpx; 
		print "partial shift:";
		print pshftd;
		print "lex shift:";
		print lshft;
		print "revlex shift:";
		print rlshft;
		break;
		);
	    );
	);)
      
    
