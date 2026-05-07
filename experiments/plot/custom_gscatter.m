function custom_gscatter(x,y,g,clr,sym,siz)
% gscatter that doesn't ignore unused labels for live lick raster plot
% Assumes that groups are 1:n_groups
hold on
for i_group = 1:max(g)
    scatter(x(g == i_group),y(g == i_group),siz,clr(i_group,:),sym(i_group))
end
end

