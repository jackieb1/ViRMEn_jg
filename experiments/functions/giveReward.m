function [vr] = giveReward(vr,nRew)
%giveReward Function which delivers rewards 
%(instantaneous pulses)
%   nRew - number of rewards to deliver
disp(['Giving reward number ', num2str(vr.numRewards)]);

for i=1:nRew
    
    if vr.ops.useTeensyReward
        msgToSend = 3;
        vr.teensy.writeString(msgToSend);
    else
        outputSingleScan(vr.ao,[5 0]);
        pause(vr.ops.rewardPulseDuration)
        outputSingleScan(vr.ao,[0 0]);
        pause(0.02)
    end
    
    vr.isReward = 1; %nRew
end