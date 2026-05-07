function vr = adjustFriction(vr)

if vr.collision
    if length(vr.dp) > 1
        % Adjust friction based on how much velocity is being projected
        % onto the wall
        proj_coef = mean(vr.dp(1:2) / (vr.velocity(1:2)*vr.dt));
        friction = vr.friction*(1-proj_coef);
    
        vr.dp(1:2) = vr.dp(1:2) * (1-friction);
    end
end