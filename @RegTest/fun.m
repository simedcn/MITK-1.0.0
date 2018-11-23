function f = fun(M, F, T)
% M : �ƶ�ͼ��
% F : �̶�ͼ��
% T : �α䳡

Mmean = mean(M(:));
Fmean = mean(F(:));
f1 = sum((M - Mmean) .* (F - Fmean), 'all') / ...
	(sqrt(sum((M - Mmean).^2, 'all')) * sqrt(sum((F - Fmean).^2, 'all')));

f = f1;

end
