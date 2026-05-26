function calibrateReward(varargin)
% calibrateReward  Reward valve utility: pulse-calibration OR flush/prime.
%
% Calibration (default) -- pulse valve 2 and report uL/pulse:
%   calibrateReward()                          % menu, then prompts for valve time
%   calibrateReward(valveMs)                   % 50 pulses at 5 Hz
%   calibrateReward(valveMs, nPulses, rateHz)  % override count/rate
%
% Flush / prime -- hold the reward valve open to clear air / prime tubing:
%   calibrateReward('flush')                   % prompts for seconds (default 2)
%   calibrateReward('flush', seconds)          % hold open for `seconds` (0.1-10)
%
% Reward valve = valve 2 (Teensy pin 23 / connector J17).
% NOTE: close the Arduino Serial Monitor first (the COM port is exclusive).

    % --- Mode dispatch
    mode = 'calibrate';
    if nargin >= 1 && (ischar(varargin{1}) || isstring(varargin{1}))
        mode = lower(char(varargin{1}));
    elseif nargin == 0
        choice = questdlg('Reward valve task:', 'calibrateReward', ...
                          'Calibrate (50 pulses)', 'Flush / Prime', 'Calibrate (50 pulses)');
        if isempty(choice), disp('Cancelled.'); return; end
        if strcmp(choice, 'Flush / Prime'), mode = 'flush'; end
    end
    if ~ismember(mode, {'calibrate', 'flush'})
        error('Unknown mode "%s". Use a numeric valve time, or ''flush''.', mode);
    end

    % --- Connect to the Teensy (shared by both modes)
    thisDir = fileparts(mfilename('fullpath'));
    addpath(thisDir);                                   % functions/ (getRigInfo, etc.)
    addpath(fullfile(thisDir, 'teensy'));               % connectToTeensy
    vr.ops = getRigInfo();                              % auto-detect rig -> COM port
    teensy = connectToTeensy(@(msg)[], 9600, vr);       % blocks on 'S' handshake
    cleanupObj = onCleanup(@() teensy.fclose());        %#ok<NASGU> % always close the port

    switch mode
        case 'flush'
            doFlush(teensy, varargin{:});
        otherwise
            doCalibrate(teensy, varargin{:});
    end
end

% -------------------------------------------------------------------------
function doCalibrate(teensy, varargin)
% Pulse valve 2 and report uL/pulse.
%   - If a valve time was passed (calibrateReward(valveMs,...)), calibrate once
%     and return.
%   - Otherwise, loop: prompt for a valve time, pulse, report, re-prompt -- so you
%     can calibrate repeatedly on the same connection. Cancel the dialog to stop.
    nPulses = 50;  rateHz = 5;
    if numel(varargin) >= 2 && ~isempty(varargin{2}), nPulses = varargin{2}; end
    if numel(varargin) >= 3 && ~isempty(varargin{3}), rateHz  = varargin{3}; end

    % Scripted single-shot: valve time supplied as an argument
    if numel(varargin) >= 1 && ~isempty(varargin{1}) && isnumeric(varargin{1})
        valveMs = varargin{1};
        if ~isscalar(valveMs) || isnan(valveMs) || valveMs < 1 || valveMs > 999
            error('Valve time must be a number between 1 and 999 ms.');
        end
        calibrateOnce(teensy, valveMs, nPulses, rateHz);
        return;
    end

    % Interactive: keep calibrating until the user cancels the dialog
    while true
        a = inputdlg({'Valve open time (ms, 1-999).  Cancel to stop.'}, ...
                     'Reward Calibration', [1 35], {'55'});
        if isempty(a), disp('Calibration stopped.'); return; end
        valveMs = str2double(a{1});
        if ~isscalar(valveMs) || isnan(valveMs) || valveMs < 1 || valveMs > 999
            warning('Valve time must be a number between 1 and 999 ms. Try again.');
            continue;
        end
        calibrateOnce(teensy, valveMs, nPulses, rateHz);
    end
end

% -------------------------------------------------------------------------
function calibrateOnce(teensy, valveMs, nPulses, rateHz)
% Pulse valve 2 nPulses times at rateHz, then prompt for measured volume and
% report uL/pulse.
    period = 1/rateHz;                       % 5 Hz -> 0.2 s between pulses
    if valveMs/1000 >= period
        warning('Valve time (%g ms) >= inter-pulse period (%g ms); pulses may overlap.', ...
                valveMs, period*1000);
    end

    fprintf('Calibrating valve 2: %d pulses of %d ms at %g Hz...\n', nPulses, valveMs, rateHz);
    for i = 1:nPulses
        teensy.writeValveCommand(0, valveMs);   % valve 2 only
        fprintf('  pulse %d / %d\n', i, nPulses);
        pause(period);
    end
    fprintf('Done: %d pulses delivered.\n', nPulses);

    % Measured-volume prompt -> uL/pulse
    a = inputdlg({'Total dispensed volume (uL):'}, 'Measured Volume', [1 35], {''});
    if isempty(a) || isempty(a{1}), disp('No volume entered; skipping report.'); return; end
    totalUl = str2double(a{1});
    if isnan(totalUl) || totalUl <= 0, warning('Invalid volume; skipping report.'); return; end
    fprintf('\n=== Calibration result ===\n');
    fprintf('Valve time      : %d ms\n', valveMs);
    fprintf('Pulses          : %d\n', nPulses);
    fprintf('Total volume    : %g uL\n', totalUl);
    fprintf('Per-pulse volume: %.3f uL/pulse\n', totalUl/nPulses);
end

% -------------------------------------------------------------------------
function doFlush(teensy, varargin)
% Prime/flush the reward line by holding valve 2 open.
%   - If a duration was passed (calibrateReward('flush', sec)), flush once and return.
%   - Otherwise, loop: prompt for a duration, flush, re-prompt -- so you can flush
%     repeatedly on the same connection. Cancel the dialog to stop.

    % Scripted single-shot: duration supplied as an argument
    if numel(varargin) >= 2 && ~isempty(varargin{2})
        flushSec = varargin{2};
        if ~isscalar(flushSec) || isnan(flushSec) || flushSec < 0.1 || flushSec > 10
            error('Flush duration must be between 0.1 and 10 seconds.');
        end
        flushOnce(teensy, flushSec);
        return;
    end

    % Interactive: keep flushing until the user cancels the dialog
    while true
        a = inputdlg({'Flush duration (seconds, 0.1-10).  Cancel to stop.'}, ...
                     'Flush / Prime', [1 35], {'2'});
        if isempty(a), disp('Flush stopped.'); return; end
        flushSec = str2double(a{1});
        if ~isscalar(flushSec) || isnan(flushSec) || flushSec < 0.1 || flushSec > 10
            warning('Flush duration must be between 0.1 and 10 seconds. Try again.');
            continue;
        end
        flushOnce(teensy, flushSec);
    end
end

% -------------------------------------------------------------------------
function flushOnce(teensy, flushSec)
% Hold valve 2 open for ~flushSec. The firmware caps a single open command at
% 999 ms (3-digit field) and auto-closes, so we re-issue a 999 ms open before
% the timer expires to keep the valve continuously open.
    holdMs  = 999;     % max single-command open (3-digit field)
    reissue = 0.5;     % resend before the 999 ms timer expires -> continuous open
    fprintf('Flushing valve 2: holding open ~%g s...\n', flushSec);
    t0 = tic;
    while toc(t0) < flushSec
        teensy.writeValveCommand(0, holdMs);
        pause(min(reissue, max(0.01, flushSec - toc(t0))));
    end
    fprintf('Flush done (valve closes within ~1 s of the last command).\n');
end
