function vr = aoEnable(vr, tf)
    assignin('base','vr',vr);              % <-- make sure callback sees the new flag
    if tf
        % --- Enable: (re)arm for the next rising edge ---
        try
            if vr.task.IsDone
                pause(0);
                if vr.task.IsDone, vr.task.Start(); end          % arm for next trigger
            end
        catch ME
            warning('aoEnable(enable): %s', ME.message);
            vr.experimentEnded = true;
        end

    else
        % --- Disable: cancel and hold baseline ---
        try
            t0 = tic;
%             while ~vr.task.IsDone && toc(t0) < 0.2 % no pause
%                 pause(0);
%             end
            vr.task.Stop();               % disarm immediately
        catch ME
            warning('aoEnable(enable): %s', ME.message);
            vr.experimentEnded = true;
        end
    end
end