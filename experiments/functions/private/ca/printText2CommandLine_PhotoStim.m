function vr = printText2CommandLine_PhotoStim(vr)

fprintf(datestr(now-vr.timeStarted, 'MM.SS')); % print the time elapsed 

%fprintf('\n world number: %03.0f\n', vr.currentWorld);
fprintf('\n TRIAL current: %03.0f\n', vr.numTrials+1); % display number of current trial rather than completed trials
fprintf('\n REWARDS: %03.0f\n', vr.numRewards);
if vr.numTrials > 0
    fprintf('\n PRCT: %03.2f\n', vr.numRewards/vr.numTrials);
    fprintf('\n NEW BLOCK: %3.0f\n', vr.Switches);
    fprintf('\n RULE SWITCHES: %3.0f\n', vr.RuleSwitches);

else
    fprintf('\n PRCT: 0\n');
end
%fprintf('\n LENGTH: %03.0f\n', vr.exper.variables.floorLength);
