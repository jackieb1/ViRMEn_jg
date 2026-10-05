% runBackfill  Open this file and press Run (or type runBackfill) to fill in
% past days missing from the SharePoint training logs. See backfillTrainingLog.m.

addpath(fileparts(mfilename('fullpath')));   % make sure this folder is on the path
backfillTrainingLog;
