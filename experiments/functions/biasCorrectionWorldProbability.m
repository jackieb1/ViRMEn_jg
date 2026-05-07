function pWorld = biasCorrectionWorldProbability(correctTrials, worldTrials, availableWorlds, eps)
    pCorrect = zeros(1, length(availableWorlds));
    for i = 1:length(availableWorlds)
        world = availableWorlds(i);
        worldIdx = worldTrials == world; 
        if sum(worldIdx) == 0
            pCorrect(i) = 0.5;
        else
            correct_worldi = correctTrials(worldTrials == world);
            pCorrect(i) = mean(correct_worldi);
        end
    end
    
    pWorld = 1 + (1 - pCorrect);
    pWorld = pWorld - min(pWorld) + eps;
    pWorld = pWorld / sum(pWorld);