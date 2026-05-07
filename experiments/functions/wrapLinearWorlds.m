function vr = wrapLinearWorlds(vr)

for k = 1:length(vr.worlds)
    nvert = size(vr.worlds{k}.surface.vertices,2);
    yoffset = vr.mazeLength - 5;
    xyzoffset = [0 yoffset 0; 0 -yoffset 0; 0 yoffset*2 0]';
    orig = vr.worlds{k};
    for j = 1:size(xyzoffset,2)
        offsetmat = repmat(xyzoffset(:,j),1,nvert);
        vr.worlds{k}.surface.vertices =  [vr.worlds{k}.surface.vertices orig.surface.vertices+offsetmat];
        vr.worlds{k}.surface.triangulation = [vr.worlds{k}.surface.triangulation orig.surface.triangulation+(nvert*j)];
        vr.worlds{k}.surface.visible = [vr.worlds{k}.surface.visible orig.surface.visible];
        vr.worlds{k}.surface.colors = [vr.worlds{k}.surface.colors orig.surface.colors];
    end
end