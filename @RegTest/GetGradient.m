function gk = GetGradient(T)

s = size(T);
x = T(:);
for i = 1:length(x)
	T1 = x; T2 = x;
	T1(i) = T1(i) + 1;
	T2(i) = T2(i) + 1;
	T1 = reshape(T1, s);
	T2 = reshape(T2, s);
	
end


end
