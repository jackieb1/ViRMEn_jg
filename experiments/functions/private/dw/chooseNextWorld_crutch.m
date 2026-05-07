function vr = chooseNextWorld_crutch(vr)
    %Randomly select from all worlds if none specified
%         if vr.trialType==1
%             vr.currentWorld = vr.currentWorld+2;
%             vr.trialType=2;
%         else
            vr.currentWorld=randi([1 4]);
%             vr.trialType=1;
%         end
end
