function nextWorld = chooseNextWorld(vr)
    trialWindow = 20; %20
    if vr.biasCorrection && (vr.numTrials > trialWindow+1)
        disp('Implementing bias correction.')
%         pWorld = biasCorrectionWorldProbability(vr.correctTrials(end-trialWindow:end), vr.worldTrials(end-trialWindow:end), vr.worldsAvailable, vr.biasCorrectionEps);
%         nextWorld = randsample(vr.worldsAvailable, 1, true, pWorld);
        turnSide = vr.turnSide(vr.turnSide~="T");
        leftTurns = turnSide=="L";
        fracLeft = mean(leftTurns(end-trialWindow:end));
        if rand <= fracLeft
            if vr.nWorlds == 2
                nextWorld = 1;
            elseif vr.nWorlds == 4
                % Choose odd world
                nextWorld = randsample([1 3], 1);
            end
        else
            if vr.nWorlds == 2
                nextWorld = 2;
            elseif vr.nWorlds == 4
                % Choose even world
                nextWorld = randsample([2 4], 1);
            end
        end

    else
        %vr.currentWorld = randi([1 vr.nWorlds]);
        nextWorld = randsample(vr.worldsAvailable, 1, true, vr.worldProbability);
    end

end