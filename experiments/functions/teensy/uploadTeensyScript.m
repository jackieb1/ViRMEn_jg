function [vr] = uploadTeensyScript_CA(vr)
%uploadTeensyScript writes initial variables in the file init_variables.h
%and uploads the script to the teensy

%Write the header file
fprintf('Writting init_variables.h...');
writeTeensyInitVar_CA(vr);
fprintf('Done! \n');

%Upload the sketch
fprintf('Uploading Arduino Sketch...');

answer = questdlg('Please upload arduino sketch and then click Done', ...
	'Upload arduino script', ...
	'Done','Done');
% Handle response
switch answer
    case 'Done'
    fprintf('Done uploading! \n'); 
end

% 
% vr.uploadFlag = uploadTeensySketch(vr.ops.arduinoSoftDir, vr.session.fullTeensySketchPath, 'COM7');
% if  ~(vr.uploadFlag == 0)
%     errordlg('ERROR UPLOADING ARDUINO SKETCH', 'ERROR UPLOADING ARDUINO SKETCH')
%     return;
% end
