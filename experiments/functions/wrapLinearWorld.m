function vr = wrapLinearWorld(vr, world_id, world_id_to_wrap)

world_to_wrap = vr.worlds{world_id_to_wrap};

nvert = size(vr.worlds{world_id_to_wrap}.surface.vertices,2);
xyzoffset = [0 vr.mazeLength 0; 0 -vr.mazeLength 0; 0 vr.mazeLength*2 0]';
    
for j = 1:size(xyzoffset,2)
    offsetmat = repmat(xyzoffset(:,j),1,nvert);
    vr.worlds{world_id}.surface.vertices =  [vr.worlds{world_id}.surface.vertices world_to_wrap.surface.vertices+offsetmat];
    vr.worlds{world_id}.surface.triangulation = [vr.worlds{world_id}.surface.triangulation world_to_wrap.surface.triangulation+(nvert*j)];
    vr.worlds{world_id}.surface.visible = [vr.worlds{world_id}.surface.visible world_to_wrap.surface.visible];
    vr.worlds{world_id}.surface.colors = [vr.worlds{world_id}.surface.colors world_to_wrap.surface.colors];
end