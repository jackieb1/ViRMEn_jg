function vr = posTriggerOptoNIDAQ(vr)

if vr.optoOn == 1
    
    t_Opto = toc(vr.optoTimeOn);
    
    if t_Opto >= vr.optoDur
        vr = aoEnable(vr, false);
        vr.optoOn = 0;
        vr.optoITI = tic;
        disp("Opto Off");
    end
    
else
    t_OptoITI = toc(vr.optoITI);
    if (vr.position(2) > vr.optoLocation) && (t_OptoITI >= vr.optoITIDur) && (vr.optoOn == 0)
        vr = aoEnable(vr, true);
        vr.optoTimeOn = tic;
        vr.optoOn = 1;
        vr.optoNum(vr.vIdx) = vr.optoNum(vr.vIdx) + 1;
        disp(["Opto On" num2str(vr.vHigh)]);
        disp(["Opto counts" num2str(vr.optoNum)]);
    end
end
end