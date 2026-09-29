function makeOmitRewardVarSizeExper()
%makeOmitRewardVarSizeExper  Build the omission / variable-size reward experiment .mat.
%   Copies wideLinearTrack_200x20_friction05_floorStripe.mat, points it at the
%   wideLinearTrack_friction05_omitReward_VarSize code file, and adds the three
%   session-parameter variables that getVarRewardParams uses as dialog defaults.
%
%   Run once, from the experiments directory. Thereafter edit the variables in the
%   ViRMEn GUI like any others. Equivalent to opening the base world in the GUI,
%   switching the experiment-code dropdown, adding the variables and doing Save As.

    srcName = 'wideLinearTrack_200x20_friction05_floorStripe';
    dstName = 'wideLinearTrack_200x20_friction05_floorStripe_omitReward_VarSize';

    here    = fileparts(mfilename('fullpath'));
    srcFile = fullfile(here, [srcName '.mat']);
    dstFile = fullfile(here, [dstName '.mat']);

    if ~exist(srcFile, 'file')
        error('Source experiment not found: %s', srcFile);
    end
    if exist(dstFile, 'file')
        error('%s already exists. Delete it first if you mean to rebuild it.', dstFile);
    end

    S = load(srcFile, 'exper');
    exper = S.exper;

    exper.name           = dstName;
    exper.experimentCode = @wideLinearTrack_friction05_omitReward_VarSize;

    % Dialog defaults. Safe to add: changeExperimentVariables only re-evaluates object
    % properties whose symbolic expressions reference a changed name, and nothing
    % references these.
    exper.variables.rewardOmissionFraction = '0.3';
    exper.variables.rewardSizes            = '[2 4 7]';
    exper.variables.rewardSizeProbs        = '[0.25 0.5 0.25]';

    % Refresh the cached copy of the code text the GUI keeps alongside the object.
    try, exper = updateCodeText(exper); catch, end

    save(dstFile, 'exper');
    fprintf('Wrote %s\n', dstFile);
    fprintf('  experimentCode  : %s\n', func2str(exper.experimentCode));
    fprintf('  rewardOmissionFraction = %s\n', exper.variables.rewardOmissionFraction);
    fprintf('  rewardSizes            = %s\n', exper.variables.rewardSizes);
    fprintf('  rewardSizeProbs        = %s\n', exper.variables.rewardSizeProbs);
end
