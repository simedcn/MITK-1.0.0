function idx = xyz2ijk(p, dn)
% 物理坐标转为索引
% p : 物理坐标，[x,y,z]
% dn : 对应的数据节点
% idx : 对应 dn 的索引

idx = [];
if ~isa(dn, 'DataNode')
	return;
end
idx = round((p - dn.Origin) ./ dn.Spacing) + 1;
% if (idx >= 1) & (idx <= dn.Size)
% 	
% else
% 	idx = [];
% end

end