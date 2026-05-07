function [trialList] = getTrialList()
currentDate = date;
currentDate = str2num(currentDate(1:2));
rng(currentDate)
idx = randi(6,[1 300]);
trialTypes = [1 2 3 3 4 4];
for trialNumber =  1:length(idx)
trialList(trialNumber) = trialTypes(idx(trialNumber));
end
end
