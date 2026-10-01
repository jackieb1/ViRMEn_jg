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
    colorBySize = isfield(p, 'colorBySize') && p.colorBySize;
    if isfield(vr, 'numRewards') && ~isempty(vr.numRewards)
        nr = vr.numRewards;
        if isnan(p.lastNumReward)
            p.lastNumReward = nr;          % baseline: don't redraw pre-existing rewards
            if colorBySize, p.lastRewVolume = vr.totalRewardVolume; end
        elseif nr > p.lastNumReward
            p.rewT(end+1) = tnow;          % new reward(s) delivered this iteration
            if colorBySize
                % size = volume added per reward this iteration (covers manual rewards too)
                p.rewSize(end+1) = (vr.totalRewardVolume - p.lastRewVolume) / (nr - p.lastNumReward);
                p.lastRewVolume  = vr.totalRewardVolume;
            end
            p.lastNumReward = nr;
        end
    end
    % keep only rewards still inside the visible window
    if ~isempty(p.rewT)
        keep = p.rewT >= (tnow - p.windowSec);
        p.rewT = p.rewT(keep);
        if colorBySize, p.rewSize = p.rewSize(keep); end
    end

    % ---- detect reward omission (vr.numOmissions rising edge) ----
    % Only tasks with reward omission set up the omission line in initLickPlot; every
    % other experiment skips this entirely and its plot is unchanged.
    showOmissions = isfield(p, 'showOmissions') && p.showOmissions && ...
                    isfield(vr, 'numOmissions') && ~isempty(vr.numOmissions);
    if showOmissions
        no = vr.numOmissions;
        if isnan(p.lastNumOmissions)
            p.lastNumOmissions = no;       % baseline: don't redraw pre-existing omissions
        elseif no > p.lastNumOmissions
            p.omitT(end+1) = tnow;
            p.lastNumOmissions = no;
        end
        if ~isempty(p.omitT)
            p.omitT = p.omitT(p.omitT >= (tnow - p.windowSec));   % keep the visible window
        end
    end

    % ---- detect unexpected reward (vr.numUnexpectedRewards rising edge) ----
    % Only the unexpected-reward task sets up this line in initLickPlot; every other
    % experiment skips this entirely and its plot is unchanged.
    showUnexpected = isfield(p, 'showUnexpected') && p.showUnexpected && ...
                     isfield(vr, 'numUnexpectedRewards') && ~isempty(vr.numUnexpectedRewards);
    if showUnexpected
        nu = vr.numUnexpectedRewards;
        if isnan(p.lastNumUnexpected)
            p.lastNumUnexpected = nu;      % baseline: don't redraw pre-existing rewards
        elseif nu > p.lastNumUnexpected
            p.unexpT(end+1) = tnow;
            p.lastNumUnexpected = nu;
        end
        if ~isempty(p.unexpT)
            p.unexpT = p.unexpT(p.unexpT >= (tnow - p.windowSec));   % keep the visible window
        end
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

    % ---- reward / omission markers (scrolling vertical lines) ----
    yl = ylim(p.ax);
    if colorBySize
        matched = false(size(p.rewT));
        for k = 1:numel(p.sizeVals)
            isK = abs(p.rewSize - p.sizeVals(k)) < 1e-6;
            matched = matched | isK;
            [rx, ry] = local_vlines(p.rewT(isK), yl);
            set(p.hRewSize(k), 'XData', rx, 'YData', ry);
        end
        [rx, ry] = local_vlines(p.rewT(~matched), yl);   % sizes outside the set
    else
        [rx, ry] = local_vlines(p.rewT, yl);
    end
    set(p.hRew, 'XData', rx, 'YData', ry);
    if showOmissions
        [ox, oy] = local_vlines(p.omitT, yl);
        set(p.hOmit, 'XData', ox, 'YData', oy);
    end
    if showUnexpected
        [ux, uy] = local_vlines(p.unexpT, yl);
        set(p.hUnexp, 'XData', ux, 'YData', uy);
    end

    txt = sprintf('ai3 = %.3f V  rew=%d', raw, local_rewardCount(vr));
    if showOmissions
        txt = [txt sprintf('  omit=%d', vr.numOmissions)];
    end
    if showUnexpected
        txt = [txt sprintf('  unexp=%d', vr.numUnexpectedRewards)];
    end
    set(p.hTxt, 'String', txt);

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
