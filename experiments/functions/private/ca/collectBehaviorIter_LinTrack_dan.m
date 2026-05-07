function vr = collectBehaviorIter_LinTrack_dan(vr)

global mvData;
lickInfo = mvData(4);

thisIter(1) = vr.currentWorld;
thisIter(2:4) = vr.velocity([1,2,4]);
thisIter(5:7) = vr.position([1,2,4]);
thisIter(8) = vr.inITI;
% 9 is reserved for the reward, not collected within this function
thisIter(10) = vr.dt;

thisIter(7) = lickInfo; % Stores info about lick detection (0 no lick, 5 lick)

% thisIter(4) = vr.switchBlock; % added by CA: store the block number to retrieve switches

vr.trialIterations = vr.trialIterations + 1;
vr.behaviorData([1:8,10],vr.trialIterations) = thisIter([1:8,10])';
