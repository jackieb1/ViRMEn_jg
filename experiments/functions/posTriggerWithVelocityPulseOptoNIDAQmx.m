function vr = posTriggerWithVelocityPulseOptoNIDAQmx(vr)
if (vr.position(2) > vr.optoLocation) && (vr.optoOn == 0)
    vr = aoEnable(vr, true);
    vr.optoTimeOn = tic;
    vr.optoOn = 1;
    vr.optoTriggered = 1;
    vr.optoNum(vr.currTrialType) = vr.optoNum(vr.currTrialType) + 1;
    disp(['Opto On: ' num2str(vr.optoNum.')]);
end
end