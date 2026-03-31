-- Returns a random n×n matrix over QQ whose k-th exterior power has non-zero determinant,
-- guaranteeing the compound matrix constructed from it has full rank generically.
-- Resamples until the condition is met (terminates almost surely).
randomMatrix = (n,k) -> (
    detValue := 0;
    while detValue == 0 do (
	Mat := random(QQ^n,QQ^n);
	detValue = det exteriorPower(k,Mat);
	if detValue != 0 then break Mat;
	)
);

doc ///
  Key
    randomMatrix
  Headline
    generate a random matrix whose k-th exterior power is non-singular
  Usage
    randomMatrix(n, k)
  Example
    randomMatrix(4, 2)
///
