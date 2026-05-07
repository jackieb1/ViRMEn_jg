function vr = draw_Ymaze(vr)
%% Draw Y maze walls for switching task
    hold on
    plot([-vr.floorWidth/2 -vr.floorWidth/2],[0 vr.floorLength],'k','linewidth',1.5)
    plot([-vr.floorWidth/2 -vr.funnelWidth/2],[vr.floorLength vr.floorLength+vr.funnelLength],'k','linewidth',1.5)
    plot([-vr.funnelWidth/2 -vr.funnelWidth/2],[vr.floorLength+vr.funnelLength vr.floorLength+vr.funnelLength + 20],'k','linewidth',1.5)
    plot([-vr.funnelWidth/2 vr.funnelWidth/2],[vr.floorLength+vr.funnelLength + 20 vr.floorLength+vr.funnelLength + 20],'k','linewidth',1.5)
    plot([vr.funnelWidth/2 vr.funnelWidth/2],[vr.floorLength+vr.funnelLength+20 vr.floorLength+vr.funnelLength],'k','linewidth',1.5)
    plot([vr.funnelWidth/2 vr.floorWidth/2],[vr.floorLength+vr.funnelLength vr.floorLength],'k','linewidth',1.5)
    plot([vr.floorWidth/2 vr.floorWidth/2],[vr.floorLength 0],'k','linewidth',1.5)
end
