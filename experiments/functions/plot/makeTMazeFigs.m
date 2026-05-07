function vr = makeTMazeFigs(vr,sessionData)
%% Format Trials  
nTrials = length(unique(sessionData(end,:)))-1
figure; h1 = subplot(1,2,1); hold on; h2 = subplot(1,2,2); hold on;
for trialNumber = 1:nTrials
    trialInd = find(sessionData(end,:)==trialNumber);
    trialStart(trialNumber) = find(sessionData(end,:)==trialNumber,1);
    world(trialNumber) = mode(sessionData(1,trialInd));
    reward(trialNumber) = sum(sessionData(9,trialInd));
    notITI = sessionData(8,trialInd)==0;
    validTrialInd = trialInd(notITI);
    timePerTrial(trialNumber) = sum(sessionData(10,validTrialInd));
    if world(trialNumber==1)
        subplot(h1);       
        plot(sessionData(5,validTrialInd),sessionData(6,validTrialInd),'b');
        subplot(h2);
        plot(sessionData(6,validTrialInd), sessionData(7,validTrialInd),'b');
        
    elseif world(trialNumber==2)
        subplot(h1);
        plot(sessionData(5,validTrialInd),sessionData(6,validTrialInd),'r');
        subplot(h2); 
        plot(sessionData(6,validTrialInd), sessionData(7,validTrialInd),'r');
    end;
end

%% Plot Smoothed Trial Time
% filtLength = 5;
% halfFiltL = floor(filtLength/2);
% trialFilt = ones(filtLength,1)/filtLength;
% reflectedTimePerTrial = [timePerTrial(halfFiltL:-1:1), ...
%     timePerTrial, ...
%     timePerTrial(max(trials)-1:-1:max(trials)-halfFiltL)];
% filtTime = conv(reflectedTimePerTrial,trialFilt,'valid');
% 
% figure, hold on;
% plot(filtTime, 'LineWidth', 2);
% xlabel('Trial');
% ylabel('Time (s)');
% xlim([0 length(trials)]);
% ylim([0  max(filtTime)]);
% 