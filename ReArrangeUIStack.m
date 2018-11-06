function ReArrangeUIStack(dm)

h = findobj('Tag', 'TableDM');
for i = 1:size(h.Data, 1)
	if h.Data{i,3}
		for ii = length(dm.DN):-1:1
			if strcmp(dm.DN(ii).Name, h.Data{i,1})
				uistack(dm.DN(ii).Fig{1}, 'bottom');
				uistack(dm.DN(ii).Fig{2}, 'bottom');
				uistack(dm.DN(ii).Fig{3}, 'bottom');
				break;
			end
		end
	end
end

end