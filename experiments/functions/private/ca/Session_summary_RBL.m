%Script to get sumarry of behavioral session Roberto Barroso-Luque
function [Session] = Session_summary_RBL(date,animal,AM_PM)

%input date in following format: day-month-year
%input animal number
%Input if triaing was in the AM or PM
day = date; animal_num = animal;

if nargin == 2
    file = strcat('C:\DATA\Charlotte\', int2str(animal_num),'\',day);
else
    file = strcat('C:\DATA\Charlotte\', int2str(animal_num),'\',day, '\', AM_PM);
end
file_name = strcat(file, '\sessionData');
load(file_name);

%Time stored in row 10 by intraframe interval
Session.Total_time = sum(sessionData(10,:))/60; %time in minutes

%trial number stored in row 11
Session.total_trials = sessionData(11,length(sessionData));
Session.num_rewards = sum(sessionData(9,:));
Session.total_percent_correct = Session.num_rewards/Session.total_trials;
%result is in ul check giveReward_stepperMotor for correct conversion
Session.rewards_given = Session.num_rewards*3.2;


Session.condone_trials = 0;Session.condtwo_trials = 0;Session.condthree_trials = 0;
Session.condfour_trials = 0;Session.condfive_trials = 0;Session.condsix_trials = 0;
Session.condseven_trials = 0;Session.condeight_trials = 0;
%get the total number of trials per each condition
for i=1:length(sessionData)-1
    trial = sessionData(11, i);
    if sessionData(1,i) == 1 && sessionData(11,i+1)~=trial
        Session.condone_trials = Session.condone_trials +1;
    elseif sessionData(1,i) == 2 && sessionData(11,i+1)~=trial
        Session.condtwo_trials = Session.condtwo_trials +1;
    elseif sessionData(1,i) == 3 && sessionData(11,i+1)~=trial
        Session.condthree_trials = Session.condthree_trials +1;
    elseif sessionData(1,i) == 4 && sessionData(11,i+1)~=trial
        Session.condfour_trials = Session.condfour_trials +1;
    elseif sessionData(1,i) == 5 && sessionData(11,i+1)~=trial
        Session.condfive_trials = Session.condfive_trials +1;
    elseif sessionData(1,i) == 6 && sessionData(11,i+1)~=trial
        Session.condsix_trials = Session.condsix_trials +1;
    elseif sessionData(1,i) == 7 && sessionData(11,i+1)~=trial
        Session.condseven_trials = Session.condseven_trials +1;
    elseif sessionData(1,i) == 8 && sessionData(11,i+1)~=trial
        Session.condeight_trials = Session.condeight_trials +1;
    end
end

%get number of rewarded trials per each condition
indx_rewards = find(sessionData(9,:)==1);
reward_one = 0; reward_two = 0; reward_three = 0; reward_four = 0;
reward_five = 0; reward_six = 0; reward_seven = 0; reward_eight = 0;

total_rewards = 0;
for j = indx_rewards
    total_rewards = total_rewards+1;
    if sessionData(1,j)==1
        reward_one = reward_one +1;
    elseif sessionData(1,j) ==2
        reward_two = reward_two +1;
    elseif sessionData(1,j) ==3
        reward_three = reward_three +1;
    elseif sessionData(1,j) ==4
        reward_four = reward_four +1;
    elseif sessionData(1,j) ==5
        reward_five = reward_five +1;
    elseif sessionData(1,j) ==6
        reward_six = reward_six +1;
    elseif sessionData(1,j) ==7
        reward_seven = reward_seven +1;
    elseif sessionData(1,j) ==8
        reward_eight = reward_eight +1;
    end
end

Session.one_percent_correct = reward_one/Session.condone_trials;
Session.two_percent_correct = reward_two/Session.condtwo_trials;
Session.three_percent_correct = reward_three/Session.condthree_trials;
Session.four_percent_correct = reward_four/Session.condfour_trials;
Session.five_percent_correct = reward_five/Session.condfive_trials;
Session.six_percent_correct = reward_six/Session.condsix_trials;
Session.seven_percent_correct = reward_seven/Session.condseven_trials;
Session.eight_percent_correct = reward_eight/Session.condeight_trials;

end