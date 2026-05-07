function vr = checkMaxRewards(vr)

    if vr.numRewards >= vr.maxNumRewards
        vr.experimentEnded = true;
    end