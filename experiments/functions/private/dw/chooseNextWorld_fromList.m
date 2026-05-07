function vr = chooseNextWorld_fromList(vr)
    %Randomly select from all worlds if none specified
    vr.currentTrial = vr.currentTrial+1;
    vr.currentWorld = vr.trialList(vr.currentTrial);

    %disp('doing bias correction'),vr.currentWorld =1;
end