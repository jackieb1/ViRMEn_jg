function vr = collectBehaviorIter_Rig1(vr)

global mvData;
lickInfo = mvData(4);

thisIter(1) = vr.currentWorld;
thisIter(2:4) = vr.velocity([1,2,4]); % row 4 will be empty with fixed view angle movement function
thisIter(5:7) = vr.position([1,2,4]); % row 7 will be empty with fixed view angle movement function
thisIter(8) = vr.inITI;
% 9 is reserved for the reward, not collected within this function
thisIter(10) = vr.dt;

thisIter(4) = vr.switchBlock; % added by CA: store the block number to retrieve switches

thisIter(7) = lickInfo; % store signal from lick detector (ca 0 for no contact, ca 5 for contact)

vr.trialIterations = vr.trialIterations + 1;
vr.behaviorData([1:8,10],vr.trialIterations) = thisIter([1:8,10])';
