function code = L_maze_FixedHdY
% Linear Track   Code for the ViRMEn experiment T_maze.
%   code = T_maze   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT

% --- INITIALIZATION code: executes before the ViRMEn engine starts.
function vr = initializationCodeFun(vr)
vr.debugMode = false;
vr.ops = getRigInfo();
vr = makeVirmenDir(vr);
vr = initTMaze(vr);
vr = initDAQ(vr);
vr = initLivePlots_linearMaze(vr);
vr.origRewLoc = 1;

vr.fixH = 0;
vr.fixdY = 0;
vr.endFixedYPos = 50;
vr.inFixed = 0;
vr.forwardBias = 0;

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
if isTrialStart(vr)
    vr = updateLivePlots_linearMaze(vr);
%     if vr.numRewards >= vr.maxNumRewards
%         vr.experimentEnded = true;
%     end
    vr = initLinearMazeTrial(vr);
    vr.fixH = randi([0 1]);
    vr.fixdY = randi([0 1]);
    vr.inFixed = vr.fixH | vr.fixdY;
    if vr.fixH == 0 && vr.fixdY == 0
        disp("Regular Trial");
    elseif vr.fixH == 1 && vr.fixdY == 0
        disp("Fixed H");
    elseif vr.fixH == 0 && vr.fixdY == 1
        disp("Fixed dY");
    elseif vr.fixH == 1 && vr.fixdY == 1
        disp("Fixed H and dY");
    end
end

vr = outputVirmenTrigger(vr);
vr = collectBehaviorIter_TMaze(vr, vr.fixH, vr.fixdY, vr.inFixed);
%vr = adjustFriction_dan(vr);
vr = checkForManualReward(vr); % Deliver reward if 'r' key pressed
vr = fixHdY(vr);
vr = checkforTrialEndPosition_L_maze(vr);
vr = waitForNextTrial(vr);
% vr = waitForNextTrial_linTrack(vr);

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
% savefig(vr.performanceFig, fullfile(vr.fullPath, 'performance.fig'));
% saveas(vr.performanceFig, fullfile(vr.fullPath, 'performance.pdf'));
vr = clearAnalogChannels(vr);
if vr.numTrials > 0
    [vr,sessionData] = collectTrialData(vr);
end

printSessionStats_linearMaze(vr);
