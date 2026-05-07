function [vr] = checkForManualOptoNIDAQmx(vr)
manualOpto = vr.keyPressed == 82; %'r' key
if manualOpto
    if vr.optoOn
        vr = aoEnable(vr, false);
        disp("Opto Off");
        vr.optoOn = 0;
    else
        vr = aoEnable(vr, true);
        vr.optoNum = vr.optoNum + 1;
        disp(["Opto On", num2str(vr.optoNum)]);
        vr.optoOn = 1;
    end
end
end
