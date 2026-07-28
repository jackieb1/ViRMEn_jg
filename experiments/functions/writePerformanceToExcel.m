function vr = writePerformanceToExcel(vr, xlsFile, weightVal)
% writePerformanceToExcel  Write this session's performance metrics into the
% behavior-tracking spreadsheet.
%
% At session end this prompts the user to pick the tracking .xlsx, then writes
% the values shown on the performance figure (vr.performanceFig) into the sheet
% for this animal (vr.mouseNum) on a row for this session. Sessions get one row
% each, ordered by session number within the date (session_1 = first row for
% the date, session_2 = second, ...).
%
% Values are read maze-agnostically from the "Performance Stats" text objects on
% the figure, so this works for wideLinearTrack, T-maze and linear-maze variants
% without per-maze code -- it only writes metrics that have a matching column.
%
% Uses Excel COM automation so the workbook's existing formatting and formula
% columns are preserved.
%
% Optional second argument xlsFile bypasses the file-picker dialog (useful for
% testing / batch use).

    persistent lastDir
    if isempty(lastDir)
        lastDir = pwd;
    end
    if nargin < 3, weightVal = []; end   % [] -> prompt (interactive path) or leave blank

    % ---- 1. Pick the spreadsheet, then ask for the day's weight ---------
    if nargin < 2 || isempty(xlsFile)
        [fname, fpath] = uigetfile({'*.xlsx;*.xlsm', 'Excel workbook (*.xlsx, *.xlsm)'}, ...
            'Select behavior-tracking spreadsheet', lastDir);
        if isequal(fname, 0)
            warning('writePerformanceToExcel:cancelled', ...
                'No spreadsheet selected -- performance metrics were not saved to Excel.');
            return
        end
        lastDir = fpath;
        xlsFile = fullfile(fpath, fname);

        % prompt for the mouse's weight for the day (populates the Weight column)
        wans = inputdlg({'Mouse weight for today (g):'}, 'Enter weight', [1 40], {''});
        if ~isempty(wans)
            w = str2double(strtrim(wans{1}));
            if ~isnan(w), weightVal = w; end
        end
    end

    % ---- 2-6. Gather metrics and write to Excel via COM -----------------
    Excel = [];
    wb = [];
    try
        metrics = gatherMetrics(vr, weightVal);   % containers.Map: Excel header -> value

        Excel = actxserver('Excel.Application');
        Excel.DisplayAlerts = false;
        wb = Excel.Workbooks.Open(xlsFile);

        sheet = findAnimalSheet(wb, vr.mouseNum);
        if isempty(sheet)
            error('writePerformanceToExcel:noSheet', ...
                'No sheet selected for animal "%s".', vr.mouseNum);
        end

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

        % stamp the date on a freshly created row
        if newRow
            excelSerial = targetDatenum - datenum(1899, 12, 30);
            setCell(sheet, targetRow, dateCol, excelSerial);
            sheet.Range(a1(targetRow, dateCol)).NumberFormat = 'm/d/yyyy';
        end

        % ---- write metric cells ------------------------------------------
        keysList = keys(metrics);
        for i = 1:numel(keysList)
            hdr = keysList{i};
            if strcmp(hdr, 'Date'), continue, end
            col = lookupCol(colOf, hdr);
            if isnan(col), continue, end    % this workbook has no such column
            setCell(sheet, targetRow, col, metrics(hdr));
        end

        sheetName = char(sheet.Name);
        wb.Save();
        wb.Close(false);
        Excel.Quit();
        delete(Excel);
        fprintf('Performance metrics saved to %s (sheet "%s", row %d).\n', ...
            xlsFile, sheetName, targetRow);

    catch ME
        try, if ~isempty(wb),    wb.Close(false);              end, catch, end
        try, if ~isempty(Excel), Excel.Quit(); delete(Excel);  end, catch, end
        warning('writePerformanceToExcel:failed', ...
            ['Could not write to the spreadsheet (%s).\n' ...
             'Is the file open in Excel? The performance.fig is still saved, ' ...
             'so you can re-run later.\nDetails: %s'], xlsFile, ME.message);
    end
end

% ======================================================================

function metrics = gatherMetrics(vr, weightVal)
% Read the "Performance Stats" text objects from the performance figure and map
% each to its Excel column header. Also add Maze name, Rig, Reward Size and the
% day's Weight.
    if nargin < 2, weightVal = []; end
    metrics = containers.Map('KeyType', 'char', 'ValueType', 'any');

    % stat label on the plot -> Excel column header
    statToHeader = containers.Map( ...
        {'Time', 'Trials', 'Rewards', 'Trials/min', 'Rewards/min', ...
         '% Correct', '% Right'}, ...
        {'Time (min)', 'Trials', 'Rewards', 'Trials/min', 'Rewards/min', ...
         '% Correct', 'Fraction Right'});

    txt = findall(vr.performanceFig, 'Type', 'text');
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

    % Day's weight (entered via the prompt); leave blank if not provided
    if ~isempty(weightVal) && isnumeric(weightVal) && ~isnan(weightVal)
        metrics('Weight') = weightVal;
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
% Worksheet whose name starts with mouseNum (case-insensitive); if none or
% several match, ask the user to pick.
    sheet = [];
    mouseNum = char(string(mouseNum));
    n = wb.Sheets.Count;
    names = cell(1, n);
    for i = 1:n
        names{i} = char(wb.Sheets.Item(i).Name);
    end
    hit = find(strncmpi(names, mouseNum, numel(mouseNum)));
    if numel(hit) == 1
        sheet = wb.Sheets.Item(hit);
        return
    end
    [sel, ok] = listdlg('ListString', names, 'SelectionMode', 'single', ...
        'PromptString', sprintf('Pick the sheet for animal "%s":', mouseNum), ...
        'Name', 'Select animal sheet');
    if ok
        sheet = wb.Sheets.Item(sel);
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
    % (e.g. "Weight\n(g)", "Reward\nSize (uL)") which won't match exactly.
    ks = keys(colOf);
    switch key
        case 'weight'
            col = firstMatch(colOf, ks, @(k) startsWith(k, 'weight'));
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
    sheet.Application.CutCopyMode = false;

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
