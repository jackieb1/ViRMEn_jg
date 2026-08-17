function vr = initLickPlot(vr)
% initLickPlot  Live scrolling plot of the lick sensor (ai3) voltage plus
%   vertical markers at reward-delivery times. Call ONCE in
%   initializationCodeFun, AFTER initDAQ(vr).
%
%   Single panel:
%     raw daqData(4)  -> what NI MAX shows on ai3 (the lick detector)
%   A dashed line at 0.5 V marks the vr.isLick threshold used in
%   collectBehaviorIter_TMaze. Magenta vertical lines mark each reward.
%
%   Mirrors the top panel of initVelVoltagePlot (ai0 -> ai3). State is kept
%   under vr.lickPlot so it never collides with vr.velPlot.

    % ---- settings ----
    vr.lickPlot.windowSec = 20;                            % seconds of history
    vr.lickPlot.maxPts    = ceil(vr.lickPlot.windowSec * 200); % assume <=200 Hz

    vr.lickPlot.t   = nan(1, vr.lickPlot.maxPts);
    vr.lickPlot.v   = nan(1, vr.lickPlot.maxPts);   % raw daqData(4) (ai3)
    vr.lickPlot.idx = 0;
    vr.lickPlot.t0  = tic;
    vr.lickPlot.thresh = 0.5;                       % vr.isLick threshold (V)

    % ---- reward markers ----
    % Times (s, same clock as t) at which a reward was delivered. Detected in
    % updateLickPlot by watching vr.numRewards increase. Drawn as scrolling
    % vertical lines.
    vr.lickPlot.rewT          = [];
    vr.lickPlot.lastNumReward = NaN;   % set on first update so old rewards aren't redrawn
    vr.lickPlot.rewColor      = [0.8 0 0.8];

    % ---- figure ----
    screenSize = get(0,'ScreenSize');
    figW = 700; figH = 300;
    % Place lower-right so it does not overlap initVelVoltagePlot (upper-right).
    vr.lickPlot.fig = figure( ...
        'Name', 'Lick sensor (ai3) live', 'Color', 'white', ...
        'NumberTitle', 'off', ...
        'Position', [screenSize(3)-figW-20, 420, figW, figH]);

    ax = axes('Parent', vr.lickPlot.fig); hold(ax,'on'); box(ax,'on');
    vr.lickPlot.ax   = ax;
    vr.lickPlot.hRew = plot(ax, nan, nan, '-', 'LineWidth', 1, ...
        'Color', vr.lickPlot.rewColor);   % reward markers (drawn first = behind trace)
    vr.lickPlot.hRaw = plot(ax, nan, nan, '-', 'LineWidth', 1, 'Color', [0 0.2 0.7]);
    yline(ax, vr.lickPlot.thresh, '--', ...
        sprintf('lick thresh = %.1f V', vr.lickPlot.thresh), ...
        'Color', [0.4 0.4 0.4], 'LabelHorizontalAlignment','left');
    ylabel(ax, 'ai3 (V)');
    xlabel(ax, 'time (s)');
    title(ax, 'Lick sensor live voltage  (ai3)   {\color[rgb]{0.8 0 0.8}| = reward}');
    ylim(ax, [-0.5 5.5]);
    vr.lickPlot.hTxt = text(ax, 0.99, 0.06, '', 'Units','normalized', ...
        'HorizontalAlignment','right', 'VerticalAlignment','bottom', ...
        'FontName','monospaced', 'Color',[0.2 0.2 0.2]);

    drawnow limitrate;
end
