function result = isTrialStart(vr)

if vr.inITI == 1 && (vr.itiTime > vr.itiDur)
    result = true;
else
    result = false;
end