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

    if nargin < 2, xlsFile = ''; end

    Excel = [];
    myPid = [];
    wb = [];
    attached = false;   % true -> wb belongs to the user's Excel: never close it
    try
        metrics = gatherMetrics(vr);   % containers.Map: Excel header -> value

        % grab the user's running Excel (if any) BEFORE starting our own, so we
        % can't pick up our hidden instance by mistake
        % while the user's Excel is busy (cell in edit mode / dialog open) every
        % Excel automation call fails -- even on a brand-new hidden instance
        userExcel = waitForUserExcel();

        pidsBefore = excelPids();
        Excel = actxserver('Excel.Application');
        myPid = setdiff(excelPids(), pidsBefore);   % our hidden instance, for cleanup
        set(Excel, 'DisplayAlerts', false);

        % ---- 1. Find this animal's tracking workbook ---------------------
        if isempty(xlsFile)
            if ~isfield(vr, 'ops') || ~isfield(vr.ops, 'trainingLogURL') || isempty(vr.ops.trainingLogURL)
                error('writePerformanceToExcel:noURL', ...
                    'ops.trainingLogURL is not set for this rig (see getRigInfo.m).');
            end
            xlsFile = resolveTrackingLog(Excel, vr.ops.trainingLogURL, vr.mouseNum);
        end

        wb = findOpenWorkbook(userExcel, xlsFile);
        attached = ~isempty(wb);
        if ~attached
            wb = openWorkbook(Excel, xlsFile, false);
        end
        if wb.ReadOnly
            if attached
                error('writePerformanceToExcel:readOnly', ...
                    ['%s is open read-only in Excel on this computer. Close it (or click ' ...
                     '"Enable Editing") and re-run.'], xlsFile);
            end
            error('writePerformanceToExcel:readOnly', ...
                ['%s opened read-only, so it cannot be saved. It is probably open and ' ...
                 'locked in another Excel (another computer with AutoSave off, or a ' ...
                 'leftover hidden EXCEL.EXE in Task Manager), or Excel is not signed in ' ...
                 'to SharePoint.'], xlsFile);
        end

        sheet = findAnimalSheet(wb, vr.mouseNum);

        used   = sheet.UsedRange;
        nCols  = used.Columns.Count;
        nRows  = used.Rows.Count;
        headerRow    = 1;
        firstDataRow = headerRow + 1;

        % header text -> column index
        headers = sheet.Range(['A' num2str(headerRow) ':' colLetter(nCols) num2str(headerRow)]).Value;
        if ~iscell(headers), headers = {headers}; end
        colOf = containers.Map('KeyType', 'char', 'ValueType', 'double');
        for c = 1:numel(headers)
            h = headers{c};
            if ischar(h) && ~isempty(strtrim(h))
                colOf(normalizeHeader(h)) = c;
            end
        end

        dateCol = lookupCol(colOf, 'Date');
        if isnan(dateCol)
            error('writePerformanceToExcel:noDateCol', ...
                'Could not find a "Date" column in sheet "%s".', char(sheet.Name));
        end

        % ---- find/insert the target row -----------------------------------
        targetDatenum = datenum(vr.date, 'yymmdd');
        sessionN      = sessionNumber(vr.sessionID);

        % read the Date column (COM returns date cells as display strings)
        dateNums = [];
        if nRows >= firstDataRow
            dcol = colLetter(dateCol);
            dv = sheet.Range([dcol num2str(firstDataRow) ':' dcol num2str(nRows)]).Value;
            dateNums = parseDateColumn(dv);   % NaN where empty/unparseable
        end

        % rows (absolute sheet row numbers) whose date matches this session
        matchRel = find(abs(dateNums - targetDatenum) < 0.5);
        matchAbs = matchRel + (firstDataRow - 1);

        if numel(matchAbs) >= sessionN
            targetRow = matchAbs(sessionN);
            newRow = false;
        else
            if ~isempty(matchAbs)
                insertAfter = matchAbs(end);
            else
                earlier = find(dateNums < targetDatenum, 1, 'last');
                if ~isempty(earlier)
                    insertAfter = earlier + (firstDataRow - 1);
                else
                    lastData = find(~isnan(dateNums), 1, 'last');
                    if isempty(lastData)
                        insertAfter = headerRow;   % empty sheet: write just below header
                    else
                        insertAfter = lastData + (firstDataRow - 1);
                    end
                end
            end
            nToInsert = sessionN - numel(matchAbs);
            for k = 1:nToInsert
                insertRowBelow(sheet, insertAfter + k - 1, nCols);
            end
            targetRow = insertAfter + nToInsert;
            newRow = true;
        end

        % cells written this session, for read-back verification: {col, value, label}
        written = cell(0, 3);

        % stamp the date on a freshly created row
        if newRow
            excelSerial = targetDatenum - datenum(1899, 12, 30);
            setCell(sheet, targetRow, dateCol, excelSerial);
            sheet.Range(a1(targetRow, dateCol)).NumberFormat = 'm/d/yyyy';
            written(end+1, :) = {dateCol, excelSerial, 'Date'};
        end

        % ---- write metric cells ------------------------------------------
        keysList = keys(metrics);
        for i = 1:numel(keysList)
            hdr = keysList{i};
            if strcmp(hdr, 'Date'), continue, end
            col = lookupCol(colOf, hdr);
            if isnan(col), continue, end    % this workbook has no such column
            setCell(sheet, targetRow, col, metrics(hdr));
            written(end+1, :) = {col, metrics(hdr), hdr}; %#ok<AGROW>
        end

        sheetName = char(sheet.Name);
        wb.Save();
        if ~wb.Saved
            error('writePerformanceToExcel:notSaved', ...
                'Excel reported the workbook still has unsaved changes after Save.');
        end
        if ~attached
            wb.Close(false);
        end
        wb = [];

        % ---- 2. Re-open read-only and verify what was saved ---------------
        verifyWritten(Excel, xlsFile, sheetName, targetRow, written);

        quitExcel(Excel, myPid);
        Excel = [];

        % ---- 3. Confirm -----------------------------------------------------
        msg = successMessage(xlsFile, sheetName, targetRow, vr, written);
        if attached
            msg{end+1} = '';
            msg{end+1} = '(Written into the copy already open in Excel; it was left open.)';
        end
        fprintf('%s\n', strjoin(msg, newline));
        msgbox(msg, 'Session logged', 'help', 'non-modal');

    catch ME
        try, if ~isempty(wb) && ~attached, wb.Close(false);    end, catch, end
        if ~isempty(Excel), quitExcel(Excel, myPid); end
        if isempty(xlsFile), where = 'the tracking spreadsheet'; else, where = xlsFile; end
        reason = ME.message;
        if isExcelBusy(ME) && ~strcmp(ME.identifier, 'writePerformanceToExcel:busy')
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

function xlsFile = resolveTrackingLog(Excel, baseURL, mouseNum)
% Look mouseNum up in column A of every sheet of Tracking_Log_FilenameSpreadsheet
% and return the URL of the workbook named in column B.
    masterName = 'Tracking_Log_FilenameSpreadsheet.xlsx';
    baseURL = normalizeBaseURL(baseURL);
    mouseID = idString(mouseNum);

    masterURL = [baseURL '/' masterName];
    mwb = openWorkbook(Excel, masterURL, true);
    files = {};
    people = {};
    try
        for s = 1:mwb.Sheets.Count
            sh = mwb.Sheets.Item(s);
            used = sh.UsedRange;
            lastRow = used.Row + used.Rows.Count - 1;
            if lastRow < 2, continue, end
            v = sh.Range(['A2:B' num2str(lastRow)]).Value;
            if ~iscell(v), v = {v}; end
            for r = 1:size(v, 1)
                if ~isempty(mouseID) && strcmpi(idString(v{r, 1}), mouseID)
                    f = idString(v{r, 2});
                    if ~isempty(f)
                        files{end+1} = f;                 %#ok<AGROW>
                        people{end+1} = char(sh.Name);    %#ok<AGROW>
                    end
                end
            end
        end
    catch ME
        mwb.Close(false);
        rethrow(ME);
    end
    mwb.Close(false);

    if isempty(files)
        error('writePerformanceToExcel:animalNotFound', ...
            'Animal "%s" was not found in column A of any sheet of %s.', ...
            idString(mouseNum), masterName);
    end
    if numel(unique(lower(files))) > 1
        error('writePerformanceToExcel:animalAmbiguous', ...
            'Animal "%s" is listed with different files in %s (sheets: %s; files: %s).', ...
            idString(mouseNum), masterName, strjoin(people, ', '), strjoin(files, ', '));
    end

    fname = files{1};
    if isempty(regexpi(fname, '\.xls[xm]?$', 'once'))
        fname = [fname '.xlsx'];
    end
    xlsFile = [baseURL '/' strrep(fname, ' ', '%20')];
end

function u = normalizeBaseURL(u)
% Tolerate a pasted "Copy path" (trailing filename, ?web=1, trailing slash, spaces).
    u = strtrim(char(u));
    u = regexprep(u, '\?.*$', '');
    u = regexprep(u, '/[^/]*\.xls[xm]?$', '', 'ignorecase');
    u = regexprep(u, '/+$', '');
    u = strrep(u, ' ', '%20');
end

function s = idString(x)
% Cell value / mouse ID as a trimmed char (numbers formatted without decimals noise).
    if isnumeric(x) || islogical(x)
        if isempty(x) || any(isnan(x)), s = ''; else, s = num2str(x, '%.15g'); end
    elseif ischar(x) || isstring(x)
        s = strtrim(char(x));
    else
        s = '';
    end
end

% NOTE: calls on the Excel *Application* object use get/set/invoke rather than
% dot syntax. If MATLAB first meets an Excel Application while Excel is busy, it
% caches an empty property list for that class and dot syntax (xl.Workbooks,
% xl.DisplayAlerts, ...) keeps failing for the rest of the MATLAB session -- even
% on new instances -- while get/set/invoke work again once Excel is free.

function wb = openWorkbook(Excel, file, readOnly)
    wb = invoke(get(Excel, 'Workbooks'), 'Open', file, 0, readOnly);
end

function xl = runningExcel()
% The user's already-running Excel, or [] if none.
    xl = [];
    try, xl = actxGetRunningServer('Excel.Application'); catch, end
end

function wb = findOpenWorkbook(xl, xlsFile)
% The workbook in Excel instance xl whose path/URL matches xlsFile, or [].
    wb = [];
    if isempty(xl), return, end
    target = canonName(xlsFile);
    try
        wbs = get(xl, 'Workbooks');
        for i = 1:get(wbs, 'Count')
            w = invoke(wbs, 'Item', i);
            if strcmp(canonName(w.FullName), target)
                wb = w;
                return
            end
        end
    catch ME
        % a busy Excel (cell in edit mode) rejects calls; report that rather than
        % falling through to a read-only copy
        if isExcelBusy(ME), rethrow(ME), end
    end
end

function s = canonName(p)
% Comparable form of a file path or SharePoint URL.
    s = lower(strrep(strtrim(char(p)), '\', '/'));
    s = strrep(s, '%20', ' ');
    s = regexprep(s, '\?.*$', '');
end

function tf = isExcelBusy(ME)
% Excel is in edit mode or showing a dialog. MATLAB reports the rejected COM call
% as "Unrecognized ... property ... for class 'COM.Excel_Application'" (or with
% the RPC_E_CALL_REJECTED / RETRYLATER codes).
    m = lower(ME.message);
    tf = contains(m, '0x80010001') || contains(m, '0x8001010a') || ...
         contains(m, 'call was rejected') || contains(m, 'retrylater') || ...
         (contains(m, 'unrecognized') && contains(m, 'com.excel_application'));
end

function xl = waitForUserExcel()
% The user's running Excel ([] if none). If it's busy, wait up to ~30 s for it to
% become responsive, then fail clearly.
    for t = 1:15
        xl = runningExcel();
        if isempty(xl), return, end
        try
            get(get(xl, 'Workbooks'), 'Count');   % any call fails while Excel is busy
            return
        catch ME
            if ~isExcelBusy(ME), xl = []; return, end   % unusable for another reason: ignore it
            if t == 1
                fprintf('Excel is busy (cell being edited?) -- press Enter or Esc in Excel...\n');
            end
            pause(2);
        end
    end
    error('writePerformanceToExcel:busy', ['Excel is busy (a cell is being ' ...
        'edited or a dialog is open). Press Enter or Esc in Excel, then re-run.']);
end

function p = excelPids()
% IDs of running EXCEL.EXE processes.
    p = [];
    try
        procs = System.Diagnostics.Process.GetProcessesByName('EXCEL');
        p = zeros(1, procs.Length);
        for i = 1:procs.Length
            p(i) = double(procs(i).Id);
        end
    catch
    end
end

function quitExcel(Excel, myPid)
% Quit our hidden Excel. If that fails, kill the process so it can't stay
% around holding the tracking log locked (which makes later sessions read-only).
    ok = false;
    try
        invoke(Excel, 'Quit');
        delete(Excel);
        ok = true;
    catch
    end
    if ~ok && isscalar(myPid)
        try
            System.Diagnostics.Process.GetProcessById(myPid).Kill();
        catch
        end
    end
end

function verifyWritten(Excel, xlsFile, sheetName, row, written)
% Re-open the saved workbook read-only and check every written cell. Retries a
% few times since a SharePoint upload can lag slightly behind Save.
    nTries = 3;
    for t = 1:nTries
        bad = readBackMismatches(Excel, xlsFile, sheetName, row, written);
        if isempty(bad), return, end
        if t < nTries, pause(5), end
    end
    error('writePerformanceToExcel:verifyFailed', ...
        'Saved file did not contain the expected values for: %s (sheet "%s", row %d).', ...
        strjoin(bad, ', '), sheetName, row);
end

function bad = readBackMismatches(Excel, xlsFile, sheetName, row, written)
    vwb = openWorkbook(Excel, xlsFile, true);
    bad = {};
    try
        sh = vwb.Sheets.Item(sheetName);
        for i = 1:size(written, 1)
            got  = sh.Range(a1(row, written{i, 1})).Value2;   % Value2: raw serial for dates
            want = written{i, 2};
            if isnumeric(want)
                ok = isnumeric(got) && ~isempty(got) && abs(got - want) <= 1e-6 * max(1, abs(want));
            else
                ok = ischar(got) && strcmp(strtrim(got), strtrim(char(want)));
            end
            if ~ok
                bad{end+1} = written{i, 3}; %#ok<AGROW>
            end
        end
    catch ME
        vwb.Close(false);
        rethrow(ME);
    end
    vwb.Close(false);
end

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

function metrics = gatherMetrics(vr)
% Read the "Performance Stats" text objects from the performance figure and map
% each to its Excel column header. Also add Maze name, Rig and Reward Size.
    metrics = containers.Map('KeyType', 'char', 'ValueType', 'any');

    % stat label on the plot -> Excel column header
    statToHeader = containers.Map( ...
        {'Time', 'Trials', 'Rewards', 'Trials/min', 'Rewards/min', ...
         '% Correct', '% Right'}, ...
        {'Time (min)', 'Trials', 'Rewards', 'Trials/min', 'Rewards/min', ...
         '% Correct', 'Fraction Right'});

    % read the stats text objects (tolerate mazes with no / a closed figure)
    txt = [];
    if isfield(vr, 'performanceFig')
        try, txt = findall(vr.performanceFig, 'Type', 'text'); catch, end
    end
    for i = 1:numel(txt)
        s = txt(i).String;
        if iscell(s)
            if isempty(s), continue, end
            s = s{1};
        end
        if ~ischar(s) || ~contains(s, ':')
            continue
        end
        parts = strsplit(s, ':');
        label = strtrim(parts{1});
        rest  = strtrim(strjoin(parts(2:end), ':'));
        if ~isKey(statToHeader, label)
            continue
        end
        tokens = regexp(rest, '[-+]?\d*\.?\d+', 'match');
        if isempty(tokens), continue, end
        val = str2double(tokens{1});
        % Time may be reported in seconds on some mazes; column is minutes
        if strcmp(label, 'Time') && ~isempty(regexpi(rest, '\ds\>', 'once')) ...
                && isempty(regexpi(rest, 'min', 'once'))
            val = val / 60;
        end
        metrics(statToHeader(label)) = val;
    end

    % Maze name: at runtime vr.exper is a virmenExperiment OBJECT (not a struct),
    % so isfield(vr.exper,'name') is false -- read .name defensively instead.
    mazeName = '';
    if isfield(vr, 'exper')
        try, mazeName = vr.exper.name; catch, end
    end
    if ~isempty(mazeName)
        metrics('Maze name') = char(mazeName);
    end
    r = rigNumber(vr);
    if ~isempty(r)
        metrics('Rig') = r;
    end

    % Reward size for the session (vr.rewardSize is a char key in uL, e.g. '4')
    if isfield(vr, 'rewardSize')
        rs = str2double(vr.rewardSize);
        if ~isnan(rs)
            metrics('Reward Size') = rs;
        end
    end
end

function n = rigNumber(vr)
% Numeric rig index from vr.ops.rigName (e.g. '..._rig1' -> 1), else ''.
    n = '';
    if isfield(vr, 'ops') && isfield(vr.ops, 'rigName')
        tok = regexp(vr.ops.rigName, '(\d+)\s*$', 'tokens', 'once');
        if ~isempty(tok)
            n = str2double(tok{1});
        end
    end
end

function sheet = findAnimalSheet(wb, mouseNum)
% Worksheet named exactly mouseNum (case-insensitive, surrounding spaces
% ignored). No partial matching, so data can't land in "JB10" when "JB1" is
% missing -- a missing sheet is an error instead.
    mouseNum = idString(mouseNum);
    n = wb.Sheets.Count;
    names = cell(1, n);
    for i = 1:n
        names{i} = char(wb.Sheets.Item(i).Name);
    end
    hit = find(strcmpi(strtrim(names), mouseNum), 1);
    if isempty(hit)
        error('writePerformanceToExcel:noSheet', ...
            'No sheet named "%s" in %s. Sheets in that file: %s', ...
            mouseNum, char(wb.Name), strjoin(names, ', '));
    end
    sheet = wb.Sheets.Item(hit);
end

function key = normalizeHeader(h)
    key = lower(regexprep(strtrim(char(h)), '\s+', ' '));
end

function col = lookupCol(colOf, header)
    key = normalizeHeader(header);
    if isKey(colOf, key)
        col = colOf(key);
        return
    end
    % Tolerant matching for headers that carry units / line breaks
    % (e.g. "Reward\nSize (uL)") which won't match exactly.
    ks = keys(colOf);
    switch key
        case 'reward size'
            col = firstMatch(colOf, ks, @(k) startsWith(strrep(k, ' ', ''), 'rewardsize'));
        otherwise
            col = NaN;
    end
end

function col = firstMatch(colOf, ks, pred)
    col = NaN;
    for i = 1:numel(ks)
        if pred(ks{i})
            col = colOf(ks{i});
            return
        end
    end
end

function n = sessionNumber(sessionID)
% Trailing integer from e.g. 'session_1'. Defaults to 1.
    n = 1;
    if ischar(sessionID) || isstring(sessionID)
        tok = regexp(char(sessionID), '(\d+)\s*$', 'tokens', 'once');
        if ~isempty(tok)
            n = str2double(tok{1});
        end
    end
end

function d = parseDateColumn(v)
% Convert a COM-read Date column (cell of char/number) into datenums (NaN where
% empty/unparseable).
    if isempty(v)
        d = [];
        return
    end
    if ~iscell(v), v = {v}; end
    d = nan(numel(v), 1);
    for i = 1:numel(v)
        x = v{i};
        if isempty(x)
            continue
        elseif isnumeric(x)
            d(i) = x + datenum(1899, 12, 30);   % Excel serial -> datenum
        elseif ischar(x)
            try
                d(i) = datenum(x);
            catch
                % leave NaN
            end
        end
    end
end

function insertRowBelow(sheet, aboveRow, nCols)
% Insert a blank row immediately below aboveRow, carrying down the row's cell
% FORMATS and any FORMULAS (so derived columns like PercentBaseline / Total
% water keep computing) -- but NOT literal values, so manual and per-session
% columns start blank.
    newRow = aboveRow + 1;
    sheet.Range([num2str(newRow) ':' num2str(newRow)]).Insert();

    % copy formatting from the row above
    src = sheet.Range([a1(aboveRow, 1) ':' a1(aboveRow, nCols)]);
    dst = sheet.Range([a1(newRow, 1)  ':' a1(newRow, nCols)]);
    src.Copy();
    dst.PasteSpecial(-4122);   % xlPasteFormats
    set(get(sheet, 'Application'), 'CutCopyMode', false);

    % carry down formula cells only (R1C1 keeps relative references correct);
    % literal-value cells are left blank
    for c = 1:nCols
        srcCell = sheet.Range(a1(aboveRow, c));
        if srcCell.HasFormula
            sheet.Range(a1(newRow, c)).FormulaR1C1 = srcCell.FormulaR1C1;
        end
    end
end

function setCell(sheet, row, col, value)
    sheet.Range(a1(row, col)).Value = value;
end

function ref = a1(row, col)
    ref = [colLetter(col) num2str(row)];
end

function s = colLetter(n)
    s = '';
    while n > 0
        r = mod(n - 1, 26);
        s = [char(65 + r) s]; %#ok<AGROW>
        n = floor((n - 1) / 26);
    end
end
