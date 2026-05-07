function yPulse = makePulseTrain(fs, fPulse, tHigh, tTotal, amp)
% makePulseTrain  Generate an evenly timed pulse train with no drift.
%
%   yPulse = makePulseTrain(fs, fPulse, tHigh, tTotal, amp)
%
%   fs      : sample rate (Hz)
%   fPulse  : pulse repetition frequency (Hz)
%   tHigh   : pulse high duration (s)
%   tTotal  : total train duration (s)
%   amp     : high-level amplitude (Volts or arbitrary units)
%
%   Output  : row vector of single precision samples (0 ? amp).
%
%   For fs = 1000 and fPulse = 7.5 this uses the 133-133-134
%   pattern so there is no cumulative drift.

    arguments
        fs (1,1) double {mustBePositive}
        fPulse (1,1) double {mustBePositive}
        tHigh (1,1) double {mustBePositive}
        tTotal (1,1) double {mustBePositive}
        amp (1,1) double {mustBeNumeric}
    end

    % Ideal (non-integer) samples per period
    S_ideal = fs / fPulse;

    % Integer sample pattern that cancels drift
    S_periods = [floor(S_ideal) floor(S_ideal) ceil(S_ideal)];   % e.g., [133 133 134]
    blockLen  = sum(S_periods);            % samples per 3-pulse block
    blockTime = blockLen / fs;             % time per block

    % Samples per high portion
    S_high = round(tHigh * fs);

    % Construct one 3-pulse block
    block = [];
    for i = 1:numel(S_periods)
        nLow = max(0, S_periods(i) - S_high);
        block = [block, amp * ones(1, S_high), zeros(1, nLow)];
    end

    % Repeat until total duration reached
    nBlocks = ceil(tTotal / blockTime);
    yPulse = repmat(block, 1, nBlocks);

    % Trim exactly to requested total duration
    yPulse = yPulse(1 : round(tTotal * fs));

    % Single precision for NI-DAQmx
    yPulse = single(yPulse);
end