function vr = chooseNextWorld(vr)

if isfield(vr,'blockWorlds')
    worlds = vr.blockWorlds;
else
    worlds = [];
end

if isempty(worlds)
    %Randomly select from all worlds if none specified
    vr.currentWorld = randi(vr.nWorlds);
else
    % If penalty prob is used, replicate current incorrect world in list
    if isfield(vr,'penaltyProb')
       if ~ismember(vr.numTrials, vr.sessionSwitchpoints) && vr.wrongStreak > 0
            worlds(end+1:end+vr.penaltyProb) = vr.currentWorld;
       end  
    end
    
    % Select randomly from worlds list
    worldChoice = randi(length(worlds));
    % make mouse go right!
    vr.currentWorld = worlds(worldChoice);
    %vr.currentWorld = 1;
end