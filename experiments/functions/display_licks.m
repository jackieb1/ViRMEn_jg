function vr = display_licks(vr)

global mvData;
lickInfo = mvData(4);

yMin = 0; 
yMax = 5;
% Normalize y-position
symbolYPosition = 2*(lickInfo - yMin)/(yMax-yMin) - 1;

vr.plot(1).y = [-1 -1 1 1 -1]*vr.symbolSize + symbolYPosition; % display lickInfo

end
