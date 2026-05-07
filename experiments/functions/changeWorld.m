function vr = changeWorld(vr)
    if vr.currentWorld == 1
        vr.currentWorld = 2;
    elseif vr.currentWorld == 2
        vr.currentWorld = 1;
    else
        disp('Warning: maze not configured for more than 2 worlds.')
    end
    vr.worlds{vr.currentWorld}.surface.visible(:) = 1;
    vr.worlds{vr.currentWorld}.backgroundColor = [vr.backgroundR_val vr.backgroundG_val vr.backgroundB_val];
    disp('Changed world.');
end
