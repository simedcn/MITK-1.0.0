function y = fun2(t, M, Ftemp, Mgrid)

tempgrid = Mgrid + t;
Mtemp = interp2(M, tempgrid(:,:,2), tempgrid(:,:,1), 'linear', 0);
Mmean = mean(Mtemp(:));
Fmean = mean(Ftemp(:));
y1 = sum((Mtemp - Mmean) .* (Ftemp - Fmean), 'all') / ...
	(sqrt(sum((Mtemp - Mmean).^2, 'all')) * ...
	sqrt(sum((Ftemp - Fmean).^2, 'all')) + 1e-10);

y = y1;

end
