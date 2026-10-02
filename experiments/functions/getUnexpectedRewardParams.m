function vr = getUnexpectedRewardParams(vr)
%getUnexpectedRewardParams  Session parameters for the unexpected-reward task.
%   vr = getUnexpectedRewardParams(vr) takes default values from the experiment's
%   ViRMEn variable table (when they are defined there), offers them in a dialog,
%   validates what comes back, and stores the result on vr.
%
%   Call ONCE in initializationCodeFun, AFTER makeVirmenDir (which sets vr.rewardSize).
%
%   Experiment variables read (all optional):
%     unexpectedRewardFraction, unexpectedRewardNumLocations, unexpectedRewardYLocations
%
%   Sets on vr:
%     unexpectedRewardFraction      probability that a trial gets an unexpected reward
%     unexpectedRewardNumLocations  N, number of possible y-locations
%     unexpectedRewardYLocations    1xN double, y-locations (each equally likely)
%     unexpectedRewardSizeUl        ul per unexpected reward (= session reward size)
%     unexpectedRewardParams        struct archived into sessionData.mat

    % ---- defaults: experiment variables when defined, else built-ins ----
    defFraction = '0.2';
    defNumLocs  = '3';
    defYLocs    = '[20 90 150]';
    try, defFraction = num2str(eval(vr.exper.variables.unexpectedRewardFraction));     catch, end
    try, defNumLocs  = num2str(eval(vr.exper.variables.unexpectedRewardNumLocations)); catch, end
    try, defYLocs    = mat2str(eval(vr.exper.variables.unexpectedRewardYLocations));   catch, end

    % ---- prompt ----
    prompt   = {'Unexpected reward fraction (0-1)', ...
                'Number of unexpected reward y-locations (N)', ...
                'Unexpected reward y-locations (N values)'};
    dlgtitle = 'Unexpected Reward Parameters';
    dims     = [1 45];
    answer   = inputdlg(prompt, dlgtitle, dims, {defFraction, defNumLocs, defYLocs});
    if isempty(answer)
        error('Session cancelled at the unexpected-reward dialog.');
    end

    % ---- fraction ----
    fraction = str2double(answer{1});
    if isnan(fraction) || fraction < 0 || fraction > 1
        error('Unexpected reward fraction "%s" is not a number in [0 1].', answer{1});
    end

    % ---- number of locations ----
    nLocs = str2double(answer{2});
    if isnan(nLocs) || nLocs < 1 || nLocs ~= round(nLocs)
        error('Number of y-locations "%s" is not a positive integer.', answer{2});
    end

    % ---- y-locations ----
    yLocs = str2num(answer{3}); %#ok<ST2NM> - accepts '[20 90 150]' and '20 90 150'
    if numel(yLocs) ~= nLocs
        error('Expected %d y-locations, got %d from "%s".', nLocs, numel(yLocs), answer{3});
    end
    if any(~isfinite(yLocs))
        error('Y-locations must all be finite: "%s".', answer{3});
    end
    yLocs = yLocs(:).';

    % Keep every location on the track and clear of the reward-tower zone. Evaluated
    % from the experiment variables so this can run before initLinearTrack.
    startY          = 2;   % matches vr.startYLocation in the maze code
    rewardZoneRad   = 3;   % matches vr.rewardZoneRadius in the maze code
    towerY          = eval(vr.exper.variables.towerYLocation);
    maxY            = towerY - rewardZoneRad;
    if any(yLocs <= startY) || any(yLocs >= maxY)
        error(['Y-locations must lie between the start (y = %g) and the edge of the ' ...
               'reward zone (y = %g): "%s".'], startY, maxY, answer{3});
    end

    % ---- seed the generator so the draw sequence is reconstructable ----
    rngSeed = uint32(mod(floor(now*86400), 2^32-1));
    rng(rngSeed, 'twister');

    % ---- store ----
    sizeUl = str2double(vr.rewardSize);
    vr.unexpectedRewardFraction     = fraction;
    vr.unexpectedRewardNumLocations = nLocs;
    vr.unexpectedRewardYLocations   = yLocs;
    vr.unexpectedRewardSizeUl       = sizeUl;

    vr.unexpectedRewardParams = struct( ...
        'fraction',      fraction, ...
        'numLocations',  nLocs, ...
        'yLocations',    yLocs, ...
        'locationProbs', ones(1, nLocs) / nLocs, ...
        'sizeUl',        sizeUl, ...
        'rngSeed',       rngSeed, ...
        'rngGenerator',  'twister');

    % ---- echo, so the session log records what was actually used ----
    fprintf('\nUnexpected reward parameters for this session:\n');
    fprintf('  Fraction of trials : %g\n', fraction);
    fprintf('  Y-locations (N=%d) : %s  (each p = %g)\n', nLocs, mat2str(yLocs), 1/nLocs);
    fprintf('  Reward size        : %g ul\n', sizeUl);
    fprintf('  RNG seed (twister) : %u\n\n', rngSeed);
end
