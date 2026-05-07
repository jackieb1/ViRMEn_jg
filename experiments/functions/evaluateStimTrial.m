function vr = evaluateStimTrial(vr)
    
    if rand <= vr.stimTrialProbability
        vr.isStimTrial = 1;
        disp('stim trial')
    else
        vr.isStimTrial = 0;
    end


end

