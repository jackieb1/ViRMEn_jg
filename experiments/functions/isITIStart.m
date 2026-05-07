function result = isITIStart(vr)
if (vr.inITI == 0) && (vr.rewDelayTime > vr.rewardDelay)
if vr.inITI == 1 && vr.itiTime > vr.itiDur
    result = true;
else
    result = false;
end