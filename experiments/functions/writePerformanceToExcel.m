function vr = writePerformanceToExcel(vr, xlsFile)
% writePerformanceToExcel  Write this session's performance metrics into the
% animal's behavior-tracking spreadsheet on SharePoint.
%
% At session end this looks the animal (vr.mouseNum) up in the master workbook
% Tracking_Log_FilenameSpreadsheet in the SharePoint "Training Logs" folder
% (vr.ops.trainingLogURL, set in getRigInfo.m). Each person has a sheet there with
% animal IDs in column A and the name of that animal's Tracking_Log_<Name> workbook
% (in the same folder) in column B. That workbook is opened and the values shown
% on the performance figure (vr.performanceFig) are written into the sheet for this
% animal on a row for this session. Sessions get one row each, ordered by session
% number within the date (session_1 = first row for the date, session_2 = second, ...).
%
% After saving, the workbook is re-opened read-only and the written cells are read
% back; a popup confirms success (or reports what went wrong).
%
% Values are read maze-agnostically from the "Performance Stats" text objects on
% the figure, so this works for wideLinearTrack, T-maze and linear-maze variants
% without per-maze code -- it only writes metrics that have a matching column.
%
% Uses Excel COM automation so the workbook's existing formatting and formula
% columns are preserved. Excel on the rig must be signed in to the org account
% so it can open the SharePoint URLs.
%
% If the tracking workbook is already open in Excel on this desktop, the row is
% written into that open copy and saved (it is left open). Otherwise a hidden
% Excel opens it. A second Excel process on the same machine can only get a
% read-only copy of a workbook that's already open, which is why the open copy
% is used directly.
%
% Optional second argument xlsFile (local path or URL) bypasses the master-sheet
% lookup (useful for testing / batch use).
%
% The Excel helpers live in trackingLogTools.m (shared with backfillTrainingLog).

    if nargin < 2, xlsFile = ''; end
    T = trackingLogTools();

    Excel = [];
    myPid = [];
    wb = [];
    attached = false;   % true -> wb belongs to the user's Excel: never close it
    try
        metrics = T.gatherMetrics(vr);   % containers.Map: Excel header -> value

        userExcel = T.waitForUserExcel();   % before starting our own hidden Excel
        [Excel, myPid] = T.startExcel();

        % ---- 1. Find this animal's tracking workbook ---------------------
        if isempty(xlsFile)
            if ~isfield(vr, 'ops') || ~isfield(vr.ops, 'trainingLogURL') || isempty(vr.ops.trainingLogURL)
                error('writePerformanceToExcel:noURL', ...
                    'ops.trainingLogURL is not set for this rig (see getRigInfo.m).');
            end
            xlsFile = T.resolveTrackingLog(Excel, vr.ops.trainingLogURL, vr.mouseNum);
        end

        [wb, attached] = T.openForWriting(userExcel, Excel, xlsFile);
        sheet = T.findAnimalSheet(wb, vr.mouseNum);
        sheetName = char(sheet.Name);
        L = T.readLayout(sheet);

        % ---- 2. Find/insert this session's row and write it ----------------
        dn       = datenum(vr.date, 'yymmdd');
        sessionN = T.sessionNumber(vr.sessionID);
        [targetRow, ~, L, dateEntry] = T.findOrInsertSessionRow(sheet, L, dn, sessionN);
        written = [dateEntry; T.writeMetrics(sheet, L, targetRow, metrics, false)];

        wb.Save();
        if ~wb.Saved
            error('writePerformanceToExcel:notSaved', ...
                'Excel reported the workbook still has unsaved changes after Save.');
        end
        if ~attached
            wb.Close(false);
        end
        wb = [];

        % ---- 3. Re-open read-only and verify what was saved ---------------
        entries = struct('sheet', sheetName, 'dn', dn, 'n', sessionN, ...
            'col', written(:, 1)', 'value', written(:, 2)', 'label', written(:, 3)');
        T.verifyEntries(Excel, xlsFile, entries);

        T.quitExcel(Excel, myPid);
        Excel = [];

        % ---- 4. Confirm -----------------------------------------------------
        msg = successMessage(xlsFile, sheetName, targetRow, vr, written);
        if attached
            msg{end+1} = '';
            msg{end+1} = '(Written into the copy already open in Excel; it was left open.)';
        end
        fprintf('%s\n', strjoin(msg, newline));
        msgbox(msg, 'Session logged', 'help', 'non-modal');

    catch ME
        try, if ~isempty(wb) && ~attached, wb.Close(false); end, catch, end
        T.quitExcel(Excel, myPid);
        if isempty(xlsFile), where = 'the tracking spreadsheet'; else, where = xlsFile; end
        reason = ME.message;
        if T.isExcelBusy(ME) && ~strcmp(ME.identifier, 'trackingLog:busy')
            reason = ['Excel is busy (a cell is being edited or a dialog is open). ' ...
                      'Press Enter or Esc in Excel, then re-run.'];
        end
        if attached
            reason = [reason sprintf(['\n\nThe workbook open in Excel may contain ' ...
                'partial, unsaved changes from this attempt -- check it before saving.'])];
        end
        msg = sprintf(['Session performance was NOT saved to %s.\n\n%s\n\n' ...
             'The performance.fig is still saved, so you can re-run ' ...
             'writePerformanceToExcel(vr) later.'], where, reason);
        warning('writePerformanceToExcel:failed', '%s', msg);
        errordlg(msg, 'Session NOT logged', 'non-modal');
    end
end

% ======================================================================

function msg = successMessage(xlsFile, sheetName, row, vr, written)
    parts = regexp(xlsFile, '[\\/]', 'split');
    fname = strrep(parts{end}, '%20', ' ');
    sess = '';
    if isfield(vr, 'sessionID'), sess = char(string(vr.sessionID)); end
    msg = {sprintf('Saved and verified: %s', fname), ...
           sprintf('Sheet "%s", row %d  (%s, %s)', sheetName, row, ...
                   datestr(datenum(vr.date, 'yymmdd'), 'mm/dd/yyyy'), sess), ''};
    for i = 1:size(written, 1)
        if strcmp(written{i, 3}, 'Date'), continue, end
        v = written{i, 2};
        if isnumeric(v), v = num2str(v, '%.4g'); end
        msg{end+1} = sprintf('%s: %s', written{i, 3}, v); %#ok<AGROW>
    end
end
