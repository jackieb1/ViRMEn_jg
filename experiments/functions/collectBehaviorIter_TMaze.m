function vr = collectBehaviorIter_TMaze(vr, varargin)

global daqData;
lickInfo = daqData(4);
vr.isLick = lickInfo > 0.5;

thisIter(1) = vr.currentWorld;
thisIter(2:4) = vr.velocity([1,2,4]); % vr.velocity(3) is dz/dt
thisIter(5:7) = vr.position([1,2,4]); % vr.position(3) is elevation
thisIter(8) = vr.inITI;
% 9 is reserved for the reward, not collected within this function
thisIter(10) = vr.dt;
thisIter(11) = lickInfo; % Stores info about lick detection (0 no lick, 5 lick)
data = daqData(1:3) - vr.ops.ballSensorOffset;
thisIter(12:14) = data;

numChannels = numel(thisIter);
nvarargin = nargin - 1;
if nvarargin >= 1
    for k = 1:nvarargin
        thisIter(numChannels+k) = varargin{k};
    end
end

numChannels = numel(thisIter);
vr.trialIterations = vr.trialIterations + 1;
vr.behaviorData([1:8,10:numChannels],vr.trialIterations) = thisIter([1:8,10:numChannels]);
