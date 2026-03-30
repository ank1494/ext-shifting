randomMatrix = (n,k) -> (
    d := 0; 
    while d == 0 do (
	Mat := random(QQ^n,QQ^n); 
	d = det exteriorPower(k,Mat); 
	if d != 0 then break Mat;
	)
);
