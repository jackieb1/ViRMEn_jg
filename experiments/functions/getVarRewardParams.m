function vr = getVarRewardParams(vr)
%getVarRewardParams  Session parameters for the omission / variable-size reward task.
%   vr = getVarRewardParams(vr) takes default values from the experiment's ViRMEn
%   variable table (when they are defined there), offers them in a dialog, validates
%   what comes back against this rig's reward calibration, and stores the result on vr.
%
%   Call ONCE in initializationCodeFun, AFTER makeVirmenDir (which sets vr.rewardSize)
%   and initLinearTrack.
%
%   Experiment variables read (all optional):
%     rewardOmissionFraction, rewardSizes, rewardSizeProbs
%
%   Sets on vr:
%     rewardOmissionFraction  probability that a correct trial is left unrewarded
%     rewardSizeKeys          1x3 cellstr, keys into ops.rewardPulseDurationDict
%     rewardSizeValues        1x3 double, the same three sizes in ul
%     rewardSizeProbs         1x3 double, probability of each size given a reward
%     rewardSizeDurations     1x3 double, calibrated valve-open time (s) per size
%     manualRewardSizeUl      ul assumed for 'r'-key manual rewards
%     rewardParams            struct archived into sessionData.mat

    % Per-trial size switching relies on giveReward re-reading the calibration map on
    % every call. The legacy DAQ path instead uses a single ops.rewardPulseDuration
    % fixed at init, so sizes cannot vary there.
    if ~vr.ops.useTeensyReward
        error(['This experiment requires the Teensy reward path (ops.useTeensyReward = true). ' ...
               'The DAQ path cannot vary reward size within a session.']);
    end

    % ---- defaults: experiment variables when defined, else built-ins ----
    defOmission = '0.3';
    defSizes    = '[2 4 7]';
    defProbs    = '[0.25 0.5 0.25]';
    try, defOmission = num2str(eval(vr.exper.variables.rewardOmissionFraction)); catch, end
    try, defSizes    = mat2str(eval(vr.exper.variables.rewardSizes));            catch, end
    try, defProbs    = mat2str(eval(vr.exper.variables.rewardSizeProbs));        catch, end

    % ---- prompt ----
    prompt   = {'Reward omission fraction (0-1)', ...
                'Reward sizes (ul, 3 values)', ...
                'Probability of each size (3 values, sum to 1)'};
    dlgtitle = 'Reward Omission / Size Parameters';
    dims     = [1 40];
    answer   = inputdlg(prompt, dlgtitle, dims, {defOmission, defSizes, defProbs});
    if isempty(answer)
        error('Session cancelled at the reward-parameter dialog.');
    end

    % ---- omission fraction ----
    omission = str2double(answer{1});
    if isnan(omission) || omission < 0 || omission > 1
        error('Reward omission fraction "%s" is not a number in [0 1].', answer{1});
    end

    % ---- reward sizes ----
    % Keep the typed spelling as the calibration-map key ('4' must stay '4'); the
    % numeric value is only used for volume bookkeeping and reporting.
    sizeKeys = regexp(answer{2}, '\d+\.?\d*', 'match');
    if numel(sizeKeys) ~= 3
        error('Expected exactly 3 reward sizes, got %d from "%s".', numel(sizeKeys), answer{2});
    end
    allKeys    = keys(vr.ops.rewardPulseDurationDict);
    validSizes = allKeys(~isnan(cellfun(@str2double, allKeys))); % numeric keys only (excludes 'flush')
    for k = 1:3
        if ~ismember(sizeKeys{k}, validSizes)
            error(['Reward size "%s" is not calibrated on this rig. Calibrated sizes: %s. ' ...
                   'To use another size, calibrate it and add a rewardPulseDurationDict key in getRigInfo.m.'], ...
                  sizeKeys{k}, strjoin(validSizes, ', '));
        end
    end
    sizeValues    = cellfun(@str2double, sizeKeys);
    sizeDurations = cellfun(@(k) vr.ops.rewardPulseDurationDict(k), sizeKeys);

    % ---- size probabilities ----
    probs = str2num(answer{3}); %#ok<ST2NM> - accepts '[.25 .5 .25]' and '.25 .5 .25'
    if numel(probs) ~= 3
        error('Expected exactly 3 size probabilities, got %d from "%s".', numel(probs), answer{3});
    end
    if any(~isfinite(probs)) || any(probs < 0)
        error('Size probabilities must all be finite and non-negative: "%s".', answer{3});
    end
    if abs(sum(probs) - 1) > 1e-6
        error('Size probabilities must sum to 1 (they sum to %g): "%s".', sum(probs), answer{3});
    end
    probs = probs(:).';

    % ---- seed the generator so the draw sequence is reconstructable ----
    rngSeed = uint32(mod(floor(now*86400), 2^32-1));
    rng(rngSeed, 'twister');

    % ---- store ----
    vr.rewardOmissionFraction = omission;
    vr.rewardSizeKeys         = sizeKeys;
    vr.rewardSizeValues       = sizeValues;
    vr.rewardSizeProbs        = probs;
    vr.rewardSizeDurations    = sizeDurations;
    % Manual ('r' key) rewards use whatever vr.rewardSize holds, which
    % giveRecordVarReward restores to the session-dialog value after every draw.
    vr.manualRewardSizeUl     = str2double(vr.rewardSize);

    vr.rewardParams = struct( ...
        'omissionFraction',  omission, ...
        'sizesUl',           sizeValues, ...
        'sizeProbs',         probs, ...
        'sizeDurationsSec',  sizeDurations, ...
        'rngSeed',           rngSeed, ...
        'rngGenerator',      'twister');

    % ---- echo, so the session log records what was actually used ----
    fprintf('\nReward parameters for this session:\n');
    fprintf('  Omission fraction : %g\n', omission);
    for k = 1:3
        fprintf('  %g ul  p = %g  (valve %g ms)\n', ...
            sizeValues(k), probs(k), round(sizeDurations(k)*1000));
    end
    fprintf('  Expected mean per correct trial: %g ul\n', (1-omission)*sum(sizeValues.*probs));
    fprintf('  RNG seed (twister): %u\n\n', rngSeed);
end
