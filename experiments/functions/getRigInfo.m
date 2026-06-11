
function ops = getRigInfo(varargin)
%Code from Noah's github rep, eddited by SS March 2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% I am altering this to be a much more general functio
%n that can be called
% by other functions (such as calibration and testing functions)
% either pass in r
%Rig  igName string, or no variables or empty string. second
% two cases matlab will try to determine rig automatically

switch nargin
    case 1
        rigName = varargin{1};
    case 0
        rigName = '0'; % flag to find automatically
end

if isempty(rigName)
    rigName = '0';
end

switch rigName

    case 'GreenLab_Behavior_rig1'
        ops.rigName = rigName;

        % daq settings
        ops.dev = 'dev1';
        ops.dioDev = 'dev1';
        ops.optoDIOPort = 'Port0/Line7';


        % ball sensor offset
        ops.ballSensorOffset = [1.6425, 1.647, 1.646]; % JEB - 2026-05-14
        ops.forwardGain = -1110;
        ops.forwardDeadband = 0.003; % volts; suppress resting +/-1-count jitter on data(1). Tune to just above resting noise.
        ops.viewAngleGain = 27;
        ops.sideGain = ops.forwardGain / 4;
        ops.sideOffset = -112;

        % reward calibration through init_variables.h
        ops.useTeensyReward = true;
        ops.comPortTeensy = 'COM4';
        ops.rewardPulseDurationDict = containers.Map;
        ops.rewardPulseDurationDict('4') = 0.055;
        ops.rewardPulseDurationDict('2') = 0.035;
        ops.rewardPulseDurationDict('7') = 0.075;
        ops.defaultRewardSize = '4';
        ops.defaultMaxRewardVolume = '800';
        %         ops.defaultMaxNumRewards = '200';

        % base data directory settings
        ops.dataDirectory = 'C:\Users\GreenLab\Desktop\TestDataDir';

    case 'GreenLab_Behavior_rig2'
        ops.rigName = rigName;

        % daq settings
        ops.dev = 'dev2';
        ops.dioDev = 'dev2';
        ops.optoDIOPort = 'Port0/Line7';


        % ball sensor offset
        ops.ballSensorOffset = [1.633, 1.647, 1.646]; % JEB - 2026-05-14
        ops.forwardGain = -135;
        ops.forwardDeadband = 0.003; % volts; suppress resting +/-1-count jitter on data(1). Tune to just above resting noise.
        ops.viewAngleGain = 27;
        ops.sideGain = ops.forwardGain / 4;
        ops.sideOffset = -112;

        % reward calibration through init_variables.h
        ops.useTeensyReward = true;
        ops.comPortTeensy = 'COM5';
        ops.rewardPulseDurationDict = containers.Map;
        ops.rewardPulseDurationDict('4') = 0.055;
        ops.rewardPulseDurationDict('2') = 0.035;
        ops.rewardPulseDurationDict('7') = 0.075;
        ops.defaultRewardSize = '4';
        ops.defaultMaxRewardVolume = '800';
        %         ops.defaultMaxNumRewards = '200';

        % base data directory settings
        ops.dataDirectory = 'C:\Users\GreenLab\Desktop\TestDataDir';


    case '0' % try to find name automatically
        disp('Trying to identify computer automatically....');
        % try to determine rig name automatically
        name = getenv('COMPUTERNAME');
        switch name
            case 'MB-GREE-0258'
                rigName = 'GreenLab_Behavior_rig1';
            case 'MB-GREE-0257'
                rigName = 'GreenLab_Behavior_rig2';
            otherwise
                error('Could not find this rig! Check getRigInfo.m');
        end
        disp(['This computer is ' rigName]);
        ops = getRigInfo(rigName);

    otherwise
        error('Could not find this rig! Check getRigInfo.m');

end

end