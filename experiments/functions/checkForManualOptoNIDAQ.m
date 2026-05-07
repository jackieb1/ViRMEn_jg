function [vr] = checkForManualOptoNIDAQ(vr)
manualOpto = vr.keyPressed == 82; %'r' key
if manualOpto
%     firePulse(vr.ao, 2.0, 30);
    if vr.optoOn
        vr.ao.outputSingleScan(0);
        disp("Opto Off");
        vr.optoOn = 0;
    else
        vr.ao.outputSingleScan(5);
        vr.optoNum = vr.optoNum + 1;
        disp(["Opto On", num2str(vr.optoNum)]);
        vr.optoOn = 1;
    end
end
end
