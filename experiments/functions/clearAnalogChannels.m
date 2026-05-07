function [vr] = clearAnalogChannels(vr)
if ~vr.debugMode
    stop(vr.ai),
    delete(vr.ai),
%     delete(vr.ao), % 10/29/25 (HK) - remove session AO to use in DAQmx
    delete(vr.dio),
    delete(vr.optoDIO),
    daqreset;
end

end

