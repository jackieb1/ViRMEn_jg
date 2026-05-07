function vr = releaseAO(vr)
% releaseAO  Safely release NI-DAQmx AO hardware held by a .NET Task.
% 
% Usage:
%   vr = releaseAO(vr);
%
% Stops the task, drives AO to 0 V (if possible), unreserves hardware,
% disposes of the task, and clears vr.task / vr.writer fields if present.

    import NationalInstruments.DAQmx.*

    if isfield(vr,'task') && isa(vr.task,'NationalInstruments.DAQmx.Task')
        try
            % Stop task if running/armed
            if ~vr.task.IsDone
                vr.task.Stop();
            end
        catch, end

        % Force baseline (on-demand write only if Stream exists)
        try
            AnalogSingleChannelWriter(vr.task.Stream).WriteSingleSample(true, 0.0);
        catch, end

        % Unreserve and dispose
        try vr.task.Control(TaskAction.Unreserve); catch, end
        try vr.task.Dispose();                     catch, end
    end

    % Remove handles from struct so MATLAB doesn't hold references
    if isfield(vr,'writer'), vr = rmfield(vr,'writer'); end
    if isfield(vr,'task'),   vr = rmfield(vr,'task');   end
end