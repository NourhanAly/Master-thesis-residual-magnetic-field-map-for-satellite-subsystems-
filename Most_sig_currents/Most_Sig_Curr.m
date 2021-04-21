function[Device_PIN , IO_Type , Current] = Most_Sig_Curr(FileName)
%Reading most significant current
Most_Sig = readtable(FileName);
Title = Most_Sig.Properties.VariableNames;
Device_PIN = Most_Sig.ComponentDesignator_PinDesignator;
IO_Type = Most_Sig.IOType;
Current = Most_Sig.Current_mA_;

for d = 1: length(Current)
    if strcmp(char(IO_Type(d)) , 'In')
        Current(d) = - Current(d);
    end
end
end