function vr = chooseNextWorld_CA(vr)

if isfield(vr,'blockWorlds')
    worlds = vr.blockWorlds;
    
else
    worlds = [];
end

if isfield(vr,'ContraBias') % not the case in e.g. linear track mazes
    if (vr.ContraBias == 1)%  if a bias is to be counteracted by selecting opposite worlds for next trial
    % check choices in past trials and see if there is a bias, if so,
    % over-represent opposite worlds in list of worlds to randomly choose from
    % for next trial

        % check if the same choice was made X times in a row
        inds2check = 3;
        if numel(vr.pastChoices) >= inds2check % if enough trials have passed
            lastChoice = vr.pastChoices{end};
            choices_last = strcmp(lastChoice, vr.pastChoices(end-(inds2check-1): end));
            if numel(find(choices_last)) == inds2check % if all choices were the same
                %disp('bias')
                % reduce the list of worlds to choose from to opposite worlds
                R_worlds = [1,4,5,8,9,12,13,16];
                L_worlds = setdiff([1:16], R_worlds);
                if lastChoice == 'L'
                    % only choose R worlds out of worlds list
                   worlds =  intersect(worlds, R_worlds);
                else % if the last Choice was R
                    worlds = intersect(worlds, L_worlds);
                end
            end
        end
    end
end

if isempty(worlds)
    %Randomly select from all worlds if none specified
    vr.currentWorld = randi(vr.nWorlds);
else
    % Select randomly from worlds list
    worldChoice = randi(length(worlds));
    vr.currentWorld = worlds(worldChoice);    
end