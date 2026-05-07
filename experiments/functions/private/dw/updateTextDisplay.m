function vr = updateTextDisplay(vr)

vr.text(1).string = ['TIME: ' datestr(now-vr.timeStarted,'MM.SS')];
vr.text(2).string = ['TRIALS: ' num2str(vr.numTrials)];
vr.text(3).string = ['REWARDS: ' num2str(vr.numRewards)];
if vr.numTrials > 0
    vr.text(4).string = ['PRCT: ' num2str(vr.numRewards/vr.numTrials)];
else
    vr.text(4).string = 'PRCT: 0';
end
vr.text(5).string = ['LENGTH: ', vr.exper.variables.floorLength];