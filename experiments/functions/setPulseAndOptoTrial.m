function vr = setPulseAndOptoTrial(vr)
vr.currTrialType = vr.trialType(vr.numTrials+1);
vr.isStimTrial = vr.isStim(vr.numTrials+1);
disp(['Trial: ' num2str(vr.numTrials+1) ', Trial type: ', convertStringsToChars(vr.trialTypeLabels(vr.currTrialType)) ', ' convertStringsToChars(vr.trialStimLabels(vr.isStimTrial+1))]);
if vr.currTrialType == 1
    vr.driftYTrigger = vr.driftYPos;
    pulseDirection = 1;
    vr.driftPulseHeight = vr.driftPulseHeight_const * pulseDirection;
elseif vr.currTrialType == 2
    vr.driftYTrigger = vr.driftYPos;
    pulseDirection = -1;
    vr.driftPulseHeight = vr.driftPulseHeight_const * pulseDirection;
else
    vr.driftYTrigger = vr.mazeLength * 2; % gain change never triggered
end

vr.optoLocation = vr.driftYTrigger; % follows velocity pulse position trigger regardless of trial type
vr.optoTriggered = 0;
end