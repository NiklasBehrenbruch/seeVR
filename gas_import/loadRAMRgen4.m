% Copyright (C) Alex A. Bhogal, 2021, University Medical Center Utrecht,
% a.bhogal@umcutrecht.nl
% <loadRAMRgen4: imports GEN4 RespirAct data >
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>. 

function [corrvec_CO2,corrvec_O2] = loadRAMRgen4(opts)
% This is the main function (used to call relevant sub-functions) to load
% the GEN4 respiratory data. This function can also perform outlier
% removal.

global opts;
cd(opts.seqpath)

if isfield(opts,'extra'); else; opts.extra = 30; end                    %defines number of extra samples taken before and after the start and end of the events
if isfield(opts,'remOUT'); else; opts.remOUT = 0; end                   %remove outliers from breathing traces
if isfield(opts,'remOUTbh'); else; opts.remOUTbh = 0; end               %for breath hold, only outliers below the baseline are removed
if isfield(opts,'remOUTmethod'); else; opts.remOUTmethod = 'median'; end %'median' or 'mean' or 'quartiles' or 'grubbs' or 'gesd'


%Import EndTidal
file = ls('EndTidal.*');
if ispc
    filename = [opts.seqpath,'\',file];
else
    file(:,end) = [];
    filename = [opts.seqpath,'/',file];
end

[MRTimes,DesiredPO2mmHg,DesiredPCO2mmHg,AchievablePO2mmHg,AchievablePCO2mmHg,PO2mmHg,PCO2mmHg,RestingPO2mmHg,RestingPCO2mmHg,PBarommHg,Inspiretimeseconds,Expiretimeseconds,Breathidx,TidalvolumemL,RespirationrateBPM,StartInspiresec,O2AdjustmentmmHg,CO2AdjustmentmmHg,G1TargetvolmL,G1FCO2,G1FO2,G2FCO2,G2FO2] = import_EndTidal(filename);

%import RGM
file = ls('RGM.*');
if ispc
    filename = [opts.seqpath,'\',file];
else
    file(:,end) = [];
    filename = [opts.seqpath,'/',file];
end
[MRTimes1,PO2mmHg1,PCO2mmHg1,PBarommHg1,PMouthmmH2O,FlowMouthmLmin,FlowS1mLmin,FlowS2mLmin,BreathPhase] = import_RGM(filename);

%import events
file = ls('Events.*');
if ispc
    filename = [opts.seqpath,'\',file];
else
    file(:,end) = [];
    filename = [opts.seqpath,'/',file];
end
[MRTimes3, CtrlRoomTimes, Event] = import_Events(filename);

%import physiological parameters
file = ls('PhysioParams.*');
if ispc
    filename = [opts.seqpath,'\',file];
else
    file(:,end) = [];
    filename = [opts.seqpath,'/',file];
end
[MRTimes2, ID, FRCmL, VdmL, TissuestoreO2mL, TissuestoreCO2mL, VO2mLmin, VCO2mLmin, QmLmin, hBconcentrationgdLBlood, Restingmetabolicscalefactor, ResponseReason] = import_Physio(filename);

% resample and realign the breathing trace and the Endtidal trace to have the same start and end and same sampling rate

[nxi,corrvec_CO2,corrvec_O2,nxi1,rawCO2,rawO2] = resampleEndtidalBreathing(MRTimes,PCO2mmHg,PO2mmHg,MRTimes1,PCO2mmHg1,PO2mmHg1,MRTimes3,Event,opts);

end

