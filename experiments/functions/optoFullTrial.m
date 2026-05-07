function vr = optoFullTrial(vr)
if vr.inITI
    vr.optoOn = 0;
end

if isTrialStart(vr)
    if rand <= vr.fractionOptoTrial
        vr.optoOn = 1;
    else
        vr.optoOn = 0;
    end
end
outputSingleScan(vr.optoDIO,[vr.optoOn]);