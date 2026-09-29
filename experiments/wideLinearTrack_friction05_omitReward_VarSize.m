function code = wideLinearTrack_friction05_omitReward_VarSize
% Wide linear track with reward omission and variable reward size.
%   Same maze as wideLinearTrack_friction05, but on each trial where the animal
%   reaches the reward tower the reward is either omitted (with probability
%   vr.rewardOmissionFraction) or delivered at one of three sizes drawn with the
%   probabilities set in the startup dialog. See getVarRewardParams and
%   giveRecordVarReward.
%
%   NOTE: behaviorData row 15 carries the per-iteration reward size in ul. Do not
%   pass extra channels to collectBehaviorIter_TMaze in this experiment - they
%   would land in row 15 and collide.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT

% --- INITIALIZATION code: executes before the ViRMEn engine starts.
function vr = initializationCodeFun(vr)

    % Initialize VR
    vr.debugMode = false;
    vr.ops = getRigInfo();
    vr = makeVirmenDir(vr);

    % Reward omission / variable size. Set up before the plots: initLickPlot keys off
    % vr.numOmissions to decide whether to draw the omission line and name it in the
    % title, and this also puts both startup dialogs before the hardware spins up.
    vr = getVarRewardParams(vr);      % .mat defaults -> dialog -> validation
    vr.totalRewardVolume = 0;         % ul actually delivered this session
    vr.numOmissions      = 0;
    vr.trialRewardSize    = [];       % per trial: ul delivered (0 = omission, NaN = tower not reached)
    vr.trialRewardOmitted = [];       % per trial: 1 = omitted, 0 = rewarded, NaN = not reached
    vr.thisTrialRewardSize    = NaN;
    vr.thisTrialRewardOmitted = NaN;
    if ~isfield(vr,'maxRewardVolume') || isempty(vr.maxRewardVolume)
        vr.maxRewardVolume = str2double(vr.ops.defaultMaxRewardVolume);  % debugMode fallback
    end

    vr = initDAQ(vr);
    vr = initLickPlot(vr);           % live ai3 lick + reward-timing plot (must be after initDAQ)
    vr = initLivePlots_wideLinearTrack(vr);

    % Initialize maze
    vr = initLinearTrack(vr);
    vr.rewardXLocation = eval(vr.exper.variables.towerXLocation);
    vr.rewardYLocation = eval(vr.exper.variables.towerYLocation);
    vr.rewardZoneRadius = 3;
    vr.teleportYLocation = vr.rewardYLocation + 5;
    vr.startYLocation = 2;
    vr.wallPatternRepetitionLength = eval(vr.exper.variables.wallPatternRepetitionLength);
    vr.correctTrials = [];
    vr.previousVelocity = [0 0 0 0];
    vr.frictionDecay = 0.05;
    vr.dpGain = 1;
    vr.sideOffset = 0;

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
    % Volume-based stop: with sizes varying, a reward count no longer maps to a volume.
    if vr.totalRewardVolume >= vr.maxRewardVolume
        vr.experimentEnded = true;
    end

    % Loop maze
    if vr.position(2) > vr.teleportYLocation
        vr.trialEnded = 1;
        vr.numTrials = vr.numTrials + 1;
        vr.position(2) = mod(vr.position(2), vr.wallPatternRepetitionLength);
        vr.trialTimeTrials = [vr.trialTimeTrials toc(vr.trialTimer)];
        vr.trialTimer = tic;
        vr.correctTrials = [vr.correctTrials vr.numRewardsThisTrial];
        vr.numRewardsThisTrial = 0;
        vr.trialRewardSize    = [vr.trialRewardSize    vr.thisTrialRewardSize];
        vr.trialRewardOmitted = [vr.trialRewardOmitted vr.thisTrialRewardOmitted];
        vr.thisTrialRewardSize    = NaN;
        vr.thisTrialRewardOmitted = NaN;
        vr = saveTrialData(vr);
        vr = updateLivePlots_wideLinearTrack(vr);
    end


    if vr.collision
        vr.dpGain = vr.dpGain * (1-vr.frictionDecay);
    else
        vr.dpGain = vr.dpGain * (1+vr.frictionDecay);
    end
    vr.dpGain = min(vr.dpGain, 1); % cap at 1
    vr.dpGain = max(vr.dpGain, 0.01); % cap at 1
    vr.dp(2) = vr.dp(2) * vr.dpGain;

    vr = outputVirmenTrigger(vr);

    vr = collectBehaviorIter_TMaze(vr);

    % Claim row 15 on every iteration. giveRecordVarReward fills it in when a reward is
    % delivered or omitted, but a trial where the animal never reaches the tower would
    % otherwise stay 14 rows - and collectTrialData concatenates trials inside a bare
    % try, so a short trial is silently dropped from sessionData rather than erroring.
    vr.behaviorData(15, vr.trialIterations) = NaN;

    % Deliver reward if 'r' key pressed. checkForManualReward is shared and does not
    % know about the volume cap, so count its rewards here.
    nRewBefore = vr.numRewards;
    vr = checkForManualReward(vr);
    if vr.numRewards > nRewBefore
        vr.totalRewardVolume = vr.totalRewardVolume + ...
            (vr.numRewards - nRewBefore) * vr.manualRewardSizeUl;
    end

    vr.distToRewardZone = hypot(vr.position(1)-vr.rewardXLocation, vr.position(2)-vr.rewardYLocation);
    if (vr.distToRewardZone < vr.rewardZoneRadius) && (vr.numRewardsThisTrial < vr.numRewardsPerTrial)
        vr = giveRecordVarReward(vr);
        % Incremented whether or not the reward was omitted, so vr.correctTrials keeps
        % meaning "reached the tower" - an omission trial is still a correct trial.
        vr.numRewardsThisTrial = vr.numRewardsThisTrial + 1;
    end

    vr = updateLickPlot(vr);   % push current ai3 sample + reward/omission markers

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
    savefig(vr.performanceFig, fullfile(vr.fullPath, 'performance.fig'));
    saveas(vr.performanceFig, fullfile(vr.fullPath, 'performance.pdf'));
    vr = clearAnalogChannels(vr);
    if vr.numTrials > 0
        [vr,sessionData] = collectTrialData(vr);
    end
    printSessionStats_wideLinearTrack(vr);
    printRewardBreakdown(vr);

