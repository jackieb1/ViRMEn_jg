function vr = updateLickPlot(vr)
% updateLickPlot  Push the current lick-sensor (ai3) sample to the live plot.
%   Call EVERY iteration in runtimeCodeFun, AFTER collectBehaviorIter_TMaze(vr)
%   (so daqData is fresh) and ideally after the reward is delivered this
%   iteration (so reward markers land on the exact frame).
%
%   Mirrors the top panel of updateVelVoltagePlot (ai0 -> ai3).

    if ~isfield(vr, 'lickPlot') || ~isvalid(vr.lickPlot.fig)
        return;   % not initialized, or figure closed
    end

    global daqData
    if isempty(daqData) || numel(daqData) < 4
        return;   % acquisition hasn't delivered the lick channel yet
    end

    p    = vr.lickPlot;
    raw  = daqData(4);                 % ai3 = lick sensor
    tnow = toc(p.t0);

    % ---- ring buffer ----
    if p.idx < p.maxPts
        p.idx = p.idx + 1; k = p.idx;
    else
        p.t(1:end-1) = p.t(2:end);
        p.v(1:end-1) = p.v(2:end);
        k = p.maxPts;
    end
    p.t(k) = tnow; p.v(k) = raw;

    % ---- detect reward delivery (vr.numRewards rising edge) ----
    if isfield(vr, 'numRewards') && ~isempty(vr.numRewards)
        nr = vr.numRewards;
        if isnan(p.lastNumReward)
            p.lastNumReward = nr;          % baseline: don't redraw pre-existing rewards
        elseif nr > p.lastNumReward
            p.rewT(end+1) = tnow;          % new reward(s) delivered this iteration
            p.lastNumReward = nr;
        end
    end
    % keep only rewards still inside the visible window
    if ~isempty(p.rewT)
        p.rewT = p.rewT(p.rewT >= (tnow - p.windowSec));
    end

    % ---- visible window ----
    sel = p.t >= (tnow - p.windowSec);
    tt = p.t(sel); vv = p.v(sel);
    set(p.hRaw, 'XData', tt, 'YData', vv);

    % ---- scroll x ----
    if tnow > p.windowSec
        xlim(p.ax, [tnow - p.windowSec, tnow]);
    else
        xlim(p.ax, [0, max(p.windowSec, tnow + eps)]);
    end

    % ---- y-limits: fixed 0-5 V band, expand upward if the signal exceeds it ----
    ytop = max(5.5, max(vv) * 1.1);
    if isfinite(ytop)
        ylim(p.ax, [-0.5, ytop]);
    end

    % ---- reward markers (scrolling vertical lines) ----
    [rx, ry] = local_vlines(p.rewT, ylim(p.ax));
    set(p.hRew, 'XData', rx, 'YData', ry);

    set(p.hTxt, 'String', sprintf('ai3 = %.3f V  rew=%d', raw, local_rewardCount(vr)));

    vr.lickPlot = p;
    drawnow limitrate;
end

% -------------------------------------------------------------------------
function [x, y] = local_vlines(times, yl)
% Build XData/YData for a set of vertical lines at the given x positions,
% each spanning the y-limits yl, using NaN separators so a single line
% handle renders them all.
    if isempty(times)
        x = nan; y = nan; return;
    end
    n = numel(times);
    x = nan(1, 3*n);
    y = nan(1, 3*n);
    x(1:3:end) = times;   y(1:3:end) = yl(1);
    x(2:3:end) = times;   y(2:3:end) = yl(2);
    % every 3rd point left as NaN to lift the pen between lines
end

% -------------------------------------------------------------------------
function n = local_rewardCount(vr)
    if isfield(vr, 'numRewards') && ~isempty(vr.numRewards)
        n = vr.numRewards;
    else
        n = 0;
    end
end
