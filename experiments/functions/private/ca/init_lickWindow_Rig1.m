function vr = init_lickWindow_Rig1(vr);

vr.symbolSize = 0.05;
vr.plot(1).x = [-1 1 1 -1 -1]*vr.symbolSize;
vr.plot(1).y = [-1 1 1 -1 -1]*vr.symbolSize;
vr.plot(1).color = [1 0 0];

vr.plot(1).window = 5; 

end