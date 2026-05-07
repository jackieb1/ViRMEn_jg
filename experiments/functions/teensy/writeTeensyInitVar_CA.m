function writeTeensyInitVar_CA(vr)
%writeTeensyInitVar writes the following variables into the teensy code
vr.session = struct('teensySketch', 'quietOpRewSpkPhotoRig',...
    'fullTeensySketchPath', [vr.ops.teensyCodeDir filesep 'quietOpRewSpkPhotoRig' filesep 'quietOpRewSpkPhotoRig.ino']);

fileID = fopen([vr.ops.teensyCodeDir filesep vr.session.teensySketch filesep 'init_variables.h'],'w'); %create the output file
vr.exper.variables.durCorrTone = 0;
vr.exper.variables.durErrTone = 0;
vr.exper.variables.timeValv = 35;

string2print = 'const int durCorrTone = ';
string2print = [string2print num2str(vr.exper.variables.durCorrTone) ';'];
fprintf(fileID, '%s\n', string2print);

string2print = 'const int durErrTone = ';
string2print = [string2print num2str(vr.exper.variables.durErrTone) ';'];
fprintf(fileID, '%s\n', string2print);

string2print = 'const int timeValv = ';
string2print = [string2print num2str(vr.exper.variables.timeValv) ';'];
fprintf(fileID, '%s\n', string2print);

%% wrap up
fclose(fileID);
end