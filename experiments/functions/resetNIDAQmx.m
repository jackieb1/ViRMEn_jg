NET.addAssembly('NationalInstruments.DAQmx');
import NationalInstruments.DAQmx.*

devId = 'Dev1';  % update if yours is Dev2, etc.

% Get the Device object and reset it
sys = DaqSystem.Local;
dev = sys.LoadDevice(devId);   % returns a NationalInstruments.DAQmx.Device
dev.Reset();                   % hard reset releases all reservations

% (Optional sanity) quick self-test
dev.SelfTest();