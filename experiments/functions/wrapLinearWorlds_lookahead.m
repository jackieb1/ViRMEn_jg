function vr = wrapLinearWorlds_lookahead(vr, worldIdx)
% Like wrapLinearWorlds, but each copy can come from a different base world.
% worldIdx: base worlds (from vr.baseWorlds) for [current, +1 ahead, -1 behind, +2 ahead]

yoffset = vr.mazeLength - 5;
yoffsets = [0 yoffset -yoffset yoffset*2];
surface = vr.baseWorlds{worldIdx(1)}.surface;
surface.vertices = zeros(3,0);
surface.triangulation = zeros(3,0,'int32');
surface.visible = false(1,0);
surface.colors = zeros(size(surface.colors,1),0);
for j = 1:4
    orig = vr.baseWorlds{worldIdx(j)}.surface;
    nvert = size(surface.vertices,2);
    surface.vertices = [surface.vertices orig.vertices + [0; yoffsets(j); 0]];
    surface.triangulation = [surface.triangulation orig.triangulation + nvert];
    surface.visible = [surface.visible orig.visible];
    surface.colors = [surface.colors orig.colors];
end
vr.worlds{vr.currentWorld}.surface = surface;
