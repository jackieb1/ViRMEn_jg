
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
    case 'Optorig' % Photostimulation Rig
        ops.rigName = rigName;
        
        % daq settings
        ops.dev = 'Dev6';
        ops.dioDev = 'Dev6';
        ops.optoDIOPort = 'Port0/Line1';
        
        % opto settings
        ops.optoOffset_V = 0.04;
        ops.optoAO0_V = 0.059; % 2.3 mW with cap
        ops.optoAO1_V = 0.112;
%        ops.optoAO0_V = 0.12; % 4.6 mW with cap
%        ops.optoAO1_V = 0.20;

        % ball sensor offset
        ops.ballSensorOffset = [ 1.639 1.642 1.6425 ];
        ops.forwardGain = -116;
        ops.viewAngleGain = 3;
        ops.sideGain = ops.forwardGain / 4;
        
        % reward calibration through init_variables.h
        ops.useTeensyReward = true;
        ops.comPortTeensy = 'COM3';
        ops.rewardPulseDurationDict = containers.Map;   
        ops.rewardPulseDurationDict('4') = 0.03; % 230306
        ops.rewardPulseDurationDict('6') = 0.03*1.5;
        ops.rewardPulseDurationDict('8') = 0.03*2;
        ops.rewardPulseDurationDict('12') = 0.03*3;
        ops.defaultRewardSize = '4';
        ops.defaultMaxRewardVolume = '800';
        
        % base data directory settings
%         ops.dataDirectory = 'C:\DATA\Carissa';
        ops.dataDirectory = 'C:\DATA\Jonathan';
        
    case 'Behavior_rig1'
        ops.rigName = rigName;
        
        % daq settings
        ops.dev = 'dev1';
        ops.dioDev = 'dev1';
        ops.optoDIOPort = 'Port0/Line7';
        
        % opto settings
        ops.optoOffset_V = 0.04;
        ops.optoAO0_V = 0.11; %2.3 mW with cap, 2.88 mW without
        ops.optoAO1_V = 0.063;
%         ops.optoAO0_V = 0.18;  %4.6 mW with cap
%         ops.optoAO1_V = 0.14;
        
        % ball sensor offset
        ops.ballSensorOffset = [1.6495, 1.652, 1.655];
        ops.forwardGain = -111;
        ops.viewAngleGain = 3.13;
        ops.sideGain = ops.forwardGain / 4;
        
        % reward calibration through init_variables.h
        ops.useTeensyReward = true;
        ops.comPortTeensy = 'COM3';
        ops.rewardPulseDurationDict = containers.Map;   
        ops.rewardPulseDurationDict('4') = 0.055;
        ops.rewardPulseDurationDict('8') = 0.095;
        ops.defaultRewardSize = '4';
        ops.defaultMaxRewardVolume = '800';
%         ops.defaultMaxNumRewards = '200';
        
        % base data directory settings
        ops.dataDirectory = 'C:\DATA\Jonathan';
        
    case 'Behavior_rig2'
        ops.rigName = rigName;
        
        % daq settings
        ops.dev = 'dev1';
        ops.dioDev = 'dev1';
        ops.optoDIOPort = 'Port0/Line7';
        
        % opto settings
        ops.optoOffset_V = 0.04;
         ops.optoAO0_V = 0.065; % 2.3 mW with cap
         ops.optoAO1_V = 0.068;
 %       ops.optoAO0_V = 0.115; % 4.6 mW with cap
 %       ops.optoAO1_V = 0.12;
        
        % ball sensor offset
        ops.ballSensorOffset = [1.644, 1.652, 1.65];
        ops.forwardGain = -109;
        ops.viewAngleGain = 3.05;
        ops.sideGain = ops.forwardGain / 4;
        
        % reward calibration through init_variables.h
        ops.useTeensyReward = true;
        ops.comPortTeensy = 'COM4';
        ops.rewardPulseDurationDict = containers.Map;
        ops.rewardPulseDurationDict('4') = 0.05; %230306
        ops.rewardPulseDurationDict('6') = 0.05*1.5;
        ops.rewardPulseDurationDict('8') = 0.05*2;
        ops.defaultRewardSize = '4';
        ops.defaultMaxRewardVolume = '700';
%         ops.defaultMaxNumRewards = '200';
        
        % base data directory settings
        ops.dataDirectory = 'D:\DATA\Jonathan';
        
    case 'Behavior_rig3'
        ops.rigName = rigName;
        
        % daq settings
        ops.dev = 'Dev1';
        ops.dioDev = 'Dev1';
        ops.optoDIOPort = 'Port0/Line7';
        
        % opto settings
        ops.optoOffset_V = 0.04;
        ops.optoAO0_V = 0.5; % 2.3 mW with cap
%         ops.optoAO1_V = 0.068;
 %       ops.optoAO0_V = 0.115; % 4.6 mW with cap
 %       ops.optoAO1_V = 0.12;
        
        % ball sensor offset
        ops.ballSensorOffset = [1.6435, 1.65, 1.65];
        ops.forwardGain = -112;
        ops.viewAngleGain = 2.9;
        ops.sideGain = ops.forwardGain / 4;
               % reward calibration through init_variables.h
        ops.useTeensyReward = true;
        ops.comPortTeensy = 'COM3';
        ops.rewardPulseDurationDict = containers.Map;
        ops.rewardPulseDurationDict('4') = 0.05; %230306
        ops.rewardPulseDurationDict('6') = 0.05*1.5;
        ops.rewardPulseDurationDict('8') = 0.05*2;
        ops.defaultRewardSize = '4';
        ops.defaultMaxRewardVolume = '1000';
%         ops.defaultMaxNumRewards = '200';
        
        % base data directory settings
        ops.dataDirectory = 'C:\DATA\Jonathan';
        
    case 'Rotation_scope'
        ops.rigName = rigName;
        
        % daq settings
        ops.dev = 'Dev1';
        ops.dioDev = 'Dev1';
        ops.optoDIOPort = 'Port0/Line7';
        
        % ball sensor offset
        ops.ballSensorOffset = [1.4939, 1.4985, 1.4992]; % old ball: [1.4946, 1.4965, 1.5];
        ops.forwardGain = -135;
        ops.viewAngleGain = 3.6;
        ops.sideGain = ops.forwardGain/4;
        
        % reward calibration through init_variables.h
        ops.useTeensyReward = true;
        ops.comPortTeensy = 'COM3';
        ops.rewardPulseDurationDict = containers.Map;
        ops.rewardPulseDurationDict('4') = 0.063; %220624
        ops.rewardPulseDurationDict('6') = 0.063*1.5;
        ops.rewardPulseDurationDict('8') = 0.063*2;

        ops.defaultRewardSize = '4';
        ops.defaultMaxRewardVolume = '800';
%         ops.defaultMaxNumRewards = '200';
        
        % base data directory settings
%         ops.dataDirectory = 'D:\DATA\Jonathan'; 
        ops.dataDirectory = 'D:\DATA\Henry';
        
    case 'Loki'
        ops.rigName = rigName;
        
        % daq settings
        ops.dev = 'Dev1';
        ops.dioDev = 'Dev1';
        ops.optoDIOPort = 'Port0/Line7';
        
        % ball sensor offset
        ops.ballSensorOffset = [1.5353, 1.52, 1.535];
        ops.forwardGain = -115;
        ops.viewAngleGain = 4.08;
        
        % reward calibration through init_variables.h
        ops.useTeensyReward = true;
        ops.comPortTeensy = 'COM3';
        ops.rewardPulseDurationDict = containers.Map;
        ops.rewardPulseDurationDict('4') = 0.030;
        ops.defaultRewardSize = '6';
        ops.defaultMaxRewardVolume = '800';
        
        % base data directory settings
        ops.dataDirectory = 'D:\DATA\Jonathan';
    case 'Anna_2PStim'
        ops.rigName = rigName;
        
        % daq settings
        ops.dev = 'dev1';
        ops.dioDev = 'dev1';
        ops.optoDIOPort = 'Port0/Line7';
        
        % ball sensor offset
%         ops.ballSensorOffset = [1.6378, 1.65, 1.654]; % recording
        ops.ballSensorOffset = [1.6025, 1.65, 1.598]; % not recording
        ops.forwardGain = -132;
        ops.viewAngleGain = 3.87;
        
        % reward calibration through init_variables.h
        ops.useTeensyReward = false;
        ops.rewardPulseDurationDict = containers.Map;
        ops.rewardPulseDurationDict('4') = 0.070; %211108
        ops.rewardPulseDurationDict('6') = 0.070*1.5;
        ops.rewardPulseDurationDict('8') = 0.070*2;
        ops.defaultRewardSize = '4';
        ops.defaultMaxRewardVolume = '800';
%         ops.defaultMaxNumRewards = '150';
        
        % base data directory settings
        ops.dataDirectory = 'D:\DATA\Jonathan'; 

    case '0' % try to find name automatically
        disp('Trying to identify computer automatically....');
        % try to determine rig name automatically
        name = getenv('COMPUTERNAME');
        switch name
            case 'OPTORIG' %'HARVEYRIG2'
                rigName = 'Optorig';
            case 'BEHAVIOR_RIG1'
                rigName = 'Behavior_rig1';
            case 'DESKTOP-SOH909T'
                rigName = 'Behavior_rig2';
            case 'DESKTOP-DUIPR9M'
                rigName = 'Behavior_rig3';
            case 'DESKTOP-3HCFBPM'
                rigName = 'Rotation_scope'; 
            case 'HARVEYLABCP'
                rigName = 'Loki';
            case 'DESKTOP-ID06G8C'
                rigName = 'Anna_2PStim';
            otherwise
                error('Could not find this rig! Check getRigInfo.m');
        end
        disp(['This computer is ' rigName]);
        ops = getRigInfo(rigName);
        
    otherwise
        error('Could not find this rig! Check getRigInfo.m'); 
        
end

end