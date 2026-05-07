function vr = makeLinearTrackFigs(vr,sessionData)

%% input handling
if ~exist('switchPoints','var') || isempty(switchPoints)
    switchPoints = 100;
end

%% Format Trials  

trials = unique(sessionData(end,:));
for nTrial = trials
    trialInd = find(sessionData(end,:)==nTrial);
    world(nTrial) = mode(sessionData(1,trialInd));
    reward(nTrial) = sum(sessionData(9,trialInd));
    notITI = sessionData(8,trialInd) == 0;
    validTrialInd = trialInd(notITI);
    timePerTrial(nTrial) = sum(sessionData(10,validTrialInd));
end

%% Plot Smoothed Trial Time
filtLength = 5;
halfFiltL = floor(filtLength/2);
trialFilt = ones(filtLength,1)/filtLength;
reflectedTimePerTrial = [timePerTrial(halfFiltL:-1:1), ...
    timePerTrial, ...
    timePerTrial(max(trials)-1:-1:max(trials)-halfFiltL)];
filtTime = conv(reflectedTimePerTrial,trialFilt,'valid');

figure, hold on;
plot(filtTime, 'LineWidth', 2);
for switchPoint = switchPoints
    line([switchPoint switchPoint],[-0.05 max(filtTime)],'Color','r')
end
xlabel('Trial');
ylabel('Time (s)');
xlim([0 length(trials)]);
ylim([0  max(filtTime)]);