function vr = chooseNextWorld_variableLength(vr)
    %Randomly select from all worlds if none specified
    vr.currentWorld = randi(6);
    %disp('doing bias correction'),vr.currentWorld =1;
end