function [vr] = checkForManualOpto(vr)
manualOpto = vr.keyPressed == 82; %'r' key
if vr.optoOn == 1
    
    t_Opto = toc(vr.optoTimeOn);
    
    if t_Opto >= vr.optoDur
        vr = turnOffLED(vr);
        vr.optoOn = 0;
        vr.optoITI = tic;
        disp("Opto Off");
    end
    
else
    t_OptoITI = toc(vr.optoITI);
    if (manualOpto) && (t_OptoITI >= vr.optoITIDur) && (vr.optoOn == 0)
        vr = turnOnLED(vr);
        vr.optoTimeOn = tic;
        vr.optoOn = 1;
        vr.optoNum = vr.optoNum + 1;
        disp(["Opto On", num2str(vr.optoNum)]);
    end
end
end
