function T = trackingLogTools()
% trackingLogTools  Shared Excel/COM helpers for writing to the SharePoint
% behavior-tracking logs. Used by writePerformanceToExcel (end of each session)
% and backfillTrainingLog (filling in past days).
%
%   T = trackingLogTools();
%   xlsFile = T.resolveTrackingLog(Excel, ops.trainingLogURL, 'JB1');
%
% Tracking-log layout assumed: one sheet per animal (named exactly the animal
% ID), header row 1 with a "Date" column, one row per session ordered by date,
% and for each date session_1 in the first row with that date, session_2 in the
% second, etc.
%
% NOTE: calls on the Excel *Application* object use get/set/invoke rather than
% dot syntax. If MATLAB first meets an Excel Application while Excel is busy, it
% caches an empty property list for that class and dot syntax (xl.Workbooks,
% xl.DisplayAlerts, ...) keeps failing for the rest of the MATLAB session -- even
% on new instances -- while get/set/invoke work again once Excel is free.

    T.startExcel            = @startExcel;
    T.quitExcel             = @quitExcel;
    T.waitForUserExcel      = @waitForUserExcel;
    T.findOpenWorkbook      = @findOpenWorkbook;
    T.openWorkbook          = @openWorkbook;
    T.openForWriting        = @openForWriting;
    T.isExcelBusy           = @isExcelBusy;
    T.canonName             = @canonName;
    T.resolveTrackingLog    = @resolveTrackingLog;
    T.findAnimalSheet       = @findAnimalSheet;
    T.readLayout            = @readLayout;
    T.findOrInsertSessionRow = @findOrInsertSessionRow;
    T.rowHasPerformance     = @rowHasPerformance;
    T.writeMetrics          = @writeMetrics;
    T.verifyEntries         = @verifyEntries;
    T.gatherMetrics         = @gatherMetrics;
    T.sessionNumber         = @sessionNumber;
    T.idString              = @idString;
end

% ======================================================================
% Excel instances / workbooks

function [Excel, myPid] = startExcel()
% New hidden Excel instance, plus its process ID (for cleanup).
    pidsBefore = excelPids();
    Excel = actxserver('Excel.Application');
    myPid = setdiff(excelPids(), pidsBefore);
    set(Excel, 'DisplayAlerts', false);
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
% around holding a tracking log locked (which makes later opens read-only).
    if isempty(Excel), return, end
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

function xl = runningExcel()
% The user's already-running Excel, or [] if none.
    xl = [];
    try, xl = actxGetRunningServer('Excel.Application'); catch, end
end

function xl = waitForUserExcel()
% The user's running Excel ([] if none). If it's busy, wait up to ~30 s for it to
% become responsive, then fail clearly. Call this BEFORE startExcel, so our own
% hidden instance can't be picked up by mistake -- and because while the user's
% Excel is busy every Excel call fails, even on a brand-new hidden instance.
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
    error('trackingLog:busy', ['Excel is busy (a cell is being ' ...
        'edited or a dialog is open). Press Enter or Esc in Excel, then re-run.']);
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

function wb = openWorkbook(Excel, file, readOnly)
    wb = invoke(get(Excel, 'Workbooks'), 'Open', file, 0, readOnly);
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

function [wb, attached] = openForWriting(userExcel, Excel, xlsFile)
% Use the copy already open in the user's Excel if there is one (a second Excel
% process can only get it read-only); otherwise open it in our hidden Excel.
% Errors if the result is read-only.
    wb = findOpenWorkbook(userExcel, xlsFile);
    attached = ~isempty(wb);
    if ~attached
        wb = openWorkbook(Excel, xlsFile, false);
    end
    if wb.ReadOnly
        if attached
            error('trackingLog:readOnly', ...
                ['%s is open read-only in Excel on this computer. Close it (or click ' ...
                 '"Enable Editing") and re-run.'], xlsFile);
        end
        try, wb.Close(false); catch, end
        error('trackingLog:readOnly', ...
            ['%s opened read-only, so it cannot be saved. It is probably open and ' ...
             'locked in another Excel (another computer with AutoSave off, or a ' ...
             'leftover hidden EXCEL.EXE in Task Manager), or Excel is not signed in ' ...
             'to SharePoint.'], xlsFile);
    end
end

function s = canonName(p)
% Comparable form of a file path or SharePoint URL.
    s = lower(strrep(strtrim(char(p)), '\', '/'));
    s = strrep(s, '%20', ' ');
    s = regexprep(s, '\?.*$', '');
end

% ======================================================================
% Finding the animal's workbook and sheet

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
        error('trackingLog:animalNotFound', ...
            'Animal "%s" was not found in column A of any sheet of %s.', ...
            idString(mouseNum), masterName);
    end
    if numel(unique(lower(files))) > 1
        error('trackingLog:animalAmbiguous', ...
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
        error('trackingLog:noSheet', ...
            'No sheet named "%s" in %s. Sheets in that file: %s', ...
            mouseNum, char(wb.Name), strjoin(names, ', '));
    end
    sheet = wb.Sheets.Item(hit);
end

% ======================================================================
% Sheet layout, rows and cells

function L = readLayout(sheet)
% Header -> column map, Date column, and the date (datenum, NaN if blank) of
% every data row. Data rows start at row 2; L.dateNums(k) is sheet row k+1.
    used = sheet.UsedRange;
    L.nCols = used.Column + used.Columns.Count - 1;
    L.firstDataRow = 2;

    headers = sheet.Range(['A1:' colLetter(L.nCols) '1']).Value;
    if ~iscell(headers), headers = {headers}; end
    L.colOf = containers.Map('KeyType', 'char', 'ValueType', 'double');
    for c = 1:numel(headers)
        h = headers{c};
        if ischar(h) && ~isempty(strtrim(h))
            L.colOf(normalizeHeader(h)) = c;
        end
    end

    L.dateCol = lookupCol(L.colOf, 'Date');
    if isnan(L.dateCol)
        error('trackingLog:noDateCol', ...
            'Could not find a "Date" column in sheet "%s".', char(sheet.Name));
    end

    % columns this code writes: new rows don't inherit formulas there (a one-off
    % formula typed into e.g. Trials/min would otherwise spread into every
    % inserted row, showing #DIV/0! on date-only rows)
    L.loggedCols = L.dateCol;
    for h = loggedHeaders()
        c = lookupCol(L.colOf, h{1});
        if ~isnan(c), L.loggedCols(end+1) = c; end
    end
    L = refreshDates(sheet, L);
end

function L = refreshDates(sheet, L)
    used = sheet.UsedRange;
    lastRow = used.Row + used.Rows.Count - 1;
    L.dateNums = [];
    if lastRow >= L.firstDataRow
        dcol = colLetter(L.dateCol);
        dv = sheet.Range([dcol num2str(L.firstDataRow) ':' dcol num2str(lastRow)]).Value;
        L.dateNums = parseDateColumn(dv);   % COM returns date cells as display strings
    end
end

function rows = rowsForDate(L, dn)
% Sheet row numbers whose Date equals datenum dn, top to bottom.
    rows = find(abs(L.dateNums - dn) < 0.5) + (L.firstDataRow - 1);
end

function [row, isNew, L, dateEntry] = findOrInsertSessionRow(sheet, L, dn, sessionN)
% Row for the sessionN-th session on date dn. If the sheet has fewer rows for
% that date, rows are inserted (after the date's last row, or after the last
% earlier date) and every inserted row gets the date stamped, so later lookups
% count them. dateEntry is {col, serial, 'Date'} when the target row was new.
    matchAbs = rowsForDate(L, dn);
    dateEntry = {};
    if numel(matchAbs) >= sessionN
        row = matchAbs(sessionN);
        isNew = false;
        return
    end

    if ~isempty(matchAbs)
        insertAfter = matchAbs(end);
    else
        earlier = find(L.dateNums < dn, 1, 'last');
        if ~isempty(earlier)
            insertAfter = earlier + (L.firstDataRow - 1);
        else
            lastData = find(~isnan(L.dateNums), 1, 'last');
            if isempty(lastData)
                insertAfter = L.firstDataRow - 1;   % empty sheet: just below header
            else
                insertAfter = lastData + (L.firstDataRow - 1);
            end
        end
    end

    excelSerial = dn - datenum(1899, 12, 30);
    nToInsert = sessionN - numel(matchAbs);
    for k = 1:nToInsert
        r = insertAfter + k;
        insertRowBelow(sheet, r - 1, L.nCols, L.loggedCols);
        setCell(sheet, r, L.dateCol, excelSerial);
        sheet.Range(a1(r, L.dateCol)).NumberFormat = 'm/d/yyyy';
    end
    row = insertAfter + nToInsert;
    isNew = true;
    dateEntry = {L.dateCol, excelSerial, 'Date'};
    L = refreshDates(sheet, L);
end

function tf = rowHasPerformance(sheet, L, row)
% True if any of the core performance cells (Trials / Rewards / Time) has a value.
    tf = false;
    for h = {'Trials', 'Rewards', 'Time (min)'}
        col = lookupCol(L.colOf, h{1});
        if ~isnan(col) && ~isBlank(sheet.Range(a1(row, col)).Value2)
            tf = true;
            return
        end
    end
end

function written = writeMetrics(sheet, L, row, metrics, fillBlanksOnly)
% Write each metric into its column on row. With fillBlanksOnly, cells that
% already hold anything are left alone. Returns {col, value, label} per write.
    written = cell(0, 3);
    keysList = keys(metrics);
    for i = 1:numel(keysList)
        hdr = keysList{i};
        if strcmp(hdr, 'Date'), continue, end
        col = lookupCol(L.colOf, hdr);
        if isnan(col), continue, end    % this workbook has no such column
        if fillBlanksOnly && ~isBlank(sheet.Range(a1(row, col)).Value2)
            continue
        end
        setCell(sheet, row, col, metrics(hdr));
        written(end+1, :) = {col, metrics(hdr), hdr}; %#ok<AGROW>
    end
end

function tf = isBlank(v)
    tf = isempty(v) || (isnumeric(v) && isscalar(v) && isnan(v)) || ...
         (ischar(v) && isempty(strtrim(v)));
end

% ======================================================================
% Verification

function verifyEntries(Excel, xlsFile, entries)
% Re-open the saved workbook read-only and check every written cell. Each entry
% is a struct with fields sheet, dn (datenum), n (n-th row for that date), col,
% value, label. Rows are located by (date, n) rather than row number because
% later inserts can shift rows. Retries a few times since a SharePoint upload
% can lag slightly behind Save.
    if isempty(entries), return, end
    nTries = 3;
    for t = 1:nTries
        bad = readBackMismatches(Excel, xlsFile, entries);
        if isempty(bad), return, end
        if t < nTries, pause(5), end
    end
    if numel(bad) > 10, bad = [bad(1:10) {sprintf('... (%d total)', numel(bad))}]; end
    error('trackingLog:verifyFailed', ...
        'Saved file did not contain the expected values for: %s', strjoin(bad, '; '));
end

function bad = readBackMismatches(Excel, xlsFile, entries)
    vwb = openWorkbook(Excel, xlsFile, true);
    bad = {};
    try
        sheetNames = unique({entries.sheet});
        for s = 1:numel(sheetNames)
            sh = vwb.Sheets.Item(sheetNames{s});
            L = readLayout(sh);
            E = entries(strcmp({entries.sheet}, sheetNames{s}));
            for i = 1:numel(E)
                rows = rowsForDate(L, E(i).dn);
                where = sprintf('%s %s #%d %s', E(i).sheet, datestr(E(i).dn, 'mm/dd/yyyy'), E(i).n, E(i).label);
                if numel(rows) < E(i).n
                    bad{end+1} = [where ' (row missing)']; %#ok<AGROW>
                    continue
                end
                got  = sh.Range(a1(rows(E(i).n), E(i).col)).Value2;   % Value2: raw serial for dates
                want = E(i).value;
                if isnumeric(want)
                    ok = isnumeric(got) && ~isempty(got) && abs(got - want) <= 1e-6 * max(1, abs(want));
                else
                    ok = ischar(got) && strcmp(strtrim(got), strtrim(char(want)));
                end
                if ~ok
                    bad{end+1} = where; %#ok<AGROW>
                end
            end
        end
    catch ME
        vwb.Close(false);
        rethrow(ME);
    end
    vwb.Close(false);
end

% ======================================================================
% Session metrics (from the performance figure)

function h = loggedHeaders()
% Every column header gatherMetrics can produce.
    h = [statHeaders(), {'Maze name', 'Rig', 'Reward Size'}];
end

function h = statHeaders()
    h = {'Time (min)', 'Trials', 'Rewards', 'Trials/min', 'Rewards/min', ...
         '% Correct', 'Fraction Right'};
end

function metrics = gatherMetrics(vr)
% Read the "Performance Stats" text objects from the performance figure and map
% each to its Excel column header. Also add Maze name, Rig and Reward Size.
    metrics = containers.Map('KeyType', 'char', 'ValueType', 'any');

    % stat label on the plot -> Excel column header
    statToHeader = containers.Map( ...
        {'Time', 'Trials', 'Rewards', 'Trials/min', 'Rewards/min', ...
         '% Correct', '% Right'}, statHeaders());

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
% Rig column value from vr.ops.rigName: '..._rig1' -> 1, 'GreenLab_2P' -> '2P rig'
% (as the logs already write it), else ''.
    n = '';
    if isfield(vr, 'ops') && isfield(vr.ops, 'rigName')
        tok = regexp(vr.ops.rigName, 'rig(\d+)\s*$', 'tokens', 'once', 'ignorecase');
        if ~isempty(tok)
            n = str2double(tok{1});
        elseif ~isempty(regexpi(vr.ops.rigName, '2P\s*$', 'once'))
            n = '2P rig';
        end
    end
end

% ======================================================================
% Small utilities

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
            if ~isnan(x), d(i) = x + datenum(1899, 12, 30); end   % Excel serial -> datenum
        elseif ischar(x)
            try
                d(i) = datenum(x);
            catch
                % leave NaN
            end
        end
    end
end

function insertRowBelow(sheet, aboveRow, nCols, skipCols)
% Insert a blank row immediately below aboveRow, carrying down the row's cell
% FORMATS and any FORMULAS (so derived columns like PercentBaseline / Total
% water keep computing) -- but NOT literal values, so manual and per-session
% columns start blank. Columns in skipCols (the ones this code fills) get no
% formulas.
    if nargin < 4, skipCols = []; end
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
    for c = setdiff(1:nCols, skipCols)
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
