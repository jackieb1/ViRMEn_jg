function vr = constructPulseOptoTrialSequence(vr, n_trialsPerProbeBlock, n_trialsPerStimBlock, n_probeBlocks)
% Trial structure generator
% forward=1, backward=2, control=3
% probe=0, stim=1

rng('shuffle');
vr.trialType = [];   % sequence of 1/2/3
vr.isStim    = [];   % parallel sequence of 0/1

for k = 1:n_probeBlocks
    % Probe block i.e. 2 of each type, insert a control after each forward -> 8 trials
    tt_probe = makeBlock(n_trialsPerProbeBlock);
    vr.trialType = [vr.trialType, tt_probe];
    vr.isStim    = [vr.isStim, zeros(1, numel(tt_probe))];

    if k < n_probeBlocks
        % Stim block i.e. 9 of each type, insert a control after each forward -> 36 trials
        tt_stim = makeBlock(n_trialsPerStimBlock);
        stim_block = ones(1, numel(tt_stim));
        stim_block(tt_stim == 3) = 0;  % control trials always 0
        vr.trialType = [vr.trialType, tt_stim];
        vr.isStim = [vr.isStim, stim_block];
    end
end