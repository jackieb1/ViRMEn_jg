function vr = setWorld(vr, world)
    vr.currentWorld = world;
    vr.position = vr.worlds{world}.startLocation;
    vr.worlds{world}.surface.visible(:) = 1;
    vr.worlds{world}.backgroundColor = [vr.backgroundR_val vr.backgroundG_val vr.backgroundB_val];
end