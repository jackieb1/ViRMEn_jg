function code = linearTrack_calibration
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
vr = initVelVoltagePlot(vr);     % live VEL_P voltage -> velocity plot (must be after initDAQ)
% vr = initLivePlots_linearMaze(vr);

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
if isTrialStart(vr)
%     vr = updateLivePlots_linearMaze(vr);
%     if vr.numRewards >= vr.maxNumRewards
%         vr.experimentEnded = true;
%     end
    vr = initLinearMazeTrial(vr);
end

% vr = outputVirmenTrigger(vr);
vr = collectBehaviorIter_TMaze(vr);
vr = updateVelVoltagePlot(vr);   % push current sample to the live voltage plot
%vr = adjustFriction_dan(vr);
vr = checkForManualReward(vr); % Deliver reward if 'r' key pressed
vr = checkforTrialEndPosition_linearTrack(vr);
vr = waitForNextTrial(vr);
% vr = waitForNextTrial_linTrack(vr);

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
% savefig(vr.performanceFig, fullfile(vr.fullPath, 'performance.fig'));
% saveas(vr.performanceFig, fullfile(vr.fullPath, 'performance.pdf'));
 vr = writePerformanceToExcel(vr);
vr = clearAnalogChannels(vr);
% if vr.numTrials > 0
    % [vr,sessionData] = collectTrialData(vr);
% end

printSessionStats_linearMaze(vr);
