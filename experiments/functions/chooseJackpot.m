function [vr] = chooseJackpot(vr)

if rand <= vr.jackpotProbability
    vr.nRewards = vr.jackpotNRewards;
    disp('Jackpot on this trial.')
else
    vr.nRewards = 1;
end