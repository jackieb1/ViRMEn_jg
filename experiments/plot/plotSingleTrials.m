clear;
f1=figure; subplot 141; hold on;
        subplot 142; hold on;
fileList = dir('Trial*.mat');
correctTrials = 0;
redCorrect=0; blueCorrect=0; totalBlue=0;totalRed=0;totalRewards=0;
for fileNumber= 1:length(fileList);
    load(fileList(fileNumber).name);
    idx = find(behavData(8,:)==0,1);
    totalRewards = totalRewards+sum(behavData(9,:));
    if behavData(1,idx)==1
        subplot 141;
        if behavData(9,end)
            plot(behavData(5,idx:end),behavData(6,idx:end),'r');
            redCorrect = redCorrect+1;
            totalRed = totalRed+1;
        else
            plot(behavData(5,idx:end),behavData(6,idx:end),'Color',[.7 .7 .7]);
            totalRed=totalRed+1;
        end
        else
        subplot 142;
        if behavData(9,end)
            plot(behavData(5,idx:end),behavData(6,idx:end),'b');
            blueCorrect = blueCorrect+1;
            totalBlue =totalBlue+1;
        else
            plot(behavData(5,idx:end),behavData(6,idx:end),'Color',[.7 .7 .7]);
            totalBlue=totalBlue+1;
        end
    end
    trialCorrect(fileNumber)=0;
    trialType(fileNumber) = behavData(1,idx);
    if behavData(9,end)
        trialCorrect(fileNumber) = 1;
        correctTrials = correctTrials+1;
    end;
    trialTime(fileNumber) = sum(behavData(10,:));
end;
subplot 141; axis square; box off;
title(['Left turn trials ', num2str(redCorrect),'/',num2str(totalRed)]);
subplot 142; axis square; box off;
title(['Right turn trials ', num2str(blueCorrect),'/',num2str(totalBlue)]);
subplot 143;hold on;
yyaxis left
plot(movmean(trialCorrect,20));
plot([0 length(trialTime)], [.25 .25],'k','LineStyle','--');
plot([0 length(trialTime)], [.75 .75], 'k','LineStyle','--');
xlabel('Trial number'); 
ylabel('Percent correct');
ylim([0 1]);
yyaxis right;
plot(movmean(trialTime/60,10));
ylabel('Trial time (min)');
axis square; box off;
subplot 144; hold on;
text(.1,.1,['Percent correct: ',num2str(100*correctTrials/length(trialTime))]);
text(.1, .3,['Total trial time: ',num2str(sum(trialTime)/60)]);
text(.1, .5,['Rewards/minute: ', num2str(correctTrials/sum(trialTime/60))]);
text(.1, .7, ['Total task rewards: ', num2str(correctTrials)]);
text(.1, .9, ['Total trials: ', num2str(length(trialTime))]);
text(.1, 1, ['Total rewards: ', num2str(totalRewards)]);
axis square; axis([0 1 0 1]); axis off; box off;
set(f1,'Position',[318 601 800 431]);