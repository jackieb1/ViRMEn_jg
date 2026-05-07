function nextYPosition = chooseNextYPosition(vr, fractionTrials, yPos)
    % Choose Y position for fraction of next trials
    if rand <= fractionTrials
    	nextYPosition = yPos;
    else
    	nextYPosition = vr.totalMazeLength * 2; % gain change never triggered
    end
end