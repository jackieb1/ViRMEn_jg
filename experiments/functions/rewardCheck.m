function rewardCheck(ops, n_pulses, delay, duration)
if nargin < 3
    duration = 0.08; % .012 -.029 duration = 0.035; %alice 130305
    % CA: 17-81^; 0.05 gives ca 4.3 ul reward
    % RBL: calibrateSolenoid_CA(300,.5,0.06) 4.3 ul reward 29-08-17
end

if nargin < 2
    delay = .1;
end

if nargin < 1
    n_pulses = 10;
end


if ops.useTeensyReward
    disp('Does not work with Teensy reward yet.')
    delete(instrfindall);
    baudRate = 9600;
    teensy = connectToTeensy(@messageHandler, baudRate, vr);
    
else
    daqreset;
    s = daq.createSession('ni');
    s.addAnalogOutputChannel(ops.dev,'ao0', 'Voltage');
    s.Rate = 1000;
    ActualRate = s.Rate;
end

for i=1:n_pulses
    disp(['i = ',num2str(i)]);
    if ops.useTeensyReward
        msgToSend = 3;
        teensy.writeString(msgToSend);
    else
        outputSingleScan(s,[5]);
        pause(duration)
        outputSingleScan(s,[0]);
    end
    pause(delay)
end


function messageHandler(msg)
	%fprintf('Recived message: %s\n', msg)
end

end