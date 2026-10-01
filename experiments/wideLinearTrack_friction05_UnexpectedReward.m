function code = wideLinearTrack_friction05_UnexpectedReward
% Wide linear track with unexpected (off-tower) rewards.
%   Same maze as wideLinearTrack_friction05, but on a fraction of trials
%   (vr.unexpectedRewardFraction) an extra reward is delivered when the animal's
%   y-position first reaches one of N y-locations, regardless of x. The location is
%   picked with equal probability from vr.unexpectedRewardYLocations. The tower reward
%   is still delivered as usual on those trials. Unexpected rewards are counted in
%   vr.numUnexpectedRewards and do NOT count toward the session-end reward limit.
%   See getUnexpectedRewardParams, drawUnexpectedReward and giveRecordUnexpectedReward.
%
%   behaviorData rows added by this experiment (written every iteration):
%     row 15 : 1 on the iteration an unexpected reward fired, 0 otherwise
%     row 16 : this trial's scheduled unexpected-reward y-location (NaN if none)
%   Do not pass extra channels to collectBehaviorIter_TMaze in this experiment - they
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

    % Unexpected rewards. Set up before the plots: initLickPlot keys off
    % vr.numUnexpectedRewards to decide whether to draw the unexpected-reward line.
    vr = getUnexpectedRewardParams(vr);   % .mat defaults -> dialog -> validation
    vr.numUnexpectedRewards     = 0;
    vr.trialUnexpected          = [];     % per trial: 1 = unexpected-reward trial, 0 = not
    vr.trialUnexpectedYLocation = [];     % per trial: scheduled y-location (NaN if none)
    vr.trialUnexpectedDelivered = [];     % per trial: 1 = unexpected reward fired
    vr = drawUnexpectedReward(vr);        % schedule trial 1

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
    vr.correctRewardProbability = 1;

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
    % Tower (and manual) rewards only - unexpected rewards are not in vr.numRewards.
    if vr.numRewards >= vr.maxNumRewards
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
        vr.trialUnexpected          = [vr.trialUnexpected          vr.thisTrialUnexpected];
        vr.trialUnexpectedYLocation = [vr.trialUnexpectedYLocation vr.thisTrialUnexpectedY];
        vr.trialUnexpectedDelivered = [vr.trialUnexpectedDelivered vr.thisTrialUnexpectedDelivered];
        trialInfo = struct( ...
            'trialNum',                     vr.numTrials, ...
            'isUnexpectedRewardTrial',      vr.thisTrialUnexpected, ...
            'unexpectedRewardYLocation',    vr.thisTrialUnexpectedY, ...
            'unexpectedRewardDelivered',    vr.thisTrialUnexpectedDelivered, ...
            'unexpectedRewardFraction',     vr.unexpectedRewardFraction, ...
            'unexpectedRewardNumLocations', vr.unexpectedRewardNumLocations, ...
            'unexpectedRewardYLocations',   vr.unexpectedRewardYLocations, ...
            'rewardSizeUl',                 vr.unexpectedRewardSizeUl);
        vr = saveTrialData(vr, trialInfo);
        vr = updateLivePlots_wideLinearTrack(vr);
        vr = drawUnexpectedReward(vr);    % schedule the next trial
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

    % Claim rows 15-16 on every iteration so every trial has the same number of rows -
    % collectTrialData concatenates trials inside a bare try, so a short trial would be
    % silently dropped from sessionData rather than erroring.
    vr.behaviorData(15, vr.trialIterations) = 0;
    vr.behaviorData(16, vr.trialIterations) = vr.thisTrialUnexpectedY;

    vr = checkForManualReward(vr); % Deliver reward if 'r' key pressed

    % Unexpected reward: fires once, on the first iteration y reaches the scheduled
    % location (>= so a frame that jumps past the exact value still triggers), any x.
    if vr.thisTrialUnexpected && ~vr.thisTrialUnexpectedDelivered && ...
            vr.position(2) >= vr.thisTrialUnexpectedY
        vr = giveRecordUnexpectedReward(vr);
    end

    vr.distToRewardZone = hypot(vr.position(1)-vr.rewardXLocation, vr.position(2)-vr.rewardYLocation);
    if (vr.distToRewardZone < vr.rewardZoneRadius) && (vr.numRewardsThisTrial < vr.numRewardsPerTrial)
        % Same as giveRecordProbReward, but counts the reward before printing (so the
        % number is 1-based) and labels it as a tower ("correct trials") reward.
        if rand <= vr.correctRewardProbability
            vr.numRewards = vr.numRewards + vr.rewardsPerTrial;
            vr = giveReward(vr, vr.rewardsPerTrial, [], ...
                sprintf('Giving reward number %d - correct trials', vr.numRewards));
            vr.behaviorData(9,vr.trialIterations) = vr.rewardsPerTrial;
        else
            vr.behaviorData(9,vr.trialIterations) = 0;
        end
        vr.numRewardsThisTrial = vr.numRewardsThisTrial + 1;
    end

    vr = updateLickPlot(vr);   % push current ai3 sample + reward markers to the live lick plot

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
    savefig(vr.performanceFig, fullfile(vr.fullPath, 'performance.fig'));
    saveas(vr.performanceFig, fullfile(vr.fullPath, 'performance.pdf'));
    vr = clearAnalogChannels(vr);
    if vr.numTrials > 0
        [vr,sessionData] = collectTrialData(vr);
    end
    printSessionStats_wideLinearTrack(vr);
    printUnexpectedRewardBreakdown(vr);
