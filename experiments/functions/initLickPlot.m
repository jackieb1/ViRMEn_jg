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

    % ---- omission markers ----
    % Only set up for tasks that maintain vr.numOmissions (the omission / variable-size
    % reward task), detected in updateLickPlot the same way as rewards. Every other
    % experiment gets no omission line and no mention of omissions in the title, so its
    % plot is exactly what it was before this was added.
    vr.lickPlot.showOmissions = isfield(vr, 'numOmissions');
    if vr.lickPlot.showOmissions
        vr.lickPlot.omitT            = [];
        vr.lickPlot.lastNumOmissions = NaN;
        vr.lickPlot.omitColor        = [0.9 0.5 0];
    end

    % ---- unexpected-reward markers ----
    % Only set up for tasks that maintain vr.numUnexpectedRewards (the unexpected-reward
    % task), detected in updateLickPlot the same way as rewards. Unexpected rewards do
    % not increment vr.numRewards, so they never appear as ordinary reward lines.
    vr.lickPlot.showUnexpected = isfield(vr, 'numUnexpectedRewards');
    if vr.lickPlot.showUnexpected
        vr.lickPlot.unexpT             = [];
        vr.lickPlot.lastNumUnexpected  = NaN;
        vr.lickPlot.unexpColor         = [0 0.65 0.2];
    end

    % ---- reward-size colouring ----
    % Only for tasks with variable reward sizes (vr.rewardSizeValues, set by
    % getVarRewardParams). Each reward line is coloured by its size on a light -> dark
    % magenta ramp (small -> large). The size of each reward is taken from the rise in
    % vr.totalRewardVolume, so manual 'r'-key rewards are sized too; a size that is not
    % one of vr.rewardSizeValues falls back to the plain magenta line (hRew).
    vr.lickPlot.colorBySize = isfield(vr, 'rewardSizeValues') && ...
                              ~isempty(vr.rewardSizeValues) && isfield(vr, 'totalRewardVolume');
    if vr.lickPlot.colorBySize
        sizes = sort(vr.rewardSizeValues(:).');
        nS    = numel(sizes);
        lightC = [1 0.65 1];  darkC = [0.35 0 0.4];
        if nS == 1
            f = 0.5;
        else
            f = (0:nS-1) / (nS-1);
        end
        vr.lickPlot.sizeVals      = sizes;
        vr.lickPlot.sizeColors    = lightC + f(:) .* (darkC - lightC);   % nS x 3
        vr.lickPlot.rewSize       = [];     % ul of each entry in rewT
        vr.lickPlot.lastRewVolume = NaN;
    end

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
    if vr.lickPlot.colorBySize
        vr.lickPlot.hRewSize = gobjects(1, numel(vr.lickPlot.sizeVals));
        for k = 1:numel(vr.lickPlot.sizeVals)
            vr.lickPlot.hRewSize(k) = plot(ax, nan, nan, '-', 'LineWidth', 1.5, ...
                'Color', vr.lickPlot.sizeColors(k,:));   % one line per reward size
        end
    end
    if vr.lickPlot.showOmissions
        vr.lickPlot.hOmit = plot(ax, nan, nan, '--', 'LineWidth', 1, ...
            'Color', vr.lickPlot.omitColor);  % omission markers (also behind trace)
    end
    if vr.lickPlot.showUnexpected
        vr.lickPlot.hUnexp = plot(ax, nan, nan, '-', 'LineWidth', 1.5, ...
            'Color', vr.lickPlot.unexpColor); % unexpected-reward markers (also behind trace)
    end
    vr.lickPlot.hRaw = plot(ax, nan, nan, '-', 'LineWidth', 1, 'Color', [0 0.2 0.7]);
    yline(ax, vr.lickPlot.thresh, '--', ...
        sprintf('lick thresh = %.1f V', vr.lickPlot.thresh), ...
        'Color', [0.4 0.4 0.4], 'LabelHorizontalAlignment','left');
    ylabel(ax, 'ai3 (V)');
    xlabel(ax, 'time (s)');
    titleStr = 'Lick sensor live voltage  (ai3)   {\color[rgb]{0.8 0 0.8}| = reward}';
    if vr.lickPlot.colorBySize
        titleStr = 'Lick sensor live voltage  (ai3)   reward:';
        for k = 1:numel(vr.lickPlot.sizeVals)
            c = vr.lickPlot.sizeColors(k,:);
            titleStr = [titleStr sprintf(' {\\color[rgb]{%.2f %.2f %.2f}| %g ul}', ...
                c, vr.lickPlot.sizeVals(k))]; %#ok<AGROW>
        end
    end
    if vr.lickPlot.showOmissions
        titleStr = [titleStr '   {\color[rgb]{0.9 0.5 0}| = omission}'];
    end
    if vr.lickPlot.showUnexpected
        titleStr = [titleStr '   {\color[rgb]{0 0.65 0.2}| = unexpected}'];
    end
    title(ax, titleStr);
    ylim(ax, [-0.5 5.5]);
    vr.lickPlot.hTxt = text(ax, 0.99, 0.06, '', 'Units','normalized', ...
        'HorizontalAlignment','right', 'VerticalAlignment','bottom', ...
        'FontName','monospaced', 'Color',[0.2 0.2 0.2]);

    drawnow limitrate;
end
