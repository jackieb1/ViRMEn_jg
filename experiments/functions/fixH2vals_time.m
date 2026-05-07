function vr = fixH2vals_time(vr)

if vr.fixH
    vr.position(4) = vr.fixHvalues(vr.hChoice);
    t = toc(vr.trialTimer);
    % If done, turn off fix for next iter
    if t >= vr.fixTime
        vr.fixH = 0;
        disp('Fixed H end.');
    end

end