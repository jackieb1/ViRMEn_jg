function vr = evaluateStimBlock(vr)
    if vr.isStimBlock
        vr.correctControlTrials = [];
        vr.stimBlockCounter = vr.stimBlockCounter + 1;
        if vr.stimBlockCounter >= vr.stimBlockSize
            vr.isStimBlock = 0;
        end
    else
        vr.stimBlockCounter = 0;
        if length(vr.correctTrials) >= 1
            vr.correctControlTrials(end+1) = vr.correctTrials(end);
            aboveThresholdTrials = length(vr.correctControlTrials) > vr.minControlBlockSize;
            if aboveThresholdTrials
                aboveThresholdAccuracy = mean(vr.correctControlTrials(max(1, end-20):end)) > vr.accuracyThreshold;
                if aboveThresholdAccuracy
                    vr.isStimBlock = 1;
                end
            end
        end
        
    end
    
    if vr.isStimBlock
        disp('stim block')
    else
        disp('control block')
    end


end

