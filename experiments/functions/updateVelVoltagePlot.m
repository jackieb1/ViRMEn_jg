function vr = updateVelVoltagePlot(vr)
% updateVelVoltagePlot  Push current sample to the live 3-panel plot.
%   Call EVERY iteration in runtimeCodeFun, AFTER the movement has been
%   applied for this iteration (i.e. after collectBehaviorIter_TMaze(vr)),
%   so vr.velocity reflects the current step.

    if ~isfield(vr, 'velPlot') || ~isvalid(vr.velPlot.fig)
        return;   % not initialized, or figure closed
    end

    global daqData
    if isempty(daqData) || numel(daqData) < 1
        return;   % acquisition hasn't delivered a sample yet
    end

    p    = vr.velPlot;
    raw  = daqData(1);                 % same value the movement code reads
    tnow = toc(p.t0);

    % ---- VR forward velocity (forwardGain applied) ----
    % Reconstruct the way the movement code computes it, so it is correct
    % regardless of which experiment overrode forwardGain. Falls back to
    % vr.velocity if the expected fields are not present.
    fwd = local_forwardVelocity(vr, raw);

    % ---- ring buffer ----
    if p.idx < p.maxPts
        p.idx = p.idx + 1; k = p.idx;
    else
        p.t(1:end-1) = p.t(2:end);
        p.v(1:end-1) = p.v(2:end);
        p.f(1:end-1) = p.f(2:end);
        k = p.maxPts;
    end
    p.t(k) = tnow; p.v(k) = raw; p.f(k) = fwd;

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
    tt = p.t(sel); vv = p.v(sel); ff = p.f(sel);

    set(p.hRaw, 'XData', tt, 'YData', vv);
    set(p.hSub, 'XData', tt, 'YData', vv - p.offset);
    set(p.hFwd, 'XData', tt, 'YData', ff);

    % ---- scroll x ----
    if tnow > p.windowSec
        xlim(p.ax1, [tnow - p.windowSec, tnow]);
    else
        xlim(p.ax1, [0, max(p.windowSec, tnow + eps)]);
    end

    % ---- autoscale y (floors keep noise visible) ----
    dv = vv - p.offset;
    spanV = max(0.02, max(abs(dv)) * 1.1);
    if isfinite(spanV)
        ylim(p.ax1, p.offset + [-1 1]*spanV);
        ylim(p.ax2, [-1 1]*spanV);
    end
    spanF = max(1, max(abs(ff)) * 1.1);
    if isfinite(spanF)
        ylim(p.ax3, [-1 1]*spanF);
    end

    % ---- reward markers (scrolling vertical lines spanning each panel) ----
    [rx1, ry1] = local_vlines(p.rewT, ylim(p.ax1));
    [rx2, ry2] = local_vlines(p.rewT, ylim(p.ax2));
    [rx3, ry3] = local_vlines(p.rewT, ylim(p.ax3));
    set(p.hRew1, 'XData', rx1, 'YData', ry1);
    set(p.hRew2, 'XData', rx2, 'YData', ry2);
    set(p.hRew3, 'XData', rx3, 'YData', ry3);

    set(p.hTxt, 'String', sprintf('VEL\\_P=%.4f V  \\Delta=%+.4f V  fwd=%+.2f  rew=%d', ...
        raw, raw - p.offset, fwd, local_rewardCount(vr)));

    vr.velPlot = p;
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

% -------------------------------------------------------------------------
function fwd = local_forwardVelocity(vr, raw)
% Mirror the movement code: forwardVelocity = forwardGain*(raw-offset) + bias,
% optionally scaled by pitchGain (T-maze variants). Robust to missing fields.
    fwd = NaN;
    try
        if isfield(vr, 'ops') && isfield(vr.ops, 'forwardGain')
            data1 = raw - vr.velPlot.offset;
            bias  = 0;
            if isfield(vr, 'forwardBias'), bias = vr.forwardBias; end
            fwd = vr.ops.forwardGain * data1 + bias;
            if isfield(vr, 'pitchGain') && ~isempty(vr.pitchGain)
                fwd = fwd * vr.pitchGain;
            end
            return;
        end
    catch
        % fall through to vr.velocity
    end
    % fallback: speed in the XY plane from the engine's velocity vector
    if isfield(vr, 'velocity') && numel(vr.velocity) >= 2
        fwd = hypot(vr.velocity(1), vr.velocity(2));
    end
end