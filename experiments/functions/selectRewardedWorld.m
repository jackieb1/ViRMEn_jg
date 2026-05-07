function vr = selectRewardedWorld(vr)
    % Create a modal dialog to ask the user which world is rewarded
    choice = questdlg('Which world is rewarded?', ...
                      'Rewarded World', ...
                      'White', 'Black', 'White');

    % Handle the user's choice
    switch choice
        case 'White'
            vr.correctRewardProbability = [0.1, 0.9];
        case 'Black'
            vr.correctRewardProbability = [0.9, 0.1];
        otherwise
            error('No valid selection made. Execution cancelled.');
    end
end
