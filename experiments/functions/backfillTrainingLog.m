function report = backfillTrainingLog(opts)
% backfillTrainingLog  Fill in past days missing from the SharePoint training logs.
%
% Run from MATLAB on a rig (outside ViRMEn):   backfillTrainingLog
%
% 1. Asks which animals to process (pick one or several).
% 2. Looks each animal up in Tracking_Log_FilenameSpreadsheet to find its
%    tracking log, the same way writePerformanceToExcel does at session end.
% 3. Reads the ViRMEn data for that animal from the shared all-rig folder
%    (ops.virmenDataArchive, e.g. Y:\data\raw\virmen\<animal>\<yymmdd>\session_N)
%    and, for every session with a performance.fig, fills that session's row in
%    the animal's sheet if it is missing or has no performance data yet.
%    Cells that already have values are never overwritten.
% 4. Adds a date-only row for every day between the animal's first and last
%    ViRMEn day that has no data and no row in the sheet yet.
%
% Before writing, it shows a preview for each animal and asks to continue. A
% summary is shown at the end. Written cells are read back to confirm they saved.
%
% opts (optional, mainly for testing) may contain:
%   animals  - cell array of animal IDs (skips the selection dialog)
%   xlsFile  - write to this workbook for every animal instead of looking it up
%   dataDir  - ViRMEn data folder (default ops.virmenDataArchive)
%   ops      - rig ops struct (default getRigInfo())
%   confirm  - false to skip the per-animal preview dialog (default true)
%   showSummary - false to skip the final summary dialog (default true)
%
% Returns a struct array with one element per animal describing what was done.

    if nargin < 1, opts = struct(); end
    T = trackingLogTools();
    report = struct('animal', {}, 'file', {}, 'status', {}, 'filled', {}, ...
                    'skipped', {}, 'dateRows', {}, 'message', {});

    % ---- rig settings and data folder -----------------------------------
    if isfield(opts, 'ops'), ops = opts.ops; else, ops = getRigInfo(); end
    if isfield(opts, 'dataDir')
        dataDir = opts.dataDir;
    elseif isfield(ops, 'virmenDataArchive')
        dataDir = ops.virmenDataArchive;
    else
        error('backfillTrainingLog:noDataDir', ...
            'ops.virmenDataArchive is not set for this rig (see getRigInfo.m).');
    end
    if ~exist(dataDir, 'dir')
        error('backfillTrainingLog:noDataDir', ...
            'ViRMEn data folder %s is not reachable (is the Y: drive connected?).', dataDir);
    end
    xlsOverride = '';
    if isfield(opts, 'xlsFile'), xlsOverride = opts.xlsFile; end
    if isempty(xlsOverride) && (~isfield(ops, 'trainingLogURL') || isempty(ops.trainingLogURL))
        error('backfillTrainingLog:noURL', ...
            'ops.trainingLogURL is not set for this rig (see getRigInfo.m).');
    end
    confirm = ~isfield(opts, 'confirm') || opts.confirm;
    showSummary = ~isfield(opts, 'showSummary') || opts.showSummary;

    % ---- which animals ----------------------------------------------------
    if isfield(opts, 'animals')
        animals = cellstr(opts.animals);
    else
        allAnimals = listAnimals(dataDir);
        if isempty(allAnimals)
            error('backfillTrainingLog:noAnimals', 'No animal folders found in %s.', dataDir);
        end
        [sel, ok] = listdlg('ListString', allAnimals, 'SelectionMode', 'multiple', ...
            'PromptString', {'Backfill the training log for which animals?', ...
                             '(Ctrl/Shift-click to pick several)'}, ...
            'Name', 'Backfill training log', 'ListSize', [260 320]);
        if ~ok || isempty(sel)
            fprintf('backfillTrainingLog: no animals selected.\n');
            return
        end
        animals = allAnimals(sel);
    end

    Excel = [];
    myPid = [];
    try
        userExcel = T.waitForUserExcel();   % before starting our own hidden Excel
        [Excel, myPid] = T.startExcel();

        % ---- read sessions and find each animal's workbook ----------------
        jobs = struct('animal', {}, 'sessions', {}, 'xlsFile', {});
        for a = 1:numel(animals)
            r = newReport(animals{a});
            try
                fprintf('Reading ViRMEn data for %s...\n', animals{a});
                sessions = readSessions(T, dataDir, animals{a});
                if isempty(sessions)
                    r.status = 'nothing to do';
                    r.message = 'No sessions with a performance.fig in the data folder.';
                    report(end+1) = r; %#ok<AGROW>
                    continue
                end
                if isempty(xlsOverride)
                    xlsFile = T.resolveTrackingLog(Excel, ops.trainingLogURL, animals{a});
                else
                    xlsFile = xlsOverride;
                end
                jobs(end+1) = struct('animal', animals{a}, 'sessions', sessions, ...
                                     'xlsFile', xlsFile); %#ok<AGROW>
            catch ME
                r.status = 'failed';
                r.message = ME.message;
                report(end+1) = r; %#ok<AGROW>
            end
        end

        % ---- one open/save per workbook (animals can share a workbook) ----
        if ~isempty(jobs)
            keysAll = cellfun(T.canonName, {jobs.xlsFile}, 'UniformOutput', false);
            [~, firstIdx, grp] = unique(keysAll, 'stable');
            for g = 1:numel(firstIdx)
                group = jobs(grp == g);
                report = [report, processWorkbook(T, userExcel, Excel, group, confirm)]; %#ok<AGROW>
            end
        end

        T.quitExcel(Excel, myPid);
    catch ME
        T.quitExcel(Excel, myPid);
        msg = ME.message;
        if T.isExcelBusy(ME) && ~strcmp(ME.identifier, 'trackingLog:busy')
            msg = 'Excel is busy (a cell is being edited or a dialog is open). Press Enter or Esc in Excel, then re-run.';
        end
        r = newReport('(all)');
        r.status = 'failed';
        r.message = msg;
        report(end+1) = r;
    end

    % ---- summary -------------------------------------------------------------
    lines = summaryLines(report);
    fprintf('\n%s\n', strjoin(lines, newline));
    if showSummary
        anyFail = any(strcmp({report.status}, 'failed'));
        if anyFail
            errordlg(lines, 'Training log backfill: some animals failed', 'non-modal');
        else
            msgbox(lines, 'Training log backfill done', 'help', 'non-modal');
        end
    end
end

% ======================================================================

function rep = processWorkbook(T, userExcel, Excel, group, confirm)
% Plan, confirm and write every animal in group (all share one workbook), then
% save once and verify.
    xlsFile = group(1).xlsFile;
    rep = repmat(newReport(''), 1, 0);
    wb = [];
    attached = false;
    entries = struct('sheet', {}, 'dn', {}, 'n', {}, 'col', {}, 'value', {}, 'label', {});
    pending = [];   % indices into rep that wrote something (verified below)
    try
        [wb, attached] = T.openForWriting(userExcel, Excel, xlsFile);
        for j = 1:numel(group)
            r = newReport(group(j).animal);
            r.file = fileLabel(xlsFile);
            try
                sheet = T.findAnimalSheet(wb, group(j).animal);
                sheetName = char(sheet.Name);
                L = T.readLayout(sheet);
                plan = planAnimal(T, sheet, L, group(j).sessions);
                r.skipped = plan.nSkip;

                if isempty(plan.items)
                    r.status = 'nothing to do';
                    r.message = sprintf('All %d sessions already logged; no missing dates.', plan.nSkip);
                    rep(end+1) = r; %#ok<AGROW>
                    continue
                end

                if confirm
                    q = previewText(group(j).animal, r.file, sheetName, plan);
                    ans_ = questdlg(q, ['Backfill ' group(j).animal], 'Yes', 'No', 'Yes');
                    if ~strcmp(ans_, 'Yes')
                        r.status = 'skipped by user';
                        rep(end+1) = r; %#ok<AGROW>
                        continue
                    end
                end

                % write in date order, so rows written earlier are never shifted
                % by later inserts
                for k = 1:numel(plan.items)
                    it = plan.items(k);
                    [row, ~, L, dateEntry] = T.findOrInsertSessionRow(sheet, L, it.dn, it.n);
                    if it.isDateOnly
                        w = dateEntry;
                        r.dateRows = r.dateRows + 1;
                    else
                        w = [dateEntry; T.writeMetrics(sheet, L, row, it.metrics, true)];
                        r.filled = r.filled + 1;
                    end
                    for c = 1:size(w, 1)
                        entries(end+1) = struct('sheet', sheetName, 'dn', it.dn, 'n', it.n, ...
                            'col', w{c, 1}, 'value', w{c, 2}, 'label', w{c, 3}); %#ok<AGROW>
                    end
                end
                r.status = 'written';
                r.message = plan.summary;
                rep(end+1) = r; %#ok<AGROW>
                pending(end+1) = numel(rep); %#ok<AGROW>
            catch ME
                r.status = 'failed';
                r.message = ME.message;
                rep(end+1) = r; %#ok<AGROW>
            end
        end

        if ~isempty(pending)
            wb.Save();
            if ~wb.Saved
                error('backfillTrainingLog:notSaved', ...
                    'Excel reported the workbook still has unsaved changes after Save.');
            end
        end
        if ~attached
            wb.Close(false);
        end
        wb = [];

        if ~isempty(pending)
            T.verifyEntries(Excel, xlsFile, entries);
            for p = pending
                rep(p).status = 'written and verified';
            end
        end
    catch ME
        try, if ~isempty(wb) && ~attached, wb.Close(false); end, catch, end
        msg = ME.message;
        if attached
            msg = [msg ' (The workbook open in Excel may contain unsaved changes from this attempt.)'];
        end
        % mark everything in this workbook that hadn't already failed/been skipped
        done = {rep.animal};
        for j = 1:numel(group)
            k = find(strcmp(done, group(j).animal), 1);
            if isempty(k)
                r = newReport(group(j).animal);
                r.file = fileLabel(xlsFile);
                rep(end+1) = r; %#ok<AGROW>
                k = numel(rep);
            end
            if any(strcmp(rep(k).status, {'written', ''}))
                rep(k).status = 'failed';
                rep(k).message = msg;
            end
        end
    end
end

function plan = planAnimal(T, sheet, L, sessions)
% Decide what to write for one animal without changing the sheet.
%   fill      - session row missing, or present but with no performance data
%   skip      - session row already has performance data
%   date-only - day between first and last data day with no data and no row
    items = struct('dn', {}, 'n', {}, 'isDateOnly', {}, 'metrics', {});
    nSkip = 0;
    fillDates = [];
    for s = 1:numel(sessions)
        S = sessions(s);
        rows = find(abs(L.dateNums - S.dn) < 0.5) + (L.firstDataRow - 1);
        if numel(rows) >= S.n && T.rowHasPerformance(sheet, L, rows(S.n))
            nSkip = nSkip + 1;
            continue
        end
        items(end+1) = struct('dn', S.dn, 'n', S.n, 'isDateOnly', false, ...
                              'metrics', S.metrics); %#ok<AGROW>
        fillDates(end+1) = S.dn; %#ok<AGROW>
    end

    dataDays = unique([sessions.dn]);
    dateOnly = [];
    for d = min(dataDays):max(dataDays)
        if ismember(d, dataDays), continue, end
        if any(abs(L.dateNums - d) < 0.5), continue, end
        dateOnly(end+1) = d; %#ok<AGROW>
        items(end+1) = struct('dn', d, 'n', 1, 'isDateOnly', true, ...
                              'metrics', containers.Map()); %#ok<AGROW>
    end

    if ~isempty(items)
        key = [items.dn] * 1000 + [items.n];
        [~, order] = sort(key);
        items = items(order);
    end

    plan.items = items;
    plan.nSkip = nSkip;
    plan.fillDates = fillDates;
    plan.dateOnly = dateOnly;
    plan.summary = sprintf('filled %d session(s), added %d date-only row(s), %d already logged', ...
        numel(fillDates), numel(dateOnly), nSkip);
end

function q = previewText(animal, file, sheetName, plan)
    q = {sprintf('%s  ->  %s, sheet "%s"', animal, file, sheetName), ''};
    q{end+1} = sprintf('Fill %d session(s): %s', numel(plan.fillDates), dateList(unique(plan.fillDates)));
    q{end+1} = sprintf('Add %d date-only row(s): %s', numel(plan.dateOnly), dateList(plan.dateOnly));
    q{end+1} = sprintf('Already logged (left alone): %d session(s)', plan.nSkip);
    q{end+1} = '';
    q{end+1} = 'Existing values are never overwritten. Continue?';
end

function s = dateList(dns)
    if isempty(dns), s = 'none'; return, end
    parts = arrayfun(@(d) datestr(d, 'mm/dd'), dns, 'UniformOutput', false);
    if numel(parts) > 12
        parts = [parts(1:12) {sprintf('... (+%d more)', numel(parts) - 12)}];
    end
    s = strjoin(parts, ', ');
end

function sessions = readSessions(T, dataDir, animal)
% Every <animal>\<yymmdd>\session_N folder with a performance.fig, with the
% metrics read from it (and maze / rig / reward size from sessionData.mat).
    sessions = struct('dn', {}, 'n', {}, 'metrics', {}, 'path', {});
    days = dir(fullfile(dataDir, animal));
    days = days([days.isdir] & ~cellfun(@isempty, regexp({days.name}, '^\d{6}$')));
    for d = 1:numel(days)
        dayPath = fullfile(dataDir, animal, days(d).name);
        sess = dir(fullfile(dayPath, 'session_*'));
        sess = sess([sess.isdir]);
        for s = 1:numel(sess)
            p = fullfile(dayPath, sess(s).name);
            figFile = fullfile(p, 'performance.fig');
            if ~exist(figFile, 'file'), continue, end

            v = struct('mouseNum', animal, 'date', days(d).name, 'sessionID', sess(s).name);
            matFile = fullfile(p, 'sessionData.mat');
            if exist(matFile, 'file')
                try
                    m = load(matFile, 'experName', 'ops', 'rewardSize');
                    if isfield(m, 'experName'),  v.exper = struct('name', m.experName); end
                    if isfield(m, 'ops') && isfield(m.ops, 'rigName'), v.ops = struct('rigName', m.ops.rigName); end
                    if isfield(m, 'rewardSize'), v.rewardSize = m.rewardSize; end
                catch
                    % unreadable .mat: fall back to the figure stats only
                end
            end

            f = [];
            try
                f = openfig(figFile, 'invisible');
                v.performanceFig = f;
                metrics = T.gatherMetrics(v);
            catch ME
                if ~isempty(f), try, close(f); catch, end, end
                warning('backfillTrainingLog:badFig', 'Skipping %s: %s', figFile, ME.message);
                continue
            end
            close(f);

            sessions(end+1) = struct('dn', datenum(days(d).name, 'yymmdd'), ...
                'n', T.sessionNumber(sess(s).name), 'metrics', metrics, 'path', p); %#ok<AGROW>
        end
    end
end

function names = listAnimals(dataDir)
% Animal folders = folders that contain at least one yymmdd day folder.
    d = dir(dataDir);
    d = d([d.isdir] & ~startsWith({d.name}, '.'));
    names = {};
    for i = 1:numel(d)
        if ~isempty(regexp(d(i).name, '^\d{6}$', 'once')), continue, end   % stray date folder
        sub = dir(fullfile(dataDir, d(i).name));
        if any([sub.isdir] & ~cellfun(@isempty, regexp({sub.name}, '^\d{6}$')))
            names{end+1} = d(i).name; %#ok<AGROW>
        end
    end
    names = sort(names);
end

function r = newReport(animal)
    r = struct('animal', animal, 'file', '', 'status', '', 'filled', 0, ...
               'skipped', 0, 'dateRows', 0, 'message', '');
end

function s = fileLabel(xlsFile)
    parts = regexp(xlsFile, '[\\/]', 'split');
    s = strrep(parts{end}, '%20', ' ');
end

function lines = summaryLines(report)
    lines = {'Training log backfill summary', ''};
    for i = 1:numel(report)
        r = report(i);
        head = sprintf('%s: %s', r.animal, upper(r.status));
        if ~isempty(r.file), head = sprintf('%s  (%s)', head, r.file); end
        lines{end+1} = head; %#ok<AGROW>
        if startsWith(r.status, 'written')
            lines{end+1} = sprintf('    filled %d session(s), added %d date-only row(s), %d already logged', ...
                r.filled, r.dateRows, r.skipped); %#ok<AGROW>
        elseif ~isempty(r.message)
            lines{end+1} = ['    ' r.message]; %#ok<AGROW>
        end
    end
    if numel(report) == 0
        lines{end+1} = 'Nothing was processed.';
    end
end
