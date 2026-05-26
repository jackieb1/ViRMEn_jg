function [vr] = giveReward(vr,nRew)
%giveReward Function which delivers rewards 
%(instantaneous pulses)
%   nRew - number of rewards to deliver
disp(['Giving reward number ', num2str(vr.numRewards)]);

for i=1:nRew
    
    if vr.ops.useTeensyReward
        rewSec = vr.ops.rewardPulseDurationDict(vr.rewardSize); % session size from startup dialog
        rewMs  = max(1, min(999, round(rewSec*1000)));                     % clamp to 3 digits
        vr.teensy.writeValveCommand(0, rewMs);   % valve 2 (solenoid on J17 / pin 23)
    else
        outputSingleScan(vr.ao,[5 0]);
        pause(vr.ops.rewardPulseDuration)
        outputSingleScan(vr.ao,[0 0]);
        pause(0.02)
    end
    
    vr.isReward = 1; %nRew
end