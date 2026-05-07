clear;
f1=figure; subplot 241; hold on; subplot 245; hold on;
        subplot 242; hold on; subplot 246; hold on;
fileList = dir('Trial*.mat');
correctTrials = 0;
redCorrect=0; blueCorrect=0; totalBlue=0;totalRed=0;totalRewards=0;
%% For crutch trials
count = 0; redCorrect=0; blueCorrect=0; totalBlue=0;totalRed=0;totalRewards=0;
for fileNumber= 1:2:length(fileList);
    count=count+1;
    load(fileList(fileNumber).name);
    idx = find(behavData(8,:)==0,1);
    totalRewards = totalRewards+sum(behavData(9,:));
    if mod(behavData(1,idx),2)==1
        subplot 241;
        if behavData(9,end)
            plot(behavData(5,idx:end),behavData(6,idx:end),'r');
            redCorrect = redCorrect+1;
            totalRed = totalRed+1;
        else
            plot(behavData(5,idx:end),behavData(6,idx:end),'Color',[.7 .7 .7]);
            totalRed=totalRed+1;
        end
        else
        subplot 242;
        if behavData(9,end)
            plot(behavData(5,idx:end),behavData(6,idx:end),'b');
            blueCorrect = blueCorrect+1;
            totalBlue =totalBlue+1;
        else
            plot(behavData(5,idx:end),behavData(6,idx:end),'Color',[.7 .7 .7]);
            totalBlue=totalBlue+1;
        end
    end
    crutchTrialCorrect(count)=0;
    trialType(count) = behavData(1,idx);
    if behavData(9,end)
        trialCorrect(count) = 1;
        correctTrials = correctTrials+1;
    end;
    crutchTrialTime(count) = sum(behavData(10,:));
end;
subplot 241; axis square; box off;
title(['Left turn trials ', num2str(redCorrect),'/',num2str(totalRed)]);
subplot 242; axis square; box off;
title(['Right turn trials ', num2str(blueCorrect),'/',num2str(totalBlue)]);
subplot 243;hold on;
yyaxis left
plot(movmean(trialCorrect,20));
xlabel('Trial number'); 
ylabel('Percent correct');
ylim([0 1]);
yyaxis right;
plot(movmean(crutchTrialTime/60,10));
ylabel('Trial time (min)');
axis square; box off;
subplot 244; hold on;
text(.1,.1,['Percent correct: ',num2str(100*correctTrials/length(crutchTrialTime))]);
text(.1, .3,['Total trial time: ',num2str(sum(crutchTrialTime)/60)]);
text(.1, .5,['Rewards/minute: ', num2str(correctTrials/sum(crutchTrialTime/60))]);
text(.1, .7, ['Total task rewards: ', num2str(correctTrials)]);
text(.1, .9, ['Total trials: ', num2str(length(crutchTrialTime))]);
text(.1, 1, ['Total rewards: ', num2str(totalRewards)]);
axis square; axis([0 1 0 1]); axis off; box off;
%% For towerless trials
count =0; redCorrect=0; blueCorrect=0; totalBlue=0;totalRed=0;totalRewards=0; trialTime = 0;
trialCorrect = []; correctTrials = 0; trialType=[];
for fileNumber= 5:5:length(fileList);
    count = count+1;
    load(fileList(fileNumber).name);
    idx = find(behavData(8,:)==0,1);
    totalRewards = totalRewards+sum(behavData(9,:));
    if mod(behavData(1,idx),2)==1
        subplot 245;
        if behavData(9,end)
            plot(behavData(5,idx:end),behavData(6,idx:end),'r');
            redCorrect = redCorrect+1;
            totalRed = totalRed+1;
        else
            plot(behavData(5,idx:end),behavData(6,idx:end),'Color',[.7 .7 .7]);
            totalRed=totalRed+1;
        end
        else
        subplot 246;
        if behavData(9,end)
            plot(behavData(5,idx:end),behavData(6,idx:end),'b');
            blueCorrect = blueCorrect+1;
            totalBlue =totalBlue+1;
        else
            plot(behavData(5,idx:end),behavData(6,idx:end),'Color',[.7 .7 .7]);
            totalBlue=totalBlue+1;
        end
    end
    trialCorrect(count)=0;
    trialType(count) = behavData(1,idx);
    if behavData(9,end)
        trialCorrect(count) = 1;
        correctTrials = correctTrials+1;
    end;
    trialTime(count) = sum(behavData(10,:));
end;
subplot 245; axis square; box off;
title(['Left turn trials ', num2str(redCorrect),'/',num2str(totalRed)]);
subplot 246; axis square; box off;
title(['Right turn trials ', num2str(blueCorrect),'/',num2str(totalBlue)]);
subplot 247;hold on;
yyaxis left
plot(movmean(trialCorrect,20));
xlabel('Trial number'); 
ylabel('Percent correct');
ylim([0 1]);
yyaxis right;
plot(movmean(trialTime/60,10));
ylabel('Trial time (min)');
axis square; box off;
subplot 248; hold on;
text(.1,.1,['Percent correct: ',num2str(100*correctTrials/length(trialTime))]);
text(.1, .3,['Total trial time: ',num2str(sum(trialTime)/60)]);
text(.1, .5,['Rewards/minute: ', num2str(correctTrials/sum(trialTime/60))]);
text(.1, .7, ['Total task rewards: ', num2str(correctTrials)]);
text(.1, .9, ['Total trials: ', num2str(length(trialTime))]);
text(.1, 1, ['Total rewards: ', num2str(totalRewards)]);
axis square; axis([0 1 0 1]); axis off; box off;
set(f1,'Position',[318 601 800 431]);