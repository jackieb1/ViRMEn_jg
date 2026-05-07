function [position,movementType] = moveLoadedData(vr) 
movementType = 'position';
vr.behavData(5:7,vr.iterNumber)
    position = [vr.behavData(5:6,vr.iterNumber);1.5;vr.behavData(7,vr.iterNumber)]

end