function vr = collectBehaviorIter_TMaze(vr, varargin)

global daqData;
lickInfo = daqData(4);

thisIter(1) = vr.currentWorld;
thisIter(2:4) = vr.velocity([1,2,4]); % vr.velocity(3) is dz/dt
thisIter(5:7) = vr.position([1,2,4]); % vr.position(3) is elevation
thisIter(8) = vr.inITI;
% 9 is reserved for the reward, not collected within this function
thisIter(10) = vr.dt;
thisIter(11) = lickInfo; % Stores info about lick detection (0 no lick, 5 lick)

for k = 1:nargin
    thisIter(11+k) = varargin{k};
end

vr.trialIterations = vr.trialIterations + 1;
vr.behaviorData([1:8,10:11+nargin],vr.trialIterations) = thisIter([1:8,10:11+nargin])';
