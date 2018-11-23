function ReArrangeUIStack(dm)

h = findobj('Tag', 'TableDM');
for i = 1:size(h.Data, 1)
	if h.Data{i,3}
		for ii = length(dm.DN):-1:1
			if strcmp(dm.DN(ii).Name, h.Data{i,1})
				for iii = 1:3
					if ~isempty(dm.DN(ii).Fig{iii}) && isvalid(dm.DN(ii).Fig{iii})
						uistack(dm.DN(ii).Fig{iii}, 'bottom');
					end
				end
				break;
			end
		end
	end
end

end