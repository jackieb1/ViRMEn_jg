function vr = freeze(vr)

if vr.isFrozen == 1
    t = toc(vr.freezeStartTime);
    vr.dp = 0;

    % If done, turn off freeze for next iter
%     disp(t);
    if t >= vr.freezeDur
        vr.isFrozen = 0;
        vr.froze = 1;
        disp('Freze end.');
    end

else
    % If triggered, turn on heading drift for next iter
    if (vr.position(2) >= vr.freezeYTrigger) && (vr.froze == 0)
        vr.isFrozen = 1;
        vr.freezeStartTime = tic;
        vr.freezeYTrigger = vr.totalMazeLength * 4; % reset y trigger until next trial (reset in chooseNextGainChangeYPosition)
        disp('Freeze start.');
    end

end

end