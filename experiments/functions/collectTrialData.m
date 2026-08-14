function [vr,sessionData] = collectTrialData(vr)
if vr.numTrials>0
    sessionData = [];
    for nTrial = 1:vr.numTrials
        try
            trialName = sprintf('Trial#%03.0f',nTrial);
            trialFileName = fullfile(vr.fullPath,trialName);
            load(trialFileName),
            behavData(end+1,:) = nTrial;
            sessionData = cat(2,sessionData,behavData);
            trialData(nTrial) = 1;
        end
    end

    fprintf('\n %03.0f Trials \n %03.0f Rewards \n',sum(trialData), vr.numRewards),
    sessionDataName = fullfile(vr.fullPath,'sessionData');

    % Only save (and clean up) when at least one trial was actually collected.
    % collectTrialData rebuilds sessionData from the trial files on every call,
    % so guarding here prevents a no-op re-run from overwriting a good
    % sessionData.mat with an empty one once the trial files have been deleted.
    if ~isempty(sessionData)
        experData = vr.exper;
        experName = experData.name;
        ops = vr.ops;
        rewardSize        = vr.rewardSize;                                  % session reward size key, e.g. '6'
        rewardDurationSec = vr.ops.rewardPulseDurationDict(vr.rewardSize);  % calibrated duration, e.g. 0.075
        numRewards        = vr.numRewards;
        save(sessionDataName,'sessionData','experData', 'experName', 'ops', ...
            'rewardSize', 'rewardDurationSec', 'numRewards'),

        % --- Verify sessionData.mat against the trial files, then delete them.
        % Two gates must pass before any deletion: (1) the trial count in the
        % saved sessionData matches the number of trial files on disk, and
        % (2) each trial file's behavData is identical to that trial's columns
        % in sessionData. If anything fails, all trial files are kept.
        trialFiles = dir(fullfile(vr.fullPath,'Trial#*.mat'));
        nFiles = numel(trialFiles);

        % Re-load from the just-written file to confirm it is on disk/readable.
        verify = load(sessionDataName,'sessionData');
        sd = verify.sessionData;
        trialRow = sd(end,:);                                   % last row = trial numbers
        nTrialsInSession = numel(unique(trialRow(~isnan(trialRow))));

        if nFiles > 0 && nTrialsInSession == nFiles
            % Per-trial content verification.
            verified = false(1,nFiles);
            for k = 1:nFiles
                tnum = sscanf(trialFiles(k).name, 'Trial#%d.mat'); % trial number from filename
                f = load(fullfile(vr.fullPath, trialFiles(k).name), 'behavData'); % load trial file
                cols = (trialRow == tnum);                         % this trial's columns
                sessBlock = sd(1:end-1, cols);                     % drop appended trial-number row
                verified(k) = isequaln(f.behavData, sessBlock);    % NaN-safe, exact for reals
            end

            if all(verified)
                nDeleted = 0;
                for k = 1:nFiles
                    try
                        delete(fullfile(vr.fullPath, trialFiles(k).name));
                        nDeleted = nDeleted + 1;
                    catch ME
                        warning('Could not delete %s: %s', trialFiles(k).name, ME.message);
                    end
                end
                fprintf('Verified %d trials (count + content) in sessionData.mat; deleted %d of %d trial files.\n', ...
                    nTrialsInSession, nDeleted, nFiles);
            else
                warning('Content mismatch for trial file(s): %s. All trial files kept.', ...
                    strjoin({trialFiles(~verified).name}, ', '));
            end
        else
            warning('Trial count mismatch: sessionData has %d trials but %d trial files on disk. Trial files kept.', ...
                nTrialsInSession, nFiles);
        end
    end
end
