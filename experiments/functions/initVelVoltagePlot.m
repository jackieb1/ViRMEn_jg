function vr = initVelVoltagePlot(vr)
% initVelVoltagePlot  Live scrolling plot of the velocity signal through the
%   whole chain. Call ONCE in initializationCodeFun, AFTER initDAQ(vr).
%
%   Three stacked panels share a time axis:
%     1 (top)    raw daqData(1)          -> what NI MAX shows on ai0
%     2 (middle) daqData(1) - offset     -> what forwardGain multiplies
%     3 (bottom) VR forward velocity     -> what the avatar actually does
%                                           (forwardGain applied, i.e. movement)
%   Dashed line on panel 1 = resting offset. Zero lines on panels 2 and 3
%   mark "no movement", so baseline drift and touch-induced jumps are obvious.

    % ---- settings ----
    vr.velPlot.windowSec = 20;                          % seconds of history
    vr.velPlot.offset    = vr.ops.ballSensorOffset(1);  % VEL_P resting V
    vr.velPlot.maxPts    = ceil(vr.velPlot.windowSec * 200); % assume <=200 Hz

    vr.velPlot.t   = nan(1, vr.velPlot.maxPts);
    vr.velPlot.v   = nan(1, vr.velPlot.maxPts);   % raw daqData(1)
    vr.velPlot.f   = nan(1, vr.velPlot.maxPts);   % VR forward velocity
    vr.velPlot.idx = 0;
    vr.velPlot.t0  = tic;

    % ---- figure ----
    screenSize = get(0,'ScreenSize');
    figW = 700; figH = 560;
    vr.velPlot.fig = figure( ...
        'Name', 'VEL_P chain (voltage -> movement)', 'Color', 'white', ...
        'NumberTitle', 'off', ...
        'Position', [screenSize(3)-figW-20, 60, figW, figH]);

    % panel 1: raw voltage
    ax1 = subplot(3,1,1, 'Parent', vr.velPlot.fig); hold(ax1,'on'); box(ax1,'on');
    vr.velPlot.ax1  = ax1;
    vr.velPlot.hRaw = plot(ax1, nan, nan, '-', 'LineWidth', 1, 'Color', [0 0.2 0.7]);
    vr.velPlot.hOff = yline(ax1, vr.velPlot.offset, '--', ...
        sprintf('offset = %.4f V', vr.velPlot.offset), ...
        'Color', [0.4 0.4 0.4], 'LabelHorizontalAlignment','left');
    ylabel(ax1, 'raw V (ai0)');
    title(ax1, 'VEL\_P live voltage  (compare to NI MAX ai0)');
    vr.velPlot.hTxt = text(ax1, 0.99, 0.06, '', 'Units','normalized', ...
        'HorizontalAlignment','right', 'VerticalAlignment','bottom', ...
        'FontName','monospaced', 'Color',[0.2 0.2 0.2]);

    % panel 2: offset-subtracted
    ax2 = subplot(3,1,2, 'Parent', vr.velPlot.fig); hold(ax2,'on'); box(ax2,'on');
    vr.velPlot.ax2  = ax2;
    vr.velPlot.hSub = plot(ax2, nan, nan, '-', 'LineWidth', 1, 'Color', [0.85 0.3 0]);
    yline(ax2, 0, '-', 'Color', [0.6 0.6 0.6]);
    ylabel(ax2, 'V - offset');
    title(ax2, 'offset-subtracted  (input to forwardGain)');

    % panel 3: VR forward velocity (movement)
    ax3 = subplot(3,1,3, 'Parent', vr.velPlot.fig); hold(ax3,'on'); box(ax3,'on');
    vr.velPlot.ax3  = ax3;
    vr.velPlot.hFwd = plot(ax3, nan, nan, '-', 'LineWidth', 1, 'Color', [0 0.5 0.2]);
    yline(ax3, 0, '-', 'Color', [0.6 0.6 0.6]);
    ylabel(ax3, 'fwd vel (vu/s)');
    xlabel(ax3, 'time (s)');
    title(ax3, 'VR forward velocity  (forwardGain applied = avatar movement)');

    linkaxes([ax1 ax2 ax3], 'x');
    drawnow limitrate;
end