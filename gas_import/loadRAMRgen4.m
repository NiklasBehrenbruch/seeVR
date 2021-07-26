function [corrvec_CO2,corrvec_O2] = loadRAMRgen4(opts)
%written by Alex Bhogal a.bhogal@umcutrecht.nl
%functions to load respiract endtidal traces from 3rd generation respiract
%system. Input is path to directory where gas traces are saved. Output is
%resampled O2 and CO2 traces at the desired sampling frequency (TR of scan)
global opts;
cd(opts.seqpath)

if isfield(opts,'extra'); else; opts.extra = 30; end                     %defines number of extra samples taken before and after the start and end of the events
if isfield(opts,'remOUT'); else; opts.remOUT = 0; end                   %remove outliers from breathing traces
if isfield(opts,'remOUTbh'); else; opts.remOUTbh = 0; end               %for breath hold, only outliers below the baseline are removed
if isfield(opts,'remOUTmethod'); else; opts.remOUTmethod = 'median'; end %'median' or 'mean' or 'quartiles' or 'grubbs' or 'gesd'
  
    
%Import EndTidal
file = ls('EndTidal.*')
filename = [opts.seqpath,'/',file];
[MRTimes,DesiredPO2mmHg,DesiredPCO2mmHg,AchievablePO2mmHg,AchievablePCO2mmHg,PO2mmHg,PCO2mmHg,RestingPO2mmHg,RestingPCO2mmHg,PBarommHg,Inspiretimeseconds,Expiretimeseconds,Breathidx,TidalvolumemL,RespirationrateBPM,StartInspiresec,O2AdjustmentmmHg,CO2AdjustmentmmHg,G1TargetvolmL,G1FCO2,G1FO2,G2FCO2,G2FO2] = import_EndTidal(filename);

%import RGM
file = ls('RGM.*')
filename = [opts.seqpath,'/',file];
[MRTimes1,PO2mmHg1,PCO2mmHg1,PBarommHg1,PMouthmmH2O,FlowMouthmLmin,FlowS1mLmin,FlowS2mLmin,BreathPhase] = import_RGM(filename);

%import events
file = ls('Events.*')
filename = [opts.seqpath,'/',file];
[MRTimes3, CtrlRoomTimes, Event] = import_Events(filename);

%import physiological parameters
file = ls('PhysioParams.*')
filename = [opts.seqpath,'/',file];
[MRTimes2, ID, FRCmL, VdmL, TissuestoreO2mL, TissuestoreCO2mL, VO2mLmin, VCO2mLmin, QmLmin, hBconcentrationgdLBlood, Restingmetabolicscalefactor, ResponseReason] = import_Physio(filename)

% resample and realign the breathing trace and the Endtidal trace to have the same start and end and same sampling rate

[nxi,corrvec_CO2,corrvec_O2,nxi1,rawCO2,rawO2] = resampleEndtidalBreathing(MRTimes,PCO2mmHg,PO2mmHg,MRTimes1,PCO2mmHg1,PO2mmHg1,MRTimes3,Event,opts)

end

