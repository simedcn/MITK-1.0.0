function idx = xyz2ijk(p, dn)
% ��������תΪ����
% p : �������꣬[x,y,z]
% dn : ��Ӧ�����ݽڵ�
% idx : ��Ӧ dn ������

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