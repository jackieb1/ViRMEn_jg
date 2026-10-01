function makeUnexpectedRewardExper()
%makeUnexpectedRewardExper  Build the unexpected-reward experiment .mat.
%   Copies wideLinearTrack_200x20_friction05_floorStripe.mat, points it at the
%   wideLinearTrack_friction05_UnexpectedReward code file, and adds the three
%   session-parameter variables that getUnexpectedRewardParams uses as dialog defaults.
%
%   Run once, from the experiments directory. Thereafter edit the variables in the
%   ViRMEn GUI like any others. Equivalent to opening the base world in the GUI,
%   switching the experiment-code dropdown, adding the variables and doing Save As.

    srcName = 'wideLinearTrack_200x20_friction05_floorStripe';
    dstName = 'wideLinearTrack_200x20_friction05_floorStripe_UnexpectedReward';

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
    exper.experimentCode = @wideLinearTrack_friction05_UnexpectedReward;

    % Dialog defaults. Safe to add: changeExperimentVariables only re-evaluates object
    % properties whose symbolic expressions reference a changed name, and nothing
    % references these.
    exper.variables.unexpectedRewardFraction     = '0.2';
    exper.variables.unexpectedRewardNumLocations = '3';
    exper.variables.unexpectedRewardYLocations   = '[20 90 150]';

    % Refresh the cached copy of the code text the GUI keeps alongside the object.
    try, exper = updateCodeText(exper); catch, end

    save(dstFile, 'exper');
    fprintf('Wrote %s\n', dstFile);
    fprintf('  experimentCode  : %s\n', func2str(exper.experimentCode));
    fprintf('  unexpectedRewardFraction     = %s\n', exper.variables.unexpectedRewardFraction);
    fprintf('  unexpectedRewardNumLocations = %s\n', exper.variables.unexpectedRewardNumLocations);
    fprintf('  unexpectedRewardYLocations   = %s\n', exper.variables.unexpectedRewardYLocations);
end
