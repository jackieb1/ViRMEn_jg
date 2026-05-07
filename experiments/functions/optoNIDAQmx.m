function vr = optoNIDAQmx(vr)

if vr.optoOn == 1
    
    t_Opto = toc(vr.optoTimeOn);
    
    if t_Opto >= vr.optoDur
        vr = aoEnable(vr, false);
        vr.optoOn = 0;
        vr.optoITI = tic;
        disp('Opto Off');
        
        vr.vIdx = randsample(6,1);
        vr.vHigh = vr.vIdx*0.5 + 2; % Voltage between 2.5-5V
        vr.yPulse = makePulseTrain(vr.Rate, 7.5, 0.03, 4.5, vr.vHigh); % set new pulse voltage
        vr = aoRewriteSameLength(vr, vr.yPulse); % write new pulse to buffer
        disp(['Next voltage set to: ' num2str(vr.vHigh)]);
    end
    
else
    t_OptoITI = toc(vr.optoITI);
    if (t_OptoITI >= vr.optoITIDur) && (vr.optoOn == 0)
        vr = aoEnable(vr, true);
        vr.optoTimeOn = tic;
        vr.optoOn = 1;
        vr.optoNum(vr.vIdx) = vr.optoNum(vr.vIdx) + 1;
        disp(['Opto On: ' num2str(vr.vHigh) ' ' num2str(vr.vIdx) ' (' num2str(vr.optoNum.') ')']);
    end
end
end