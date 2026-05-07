function vr = initLivePlots_linearMaze(vr)
    vr.exper_name = vr.exper.name; % get experiment name
    % initialize settings for plotting online behavioral metrics
    screenSize = get(0,'ScreenSize'); 
    fig_width = 1300; 
    fig_height = 700;
    performance_fig_width = 700;         
    performance_fig_height = 200; 
    vr.performanceFig = figure('Name', vr.mouseNum, 'color','white',...
    'position',[screenSize(3) - performance_fig_width,screenSize(4) - fig_height - performance_fig_height + 140,performance_fig_width, performance_fig_height]); 

    % set up performance plot figure
    vr.livePlot_opt.minTrials = 10;
    vr.livePlot_opt.nSubplots = 2;
    vr.livePlot_opt.nRows = 1;
    figure(vr.performanceFig);
    sgtitle([vr.mouseNum ' ' vr.date ' ' vr.sessionID ' ' vr.exper.name], 'Interpreter', 'none')
    
    % Time per trial
    subplot(vr.livePlot_opt.nRows,vr.livePlot_opt.nSubplots,1); hold on 
    xlim([0 vr.livePlot_opt.minTrials]);
    title("Time per trial (s)");
    
    % Stats
    subplot(vr.livePlot_opt.nRows, vr.livePlot_opt.nSubplots, 2); 
    cla; hold on;
    title("Performance Stats");
    ylim([-7 1]);
    
    text(0, 0, ['Time: 0 s'])
    text(0, -1, ['Trials: 0'])
    text(0, -2, ['Rewards: 0'])
    text(0, -3, ['Trials/min: NA'])
    text(0, -4, ['Rewards/min: NA'])
    set(gca,'visible','off')
end

 