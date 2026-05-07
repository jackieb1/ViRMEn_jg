function code = T_maze_worldChange150_270vu
% T_maze   Code for the ViRMEn experiment T_maze.
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
vr = initLivePlots(vr);

% Version-specific parameters
vr.totalMazeLength = vr.floorLength + vr.cueLength;
vr.YTrigger = vr.totalMazeLength * 2;
vr.fractionTrials = 0.3;
vr.YTriggerPositions = [150 270];
vr.YTriggerPosition = 270;
vr.inWorldChange = 0;

vr = initDAQ(vr);

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

vr = outputVirmenTrigger(vr);
vr = collectBehaviorIter_TMaze(vr, vr.inWorldChange, vr.YTrigger);
%vr = adjustFriction_dan(vr);
vr = checkForManualReward(vr); % Deliver reward if 'r' key pressed
vr = checkforTrialEndPosition_Tmaze(vr);
vr = waitForNextTrial(vr);

if vr.position(2) >= vr.YTrigger
    vr = changeWorld(vr);
    vr.inWorldChange = 1;
    vr = disableYTrigger(vr);
end

if isTrialStart(vr)
    vr = updateLivePlots(vr);
    if vr.numRewards >= vr.maxNumRewards
        vr.experimentEnded = true;
    end
    
    vr = initTrial(vr);
    if rand <= vr.fractionTrials
        vr.YTriggerPosition = datasample(vr.YTriggerPositions, 1);
        disp(['y trigger at:', num2str(vr.YTriggerPosition)]);
        vr.YTrigger = vr.YTriggerPosition;
    end
    vr.inWorldChange = 0;
end

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
vr = clearAnalogChannels(vr);
[vr,sessionData] = collectTrialData(vr);
savefig(vr.performanceFig, fullfile(vr.fullPath, 'performance.fig'));
saveas(vr.performanceFig, fullfile(vr.fullPath, 'performance.pdf'));
%vr = makeTMazeFigs(vr,sessionData);
printSessionStats(vr);
