function vr = changeHeading(vr)

    headingChange = vr.headingChange;
    if rand <= 0.5
        headingChange = headingChange * -1;
    end
    vr.position(4) = vr.position(4) + headingChange;
    disp('Changed heading.');

end
