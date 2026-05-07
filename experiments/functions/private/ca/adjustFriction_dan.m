function vr = adjustFriction_dan(vr)

if vr.collision
    vr.dp(1:2) = vr.dp(1:2) * (1-vr.friction);
end