function code = linearTrack200vu_2cuesInterleavedPopup_rewardBlock20after100Trials
% linearTrackNew   Code for the ViRMEn experiment linearTrackNew.
%   code = linearTrackNew   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT


%% MAZE DESCRIPTION
% Infinite linear maze (loops back on itself) with 4 wall cues and
% associated landmarks.

% --- INITIALIZATION code: executes before the ViRMEn engine starts.
function vr = initializationCodeFun(vr)

    % wrap world
    vr.mazeLength = eval(vr.exper.variables.mazewidth);
    vr = wrapLinearWorlds(vr);
%     vr = wrapLinearWorld(vr, 1, 1);
%     vr = wrapLinearWorld(vr, 2, 1);
    
    % Initialize VR
    vr.debugMode = false;
    vr.ops = getRigInfo();
    vr = makeVirmenDir(vr);
    vr = initLinearTrack(vr);
    vr = initDAQ(vr);
    vr = initLivePlots_linearMaze(vr);
    
    % Initialize maze
    vr.CueRevealPosition = 80;
    vr.CueEndPosition = 120;
    vr.currentWorld = 1;
    vr.isRewardTrial = 0;
    vr.probAutomaticReward = 1;
    vr.numRewardsPerTrial = 1;
    vr.rewardProbability = 1;
    vr.worldProbability = [0.2 0.4 0.4];
    vr.cueHasAppeared = 0;
    
    firstBlockSize = 100;
    blockSize = 20;
    rewardedWorldBlockSet = [-1 2 -1 3];
    blockSetSize = length(rewardedWorldBlockSet);
    blockSetReps = 25; % >1000 trials so will not go over
    vr.rewardBlockWorlds = [repmat(rewardedWorldBlockSet, 1, blockSetReps)]; % which world is rewarded, not which world is presented
    vr.rewardBlockSizes = [[firstBlockSize] repmat([blockSize], 1, blockSetSize-1) repmat([blockSize], 1, (blockSetReps-1)*blockSetSize)];
    vr.rewardBlockCumSum = cumsum(vr.rewardBlockSizes);
    

%% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
    % Loop maze
    if vr.position(2) > vr.mazeLength
        vr = endLinearTrackTrial(vr);
        vr = initLinearTrackTrial(vr);
        vr = updateLivePlots_linearMaze(vr);
        vr.currentWorld = 1;
        vr.cueHasAppeared = 0;

        % Decide which world is rewarded
        vr.rewardBlockNum = find(vr.rewardBlockCumSum > vr.numTrials, 1, 'first')
        vr.rewardedWorld = vr.rewardBlockWorlds(vr.rewardBlockNum)
    end
    
    vr = outputVirmenTrigger(vr);
    
    

    if (~vr.cueHasAppeared) && (vr.position(2) > vr.CueRevealPosition)
        vr.currentWorld = randsample(vr.worldsAvailable, 1, true, vr.worldProbability);
        disp(vr.currentWorld)
        vr.cueHasAppeared = 1;
        
        if (vr.currentWorld == vr.rewardedWorld)
            vr.isRewardTrial = 1;
            vr.isAutomaticReward = rand <= vr.probAutomaticReward;
            if vr.isAutomaticReward
                disp('Crutch trial')
            else
                disp('Lick for reward trial.')
            end
        else
            vr.isRewardTrial = 0;
        end
        
    end

    if vr.cueHasAppeared && (vr.position(2) > vr.CueEndPosition)
        vr.currentWorld = 1;
    end

        
    vr = collectBehaviorIter_TMaze(vr);
    vr.behaviorData(9,vr.trialIterations) = 0;
    vr = checkForManualReward(vr); % Deliver reward if 'r' key pressed

    vr.behaviorData(9,vr.trialIterations) = 0;
    if vr.isRewardTrial && (abs(vr.position(2)-vr.rewardLocation)<vr.rewardZoneRadius)
        if vr.numRewardsThisTrial < vr.numRewardsPerTrial
            if vr.isAutomaticReward || vr.isLick
                vr = giveRecordProbReward(vr, vr.rewardProbability);
                vr.numRewardsThisTrial = vr.numRewardsThisTrial + 1;
            end
        end
    end

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
vr = clearAnalogChannels(vr);
savefig(vr.performanceFig, fullfile(vr.fullPath, 'performance.fig'));
saveas(vr.performanceFig, fullfile(vr.fullPath, 'performance.pdf'));
vr = writePerformanceToExcel(vr);

if vr.numTrials > 0
    [vr,sessionData] = collectTrialData(vr);
end
printSessionStats_linearMaze(vr)
delete(instrfind);