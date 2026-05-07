function [animalData] = behaviorReport(animalList,dateList)
animalData = {};
for animalNumber = 1:length(animalList)
    for sessionNumber = 1:length(dateList)
try
    cd(fullfile('D:\DATA\Jonathan\',animalList{animalNumber},dateList{sessionNumber}));
%     cd(fullfile('Z:\HarveyLab\Tier1\Jonathan\Behavior_Imaging_Data\Virmen\',animalList{animalNumber},dateList{sessionNumber}));
%     cd(fullfile('\\research.files.med.harvard.edu\Neurobio\HarveyLab\Tier1\Jonathan\Behavior_Imaging_Data\Virmen\',animalList{animalNumber},dateList{sessionNumber}));
    folderList= dir('session*');
    load(fullfile(folderList(end).name,'sessionData.mat'))
    currentSessionData = {};
    disp('===========');
    disp(['Behavior summary for ', animalList{animalNumber}]);
    currentSessionData{1,1} = animalList{animalNumber};
    disp(['Date: ', dateList{sessionNumber}]);
    
    disp(['Experiment code: ',experData.name])
    currentSessionData{1,2} = experData.name;

    disp(['Maze length: ', num2str(str2num(experData.variables.cueLength)+str2num(experData.variables.floorLength))]);
    currentSessionData{1,3} = str2num(experData.variables.cueLength)+str2num(experData.variables.floorLength);
    
    disp(['Floor length: ',experData.variables.floorLength]);
    try
    disp(['Optolocation: ', experData.variables.optoLocation]);
    catch
    disp('No opto location found.')
    end
    
    disp(['Total time: ', num2str(sum(sessionData(10,:))/60), ' m']);
    currentSessionData{1,4} = sum(sessionData(10,:))/60;

    disp(['Total trials: ', num2str(max(sessionData(12,:)))]);
    currentSessionData{1,5} = max(sessionData(12,:));

    disp(['Correct trials: ', num2str(length(find(sessionData(9,:))))]);
    currentSessionData{1,6} = length(find(sessionData(9,:)));

    disp(['Correct %: ',num2str(100*length(find(sessionData(9,:)))/max(sessionData(12,:)))]);
    currentSessionData{1,7} = 100*length(find(sessionData(9,:)))/max(sessionData(12,:));
    disp(['Rewards per minute:', num2str(length(find(sessionData(9,:)))/(sum(sessionData(10,:))/60))])
    currentSessionData{1,8} = length(find(sessionData(9,:)))/(sum(sessionData(10,:))/60);
%     disp(['Correct % (right): ',num2str(length(find(s.isCorrect & s.trialType==2))/length(s.isCorrect(s.trialType==2)))]);
%     disp(['Correct % (left): ',num2str(length(find(s.isCorrect & s.trialType==1))/length(s.isCorrect(s.trialType==1)))]);

    disp('===========');
    percentCorrect(animalNumber,sessionNumber) = 100*length(find(sessionData(9,:)))/max(sessionData(12,:));
    rpm(animalNumber,sessionNumber)=length(find(sessionData(9,:)))/(sum(sessionData(10,:))/60);
    clear sessionData
    currentSessionData{1,9} = dateList{sessionNumber};
    animalData = cat(1,animalData,currentSessionData);
    clear sessionData currentSessionData
catch
    for columnNumber = 1:9;
    currentSessionData{1,columnNumber} = NaN;
    end
    currentSessionData{1,1} = animalList{animalNumber};
    currentSessionData{1,9} = dateList{sessionNumber};

    animalData = cat(1,animalData,currentSessionData);
    clear sessionData currentSessionData

    disp(['No session for ', animalList{animalNumber}, ' on ', dateList{sessionNumber}]);
    percentCorrect(animalNumber,sessionNumber) = NaN;
end;
    end;
end;
% 
% figure; 
% yyaxis left;
% hold on; 
% plot([12.5 12.5], [0 105],'--k')
% plot([16.5 16.5], [0 105],'--k')
% plot([20.5 20.5], [0 105],'--k')
% plot([24.5 24.5], [0 105],'--k')
% plot([26.5 26.5], [0 105],'--k')
% 
% plot(percentCorrect');
% ylim([0 105]);
% xlabel('Session number');
% ylabel('Percent correct');
% yyaxis right;
% plot(rpm,'r');
% ylabel('Rewards per minute');
end