% Simple Teensy connection example

function vr = initTeensy(vr)
    delete(instrfindall);
    baudRate = 9600;
    vr.teensy = connectToTeensy(@messageHandler, baudRate, vr);
end

function messageHandler(msg)
	%fprintf('Recived message: %s\n', msg)
end
