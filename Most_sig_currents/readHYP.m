function [Net_t , PIN_t ,  PIN_dev , VIA_t , Device_t , Layers_t , Padstack] = readHYP(filename)
%Reading HYP file 
fid = fopen ( filename , 'r');
% read the file
if fid == -1
    disp([file_name ' not found'])
    return;
end
txt = fgets(fid);
i=1;
while txt>0
    file{i} = txt;
    txt = fgets(fid);
    i = i + 1;
end
fclose(fid);

% extract the tracks
i = 1;
Device_count = 0;
track_count = 0;
PIN_count = 0;
VIA_count = 0;
PAD_count = 0;
%track = [];
while i < length(file)
    if length(file{i}) > 1
      %Extracting layer
      if strfind(file{i}, 'STACKUP')
          no_L = 0;
          while strfind(file{i+1} , 'M=') 
            i = i + 1;
            no_L = no_L + 1;
            %first entry is layer name , second entry is layer thickness
            [ Layers(no_L , 1) , Layers(no_L , 2)] = parse_layer(file{i});
          end
          %Extracting Devices
      elseif  strfind(file{i}, 'DEVICES')
          while strfind(file{i+1} , 'REF')
            i = i + 1;
            Device_count = Device_count + 1;
            %first entry is device name , second entry is layer of device
            [Device(Device_count , 1), Device(Device_count , 2)] = parse_Dev(file{i});
             
          end
          %extracting Nets
      elseif strfind(file{i}, 'NET')
          pos = strfind(file{i} , 'NET');
          net = file{i}(pos+4 : end);
          %i = i + 1;
          while ~(isempty(strfind(file{i+1} , 'X')) && isempty( strfind(file{i+1} , 'Y')))
          if strfind(file{i+1} , 'SEG')
              i = i + 1;
              track_count = track_count + 1;
              [x1 y1 x2 y2 layer] = parse_line(file{i}); 
              %1st and 2nd are the x , y coordinate for the start
              %3rd and 4th are the x , y coordinates for the end 
              %5th is net name, 6th is layer name
              Net(track_count , 1) = num2cell(x1); Net(track_count , 2) = num2cell(y1);
              Net(track_count , 3) = num2cell(x2); Net(track_count , 4) = num2cell(y2);
              Net(track_count , 5) = cellstr(net);
              Net(track_count , 6) = layer;
              
          elseif strfind(file{i+1} , 'PIN')
           i = i + 1;
           PIN_count = PIN_count + 1;
           [x , y , device , padstack] = parse_PIN(file{i});
           PIN(PIN_count , 1) = num2cell(x);
           PIN(PIN_count , 2) = num2cell(y);
           PIN_dev(PIN_count , 1) = cellstr(device);
           PIN_dev(PIN_count , 2) = cellstr(Net(end , 5));
           PIN(PIN_count , 3) = num2cell(padstack);
           
          elseif strfind(file{i+1} , 'VIA')
           i = i + 1;
           VIA_count = VIA_count + 1;
           [x , y , padstack] = parse_VIA(file{i});
           %1st, 2nd entries are the x , y coordinates , 3rd is the
           %padstack number
           VIA(VIA_count , 1) = num2cell(x);
           VIA(VIA_count , 2) = num2cell(y);
           VIA(VIA_count , 3) = num2cell(padstack);
          else
              i = i + 1;
          end
          end
      elseif strfind(file{i} , 'PADSTACK=')
          PAD_pos = strfind(file{i} , 'PADSTACK=');
          c_pos = strfind(file{i} , ',');
          c2_pos = strfind(file{i+1} , '",');
          if isempty(c2_pos)
               i = i + 1;
              continue
          else
            PAD_count = PAD_count + 1;
            %1st is padstack number , 2nd is padstack position
            Padstack(PAD_count , 1) = num2cell(str2double(file{i}(PAD_pos+9 : c_pos-1)));
            Padstack(PAD_count , 2) = cellstr(file{i+1}(5 : c2_pos-1));
            i = i + 1;
          end
      else
          i = i + 1;
    end
end


end
z = 0 ;
for c = length(Layers) : -1 : 1
    m = length(Layers) - c + 1;
    %first is layer position in z , secomd is layer name
    z = z + str2double(Layers(c , 2));
    Layers_t(m , 1) = num2cell(z);
    Layers_t(m , 2) = Layers(c , 1);
end

%%Transfer of data to 3d %%
%For nets
for s = 1 : length (Net)
   ind = find(ismember(Layers_t(: , 2) , Net(s , 6)));
   zz = Layers_t(ind , 1);
   %1 , 2 , 3 are x , y , z of start , 4 , 5 , 6 are x , y , z of end , 7
   %net name
   Net_t(s , :) = [Net(s , 1:2) , zz , Net(s , 3:4) , zz , Net{s , 5}];
end
% For Devices
for s = 1 : length(Device)
   ind = find(ismember(Layers_t(: , 2) , Device(s , 2)));
   zz = Layers_t(ind , 1);
   %1 iis device name , 2 is position in z
   Device_t(s , :) = [Device{s , 1} , zz ];
end
%For pins(assuming they are through holes)
for s = 1: length(PIN)
    %1 , 2 ,3 are x , y , z for start , 4 , 5 ,6 for ends , 7 is device leg
    %connevted to it , 8 is padstack number
    PIN_t(s , :) = [PIN(s , 1:2) , Layers_t(1 , 1) , PIN(s, 1:2) , Layers_t(end , 1) , PIN(s , 3)] ;
end
%For vias (assuming they are through holes)
for s = 1: length(VIA)
    %1 , 2 ,3 are x , y , z for start , 4 , 5 ,6 for ends , 7 is padstack number
    VIA_t(s , :) = [VIA(s , 1:2) , Layers_t(1 , 1) , VIA(s, 1:2) , Layers_t(end , 1) , VIA(s , 3)] ;
end

end
function [ Layer , thick] = parse_layer(line)
T_pos = strfind(line , 'T=');
P_pos = strfind(line , 'P=');
L_pos = strfind(line , 'L=');
M_pos = strfind(line , 'M=');
thick = cellstr(line(T_pos+2 : T_pos+9));
Layer = cellstr(line(L_pos+3 : M_pos-3));
end
function [x1 , y1 , x2 , y2 , Layer] = parse_line(line)
x1_pos = strfind(line , 'X1');
y1_pos = strfind(line , 'Y1');
x2_pos = strfind(line , 'X2');
y2_pos = strfind(line , 'Y2');
W_pos = strfind(line , 'W');
L_pos = strfind(line , 'L');
if isempty( x1_pos ) && isempty( y1_pos )
    x1 = NaN;
    y1 = NaN;
    x2 = NaN;
    y2 = NaN;
    Layer = NaN;
else
    x1 = str2double(line(x1_pos+3 : y1_pos-1));
    y1 = str2double(line(y1_pos+3 : x2_pos-1));
    x2 = str2double(line(x2_pos+3 : y2_pos-1));
    y2 = str2double(line(y2_pos+3 : W_pos-1));
    Layer = cellstr(line(L_pos+3 : end-4));
end

end
function [R , L] = parse_Dev(line)
R_pos = strfind(line , 'REF');
L_pos = strfind(line , 'L=');
if isempty( R_pos ) && isempty( L_pos )
    R = NaN;
    L = NaN;
else
    R = cellstr(line(R_pos+4 : L_pos-2));
    L = cellstr(line(L_pos+3 : end-4));
end
end
function [x , y , device , Padstack] = parse_PIN(line)
x_pos = strfind(line , 'X=');
y_pos = strfind(line , 'Y=');
R_pos = strfind(line , 'R=');
P_pos = strfind(line , 'P=');

x = str2double(line(x_pos+2 : y_pos-1));
y = str2double(line(y_pos+2 : R_pos-1));
device = line(R_pos+2 : P_pos-1);
Padstack = str2double(line(P_pos+2 : end-3));
end
function [x , y , Padstack] = parse_VIA(line)
x_pos = strfind(line , 'X=');
y_pos = strfind(line , 'Y=');
P_pos = strfind(line , 'P=');

x = str2double(line(x_pos+2 : y_pos-1));
y = str2double(line(y_pos+2 : P_pos-1));
Padstack = str2double(line(P_pos+2 : end-3));
end