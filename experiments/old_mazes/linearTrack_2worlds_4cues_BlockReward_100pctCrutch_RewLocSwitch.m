function code = linearTrack_2worlds_4cues_BlockReward_100pctCrutch_RewLocSwitch
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
%     vr = wrapLinearWorlds(vr);
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
    vr.rewardLocation = 150;
    vr.rewardZoneRadius = 30;
    vr.rewardedWorld = 0; % set to 0 so switch to 1 in first rewarded block
    vr.probAutomaticReward = 1; % 0.2
    vr.isAutomaticReward = 0;
    vr.numRewardsThisTrial = 0;
    vr.numRewardsPerTrial = 1;
    vr.rewardProbability = 1;
    vr.isRewardTrial = 0;
    vr.firstRewardedTrial = 50;
    vr.rewardsPerTrial = 1; % rewards per reward trigger
    vr.rewardBlock = 0;
    vr.rewardBlockSize = 20;
    
    vr.currentWorld = 1;
    vr.worldProbability = [0.5 0.5]; %[0.2 0.4 0.4]
    vr.dispTrialInfo = false;
    
    

%% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
    % Loop maze
    if isTrialStart(vr)
        vr.nextWorld = randsample(vr.worldsAvailable, 1, true, vr.worldProbability);
        vr = setWorld(vr, vr.nextWorld);
        vr = initLinearTrackTrial_hk(vr);
        vr = updateLivePlots_linearMaze(vr);
        vr.isRewardTrial = 0;
        vr.isAutomaticReward = 0;
        vr.inITI = 0;
        vr.dispTrialInfo = false;
    end
    
    vr = outputVirmenTrigger(vr);
    
    if vr.dispTrialInfo == false % only run at beginning of trial
        disp(['Trial ' num2str(vr.numTrials)])
        if (vr.numTrials >= vr.firstRewardedTrial) % first n trials not rewarded
            if mod(vr.numTrials-vr.firstRewardedTrial, vr.rewardBlockSize) == 0 % switch to rewarded block every m trials
                if vr.rewardBlock == 1 % switch to unrewarded if just rewarded
                    vr.rewardBlock = 0;
                    vr.isRewardedTrial = 0;
                    disp('Unrewarded Block')
                else
                    vr.rewardBlock = 1;
                    if vr.rewardedWorld == 1 % switch rewarded world if back to rewarded block
                        vr.rewardedWorld = 2;
                    else
                        vr.rewardedWorld = 1;
                    end
                    disp(['Rewarded Block: World ' num2str(vr.rewardedWorld)])
                end
            end
            disp(['World ' num2str(vr.currentWorld)])
            if vr.rewardBlock == 1
                if vr.currentWorld == vr.rewardedWorld % set rewarded trial if rewarded world in rewarded block
                    vr.isRewardTrial = 1;
                else
                    vr.isRewardTrial = 0;
                end
                if vr.isRewardTrial == 1 % set automatic vs lick for reward if rewarded trial
                    vr.isAutomaticReward = rand <= vr.probAutomaticReward;
                    if vr.isAutomaticReward
                        disp('Crutch trial')
                    else
                        disp('Lick for reward trial')
                    end
                end
            end
        else
            disp(['World ' num2str(vr.currentWorld)])
        end
        vr.dispTrialInfo = true;
    end
        
    vr = collectBehaviorIter_TMaze(vr, vr.isAutomaticReward);
    vr = checkForManualReward(vr); % Deliver reward if 'r' key pressed
    
    vr.behaviorData(9,vr.trialIterations) = 0;
    if vr.isRewardTrial && (abs(vr.position(2)-vr.rewardLocation)<vr.rewardZoneRadius)
        if vr.numRewardsThisTrial < vr.numRewardsPerTrial
            if vr.isAutomaticReward || vr.isLick
%                 disp('Giving reward')
                vr = giveRecordProbReward(vr, vr.rewardProbability);
                vr.numRewardsThisTrial = vr.numRewardsThisTrial + 1;
            end
        end
    end

    vr = checkforTrialEndPosition_linearTrack_hk(vr);
    vr = waitForNextTrial(vr);
                
                



% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
vr = clearAnalogChannels(vr);
savefig(vr.performanceFig, fullfile(vr.fullPath, 'performance.fig'));
saveas(vr.performanceFig, fullfile(vr.fullPath, 'performance.pdf'));
if vr.numTrials > 0
    [vr,sessionData] = collectTrialData(vr);
end
printSessionStats_linearMaze(vr)
delete(instrfind);