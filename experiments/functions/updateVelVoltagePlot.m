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

    set(p.hTxt, 'String', sprintf('VEL\\_P=%.4f V  \\Delta=%+.4f V  fwd=%+.2f', ...
        raw, raw - p.offset, fwd));

    vr.velPlot = p;
    drawnow limitrate;
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