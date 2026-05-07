function vr = multi_freeze(vr)

% Check if currently frozen
if vr.isFrozen
    vr.dp = 0;
    if toc(vr.freezeTimer) >= vr.freezeDur
        vr.isFrozen = 0;
    end
    return
end

% Check if we've crossed a new landmark
landmarkHit = find(vr.position(2) >= vr.freezeYPos & ~vr.freezeChecked, 1);

if ~isempty(landmarkHit)
    vr.freezeChecked(landmarkHit) = true;
    if rand < vr.freezeProb
        vr.isFrozen = 1;
        vr.freezeTimer = tic;
        vr.dp = 0;
    end
end