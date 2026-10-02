% Simple Teensy connection example

function vr = initTeensy(vr)
    warnState = warning('off','instrument:instrfindall:FunctionToBeRemoved'); % TODO: migrate to serialportfind
    delete(instrfindall);
    warning(warnState);
    baudRate = 9600;
    vr.teensy = connectToTeensy(@messageHandler, baudRate, vr);
end

function messageHandler(msg)
	%fprintf('Recived message: %s\n', msg)
end
