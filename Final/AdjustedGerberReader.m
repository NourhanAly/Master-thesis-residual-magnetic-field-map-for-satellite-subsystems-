%%%%%%%%%%%%%%%%%%%%% General Information
%
% Parse a GERBER file to
%      - text file with coordinates
%      - odb++ xml file
%
% COMSOL can only import ODB(X)++ PCB tracks geometry.
% The facts is that many PCB design tools can't export ODB(X)++ (or
% the export function sucks).
%
% GERBER is the standard format for PCB tracks. Thus the function convert
% a GERBER file into a ODB(X)++ for COMSOL (or other software). A text
% file (space separated) value is also available.
%
% The function can changes to units, set a new origin, ...
%
%%%%%%%%%%%%%%%%%%%%% Export the GERBER file
%
% The procedure to export the GERBER file is explained for Altium
% Designer. But the code should also works with any PCB design tools that
% can export descent GERBER files.
%
% Altium Designer Summer 09 : export procedure
%    - File => Fabrication Outputs => Gerber Files
%    - Millimeters / 4:4
%    - Plot Top Layer and Bottom Layer
%    - No Drill Drawing
%    - Aperture : Embedded
%    - Separate file per layer / Suppress leading zeroes
%      Reference to relative origin / Sorted (vector)
%
% You can use a basic Gerber viewer to check the files that you exported:
%    - gerbv / gEDA
%    - GerbView / KiCad
%
%%%%%%%%%%%%%%%%%%%%% Convert the GERBER files using the MATLAB function
%
% INPUT:
% name - name of the gerber file (without extension, in the 'gerber' directory)
%                         - load ./gerber/name.GBL - bottom layer gerber file
%                         - load ./gerber/name.GTL - top layer gerber file
%
% geom - structure with geometry parameters (optional)
%                         - geom.b = thickness of the PCB [m] [default: 1.6e-3]
%                         - geom.bcu = thickness of the copper [m] [default: 35e-6]
%                         - geom.lcu = width of the copper [m] [default: 0.3e-3]
%
% center_ori - centering of the origin (optional)
%                         - false - keep the gerber origin
%                         - true  - compute a new origin in the middle [default]
%                         - [x y] - the new origin [mm]
%
% unit - conversion factor for output unit (mm : 1e-3 / cm : 1e-2) [default: mm/1e-3] (optional)
%
% output - type of the output (optional)
%                         - 'txt' - text file with the coordinates [default]
%                         - 'odb' - ODB(X)++ xml file
%
% pcb - vector [xmin xmax ymin ymax] for pcb layout if output=='odb' [mm], original coordinate
%
% OUTPUT FILES:
% ./layer/name/name_info.txt         - some infos about the export
%
% if output=='txt'
% ./layer/name/name_bottom_via.txt   - vias of the top layer
% ./layer/name/name_top_via.txt      - vias of the bottom layer
% ./layer/name/name_top_layer.txt    - tracks of the top layer
% ./layer/name/name_bottom_layer.txt - tracks of the bottom layer
%
% if output=='odb'
% ./layer/name/name_odb_layer.xml    - tracks in ODB(X)++ xml format
% ./layer/name/name_odb_via.xml      - vias in ODB(X)++ xml format
%
% FILES FORMAT:
%
% text files (space separated values):
%    - 'x1 y1 z1 x2 y2 z2'
%    - with (x1,y1,z1) and (x2,y2,z2) begin/end of the line
%
% odb++ xml files
%    - is not compliant to the ODB(X)++ standard but is suitable for COMSOL import
%    - top/bottom layers and vias on different files
%
% info file
%    - contains all the important informations about the export
%    - read it in order to detect errors
%
%%%%%%%%%%%%%%%%%%%%% Extra features
%
% The code computes the following parameters:
%    - the length of the tracks, the vias (usefull for resistance computation)
%    - the inductance of the tracks with a very simple approximation
%
% The following checks are made to ensure the integritiy of the export:
%    - check that the vias position is the same on the top and bottom layer
%    - check if there is any track with zero length
%    - check for duplicated tracks/vias
%
%%%%%%%%%%%%%%%%%%%%% Import the converted geometry in COMSOL
%
% Works for COMSOL 4.1 and 4.2 (and probably for 4.0).
%
% Look at the file "odb_import.mph" (COMSOL 4.2a file) to see an example.
%
% 1) In a 3D COMSOL model (unit in mm)
% 2) In the geometry, do "Import"
%    - choose "ECAD file (ODB++)"
%    - choose the file name_odb_layer.xml
%    - TOP.LAYER, set thickness to 0.035, import
%    - TOP.LAYER.DIEL, set thickness to 1.6, don't import
%    - BOTTOM.LAYER, set thickness to 0.035, import
%    - VIAS, set thickness to 0, import
% 3) In the geometry, do "Import"
%    - choose "ECAD file (ODB++)"
%    - choose the file name_odb_via.xml
%    - TOP.LAYER, set thickness to 0.035, don't import
%    - TOP.LAYER.DIEL, set thickness to 1.6, import
%    - BOTTOM.LAYER, set thickness to 0.035, don't import
%    - VIAS, set thickness to 0, import
% 3) In the geometry, do "Split
%    - select "imp1" and "imp2"
% 4) The geometry is ready, set the Physics, Mesh and Solve.
%
%%%%%%%%%%%%%%%%%%%%% Limitations
%
% This code has been written for importing a coil geometry (realised on a PCB).
% The layout from Altium Designer has been exported to COMSOL with this code.
% Since the coil is a rather simple layout, the code has many restrictions.
%
% But it would be easy to add the features that you need.
%
%    - Limitations on input GERBER files:
%        - only tested with output from Altium Designer Summer 09
%        - with GERBER files from other software, some adaptations are probably needed
%
%    - Limitations on output ODB(X)++ files:
%        - ODB(X)++ import has only been tested with COMSOL 4.1 and 4.2
%        - for others tools, some (small) adaptations may also be required
%
%    - Restrictions on geometry:
%        - accept only vias and tracks
%        - no pads, no components, no solder masks, ...
%        - only top/bottom layers
%        - no multi-layer
%
%    - Restrictions MATLAB code:
%        - works with MATLAB r2010a, r2010b, r2011a
%        - works on Windows/Linux
%        - doesn't require any toolbox
%
%%%%%%%%%%%%%%%%%%%%% Copyright
%
% Copyright (c) 2012, Thomas Guillod
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
%     * Redistributions of source code must retain the above copyright 
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright 
%       notice, this list of conditions and the following disclaimer in 
%       the documentation and/or other materials provided with the distribution
%       
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
% POSSIBILITY OF SUCH DAMAGE.
%
% Thomas Guillod - 04.04.2012
%Reads multiple layers
function varargout = AdjustedGerberReader(name,thick,no_layers)
varargout = cell(1,(2*no_layers)+1);
tstart = tic;
%close all;

if nargin==0
    disp('usage : gerber2odb_comsol(name)')
    return
end
    % thickness of the PCB
    geom.b = thick;
    % thickness of the copper
    geom.bcu = 35e-6;
    % width of the copper
    geom.lcu = 0.3e-3;
    center_ori = false;
    unit = 1e-3;
    output = 'txt';

[s,mess,messid] = mkdir(['layer/' name]);
fid = fopen (['layer/' name '/' name '_' output '_info.txt'],'w');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% extract the coordinates from GERBER file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fdisp(fid,'------------------------------------------------------------------')
fdisp(fid,['------------------ ' name ' / ' date]);
fdisp(fid,'------------------------------------------------------------------')
fdisp(fid,'------------------ Top Layer extraction --------------------------')
[top_layer, top_via,top_thick_track , top_thick_via] = parse([name '.GTL']);
fdisp(fid,'                                                              done')
fdisp(fid,'------------------ Bottom Layer extraction -----------------------')
[bottom_layer, bottom_via,bottom_thick_track , bottom_thick_via] = parse([name '.GBL']);
fdisp(fid,'                                                              done')

fdisp(fid,'------------------ Middle Layer/s extraction -----------------------')
 if no_layers == 3
     [mid1_layer mid1_via,mid1_thick_track , mid1_thick_via] = parse([name '.GB1']);
     mid1_null_track = find(all((mid1_layer(:,1:2) == mid1_layer(:,3:4))')==1);
     mid1_layer_inv = [mid1_layer(:,3:4) mid1_layer(:,1:2)];
elseif no_layers == 4
     [mid1_layer mid1_via,mid1_thick_track , mid1_thick_via] = parse([name '.GB1']);
     mid1_null_track = find(all((mid1_layer(:,1:2) == mid1_layer(:,3:4))')==1);
     mid1_layer_inv = [mid1_layer(:,3:4) mid1_layer(:,1:2)];
     [mid2_layer mid2_via,mid2_thick_track , mid2_thick_via] = parse([name '.GB2']);
     mid2_null_track = find(all((mid2_layer(:,1:2) == mid2_layer(:,3:4))')==1);
     mid2_layer_inv = [mid2_layer(:,3:4) mid2_layer(:,1:2)];
else
    [mid1_via mid1_layer] = deal(zeros(4,4));
    [mid2_via mid2_layer] = deal(zeros(4,4));
 end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% make differents integrity tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fdisp(fid,'------------------ Check Layers ----------------------------------')

% check the via layer (matching top/bottom)
if all(size(top_via)==size(bottom_via))
    if all(all(sortrows(top_via)==sortrows(bottom_via)))
        fdisp(fid,'top/bottom layer vias matching : OK')
    else
        fdisp(fid,'WARNING : top/bottom layer vias matching : coordinate mismatching')
    end
else
    fdisp(fid,'WARNING : top/bottom layer vias matching : dimension mismatching')
end

% search for null tracks
top_null_track = find(all((top_layer(:,1:2)==top_layer(:,3:4))')==1);
bottom_null_track = find(all((bottom_layer(:,1:2)==bottom_layer(:,3:4))')==1);

if ~isempty(top_null_track)
    fdisp(fid,['WARNING : null tracks top layer : ' num2str(top_null_track)])
else
    fdisp(fid,'null tracks top layer : OK')
end
if ~isempty(bottom_null_track)
    fdisp(fid,['WARNING : null tracks bottom layer : ' num2str(bottom_null_track)])
else
    fdisp(fid,'null tracks bottom layer : OK')
end

% check fur duplicate data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%To be checked%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
top_layer_inv = [top_layer(:,3:4) top_layer(:,1:2)];
bottom_layer_inv = [bottom_layer(:,3:4) bottom_layer(:,1:2)];

if (size(unique(top_layer,'rows'),1) == size(top_layer,1))&&...
        (size(unique(top_layer_inv,'rows'),1) == size(top_layer_inv,1))
    fdisp(fid,'duplicate top layer : OK')
else
    fdisp(fid,['WARNING : # duplicate tracks on top layer : '...
        num2str( size(top_layer,1)-size(unique(top_layer,'rows'),1) + ...
        size(top_layer_inv,1)-size(unique(top_layer_inv,'rows'),1) )])
end

if (size(unique(bottom_layer,'rows'),1) == size(bottom_layer,1))&&...
        (size(unique(bottom_layer_inv,'rows'),1) == size(bottom_layer_inv,1))
    fdisp(fid,'duplicate bottom layer : OK')
else
    fdisp(fid,['WARNING : # duplicate tracks on bottom layer : '...
        num2str( size(bottom_layer,1)-size(unique(bottom_layer,'rows'),1) + ...
        size(bottom_layer_inv,1)-size(unique(bottom_layer_inv,'rows'),1) )])
end

if size(unique(top_via,'rows'),1) == size(top_via,1)
    fdisp(fid,'duplicate top vias : OK')
else
    fdisp(fid,['WARNING : # duplicate vias on top layer : '...
        num2str(size(top_via,1)-size(unique(top_via,'rows'),1))])
end

if size(unique(bottom_via,'rows'),1) == size(bottom_via,1)
    fdisp(fid,'duplicate bottom vias : OK')
else
    fdisp(fid,['WARNING : # duplicate vias on bottom layer : '...
        num2str(size(bottom_via,1)-size(unique(bottom_via,'rows'),1))])
end
fdisp(fid,'                                                              done')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% centering layers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fdisp(fid,'------------------ Centering Layers ------------------------------')
if length(center_ori)==2
    x_shift = center_ori(1)*1e4;
    y_shift = center_ori(2)*1e4;
elseif center_ori
    if no_layers ==2
    xmax_top = max(max(top_layer(:,[1 3])));
    xmax_bottom = max(max(bottom_layer(:,[1 3])));
    xmax = max(xmax_top,xmax_bottom);
    
    xmin_top = min(min(top_layer(:,[1 3])));
    xmin_bottom = min(min(bottom_layer(:,[1 3])));
    xmin = min(xmin_top,xmin_bottom);
    
    ymax_top = max(max(top_layer(:,[2 4])));
    ymax_bottom = max(max(bottom_layer(:,[2 4])));
    ymax = max(ymax_top,ymax_bottom);
    
    ymin_top = min(min(top_layer(:,[2 4])));
    ymin_bottom = min(min(bottom_layer(:,[2 4])));
    ymin = min(ymin_top,ymin_bottom);
    
    x_shift = (xmax+xmin)/2;
    y_shift = (ymax+ymin)/2;    
    
    elseif no_layers == 3
    xmax_top = max(max(top_layer(:,[1 3])));
    xmax_bottom = max(max(bottom_layer(:,[1 3])));
    xmax_mid1 = max(max(mid1_layer(:,[1 3])));
    xmax = max([xmax_top,xmax_bottom , xmax_mid1]);
    
    xmin_top = min(min(top_layer(:,[1 3])));
    xmin_bottom = min(min(bottom_layer(:,[1 3])));
    xmin_mid1 = min(min(mid1_layer(:,[1 3])));
    xmin = min([xmin_top,xmin_bottom , xmin_mid1]);
    
    ymax_top = max(max(top_layer(:,[2 4])));
    ymax_bottom = max(max(bottom_layer(:,[2 4])));
    ymax_mid1 = max(max(mid1_layer(:,[2 4])));
    ymax = max([ymax_top,ymax_bottom , ymax_mid1]);
    
    ymin_top = min(min(top_layer(:,[2 4])));
    ymin_bottom = min(min(bottom_layer(:,[2 4])));
    ymin_mid1 = min(min(mid1_layer(:,[2 4])));
    ymin = min([ymin_top,ymin_bottom , ymin_mid1]);
    
    x_shift = (xmax+xmin)/2;
    y_shift = (ymax+ymin)/2;
        
    elseif no_layers == 4
    xmax_top = max(max(top_layer(:,[1 3])));
    xmax_bottom = max(max(bottom_layer(:,[1 3])));
    xmax_mid1 = max(max(mid1_layer(:,[1 3])));
    xmax_mid2 = max(max(mid2_layer(:,[1 3])));
    xmax = max([xmax_top,xmax_bottom , xmax_mid1 , xmax_mid2]);
    
    xmin_top = min(min(top_layer(:,[1 3])));
    xmin_bottom = min(min(bottom_layer(:,[1 3])));
    xmin_mid1 = min(min(mid1_layer(:,[1 3])));
    xmin_mid2 = min(min(mid2_layer(:,[1 3])));
    xmin = min([xmin_top,xmin_bottom , xmin_mid1 , xmin_mid2]);
    
    ymax_top = max(max(top_layer(:,[2 4])));
    ymax_bottom = max(max(bottom_layer(:,[2 4])));
    ymax_mid1 = max(max(mid1_layer(:,[2 4])));
    ymax_mid2 = max(max(mid2_layer(:,[2 4])));
    ymax = max([ymax_top,ymax_bottom , ymax_mid1 , ymax_mid2]);
    
    ymin_top = min(min(top_layer(:,[2 4])));
    ymin_bottom = min(min(bottom_layer(:,[2 4])));
    ymin_mid1 = min(min(mid1_layer(:,[2 4])));
    ymin_mid2 = min(min(mid2_layer(:,[2 4])));
    ymin = min([ymin_top,ymin_bottom , ymin_mid1 , ymin_mid2]);
    
    x_shift = (xmax+xmin)/2;
    y_shift = (ymax+ymin)/2;    
    end
else
    x_shift = 0;
    y_shift = 0;
end

top_layer(:,[1 3]) = top_layer(:,[1 3])-x_shift;
top_layer(:,[2 4]) = top_layer(:,[2 4])-y_shift;
top_via(:,1) = top_via(:,1)-x_shift;
top_via(:,2) = top_via(:,2)-y_shift;

bottom_layer(:,[1 3]) = bottom_layer(:,[1 3])-x_shift;
bottom_layer(:,[2 4]) = bottom_layer(:,[2 4])-y_shift;
bottom_via(:,1) = bottom_via(:,1)-x_shift;
bottom_via(:,2) = bottom_via(:,2)-y_shift;

if no_layers > 2 
    mid1_layer(:,[1 3]) = mid1_layer(:,[1 3])-x_shift;
    mid1_layer(:,[2 4]) = mid1_layer(:,[2 4])-y_shift;
    mid1_via(:,1) = mid1_via(:,1)-x_shift;
    mid1_via(:,2) = mid1_via(:,2)-y_shift; 
end
if no_layers > 3
    mid2_layer(:,[1 3]) = mid2_layer(:,[1 3])-x_shift;
    mid2_layer(:,[2 4]) = mid2_layer(:,[2 4])-y_shift;
    mid2_via(:,1) = mid2_via(:,1)-x_shift;
    mid2_via(:,2) = mid2_via(:,2)-y_shift;
end
if strcmp(output,'odb');
    pcb_original = pcb;
    pcb(1:2) = pcb(1:2)*1e4-x_shift;
    pcb(3:4) = pcb(3:4)*1e4-y_shift;
end

fdisp(fid,'                                                              done')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% convert layers (unit+2D=>3D)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fdisp(fid,'------------------ Convert Layers --------------------------------')

% convert to unit => 4:4 => 0.1um resolution 1e4 => mm => 1e5 => cm
top_layer = top_layer/(unit*1e7);
top_via = top_via/(unit*1e7);
bottom_layer = bottom_layer/(unit*1e7);
bottom_via = bottom_via/(unit*1e7);

if no_layers > 2
    mid1_layer = mid1_layer/(unit*1e7);
    mid1_via = mid1_via/(unit*1e7); 
end
if no_layers > 3
    mid2_layer = mid2_layer/(unit*1e7);
    mid2_via = mid2_via/(unit*1e7);
end
    
if strcmp(output,'odb');
    pcb = pcb/(unit*1e7);
end

% 2D => 3D
Three_D = linspace(-geom.b/2 , geom.b/2 , no_layers);
if no_layers == 2
    top_layer = [top_layer(:,1:2) Three_D(1)*(1/unit)*geom.b*ones(size(top_layer,1),1)...
        top_layer(:,3:4) Three_D(1)*(1/unit)*geom.b*ones(size(top_layer,1),1) top_thick_track];
    bottom_layer = [bottom_layer(:,1:2) Three_D(end)*(1/unit)*geom.b*ones(size(bottom_layer,1),1)...
        bottom_layer(:,3:4) Three_D(end)*(1/unit)*geom.b*ones(size(bottom_layer,1),1) bottom_thick_track];
    top_via = [top_via(:,1:2) Three_D(end)*(1/unit)*geom.b*ones(size(top_via,1),1)...
        top_via(:,1:2) Three_D(1)*(1/unit)*geom.b*ones(size(top_via,1),1) top_thick_via];
    bottom_via = [bottom_via(:,1:2) Three_D(end)*(1/unit)*geom.b*ones(size(bottom_via,1),1)...
        bottom_via(:,1:2) Three_D(1)*(1/unit)*geom.b*ones(size(bottom_via,1),1) bottom_thick_via];

    %Output Definition
    varargout{1} = top_layer; varargout{2} = top_via; varargout{3} = bottom_layer;
    varargout{4} = bottom_via;
    
elseif no_layers == 3 
    top_layer = [top_layer(:,1:2) Three_D(1)*(1/unit)*geom.b*ones(size(top_layer,1),1)...
        top_layer(:,3:4) Three_D(1)*(1/unit)*geom.b*ones(size(top_layer,1),1) top_thick_track];
    bottom_layer = [bottom_layer(:,1:2) Three_D(end)*(1/unit)*geom.b*ones(size(bottom_layer,1),1)...
        bottom_layer(:,3:4) Three_D(end)*(1/unit)*geom.b*ones(size(bottom_layer,1),1) bottom_thick_track];
    mid1_layer = [mid1_layer(:,1:2) Three_D(2)*(1/unit)*geom.b*ones(size(mid1_layer,1),1)...
        mid1_layer(:,3:4) Three_D(2)*(1/unit)*geom.b*ones(size(mid1_layer,1),1) mid1_thick_track];
    top_via = [top_via(:,1:2) Three_D(end)*(1/unit)*geom.b*ones(size(top_via,1),1)...
        top_via(:,1:2) Three_D(1)*(1/unit)*geom.b*ones(size(top_via,1),1) top_thick_via];
    bottom_via = [bottom_via(:,1:2) Three_D(end)*(1/unit)*geom.b*ones(size(bottom_via,1),1)...
        bottom_via(:,1:2) Three_D(1)*(1/unit)*geom.b*ones(size(bottom_via,1),1) bottom_thick_via];
    mid1_via = [mid1_via(:,1:2) Three_D(end)*(1/unit)*geom.b*ones(size(mid1_via,1),1)...
        mid1_via(:,1:2) Three_D(1)*(1/unit)*geom.b*ones(size(mid1_via,1),1) mid1_thick_via];    
    
    %Output Definition
    varargout{1} = top_layer; varargout{2} = top_via; varargout{3} = bottom_layer;
    varargout{4} = bottom_via; varargout{5} = mid1_layer; varargout{6} = mid1_via; 
    
elseif no_layers == 4
    top_layer = [top_layer(:,1:2) Three_D(1)*(1/unit)*geom.b*ones(size(top_layer,1),1)...
        top_layer(:,3:4) Three_D(1)*(1/unit)*geom.b*ones(size(top_layer,1),1) top_thick_track];
    bottom_layer = [bottom_layer(:,1:2) Three_D(end)*(1/unit)*geom.b*ones(size(bottom_layer,1),1)...
        bottom_layer(:,3:4) Three_D(end)*(1/unit)*geom.b*ones(size(bottom_layer,1),1) bottom_thick_track];
    mid1_layer = [mid1_layer(:,1:2) Three_D(2)*(1/unit)*geom.b*ones(size(mid1_layer,1),1)...
        mid1_layer(:,3:4) Three_D(2)*(1/unit)*geom.b*ones(size(mid1_layer,1),1) mid1_thick_track];
    mid2_layer = [mid2_layer(:,1:2) Three_D(3)*(1/unit)*geom.b*ones(size(mid2_layer,1),1)...
        mid2_layer(:,3:4) Three_D(3)*(1/unit)*geom.b*ones(size(mid2_layer,1),1) mid2_thick_track];
    top_via = [top_via(:,1:2) Three_D(end)*(1/unit)*geom.b*ones(size(top_via,1),1)...
        top_via(:,1:2) Three_D(1)*(1/unit)*geom.b*ones(size(top_via,1),1) top_thick_via];
    bottom_via = [bottom_via(:,1:2) Three_D(end)*(1/unit)*geom.b*ones(size(bottom_via,1),1)...
        bottom_via(:,1:2) Three_D(1)*(1/unit)*geom.b*ones(size(bottom_via,1),1) bottom_thick_via];
    mid1_via = [mid1_via(:,1:2) Three_D(end)*(1/unit)*geom.b*ones(size(mid1_via,1),1)...
        mid1_via(:,1:2) Three_D(1)*(1/unit)*geom.b*ones(size(mid1_via,1),1) mid1_thick_via]; 
    mid2_via = [mid2_via(:,1:2) Three_D(end)*(1/unit)*geom.b*ones(size(mid2_via,1),1)...
        mid2_via(:,1:2) Three_D(1)*(1/unit)*geom.b*ones(size(mid2_via,1),1) mid2_thick_via]; 
    
    %Output Definition
    varargout{1} = top_layer; varargout{2} = top_via; varargout{3} = bottom_layer;
    varargout{4} = bottom_via; varargout{5} = mid1_layer; varargout{6} = mid1_via; 
    varargout{7} = mid2_layer; varargout{8} = mid2_via;
end
fdisp(fid,'                                                              done')



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% save the results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fdisp(fid,'------------------ Save Layers -----------------------------------')
if strcmp(output,'txt')
    save_file(name,top_layer,'top_layer');
    save_file(name,bottom_layer,'bottom_layer');
    save_file(name,top_via,'top_via');
    save_file(name,bottom_via,'bottom_via');
else
    save_file_odb(name,top_layer,bottom_layer,top_via,geom,pcb);
end

fdisp(fid,['conversion name : ' name]);
fdisp(fid,['conversion date : ' date]);
fdisp(fid,['conversion type : ' output]);
fdisp(fid,'-------------------------');
fdisp(fid,['thickness of the PCB [m] : ' num2str(geom.b)]);
fdisp(fid,['thickness of the copper [m] : ' num2str(geom.bcu)]);
fdisp(fid,['width of the copper [m] : ' num2str(geom.lcu)]);
fdisp(fid,['half width of the copper [m] : ' num2str(geom.lcu/2)]);

fdisp(fid,'-------------------------');
fdisp(fid,['thickness of the PCB [unit] : ' num2str((1/unit)*geom.b)]);
fdisp(fid,['thickness of the copper [unit] : ' num2str((1/unit)*geom.bcu)]);
fdisp(fid,['width of the copper [unit] : ' num2str((1/unit)*geom.lcu)]);
fdisp(fid,['half width of the copper [unit] : ' num2str((1/unit)*geom.lcu/2)]);
fdisp(fid,'-------------------------');
if length(center_ori)==2
    fdisp(fid,['centering of the origin [mm] : [' num2str(center_ori) ']']);
elseif center_ori
    fdisp(fid,['centering of the origin [mm] : automatic : ['...
        num2str(x_shift*1e-4) ' ' num2str(y_shift*1e-4) ']']);
else
    fdisp(fid,'centering of the origin [mm] : false');
end
if strcmp(output,'odb')
    fdisp(fid,['pcb orginal coord [mm] : [' num2str(pcb_original) ']']);
    fdisp(fid,['pcb coord [mm] : [' num2str(pcb) ']']);
end
fdisp(fid,'-------------------------');
fdisp(fid,['unit (mm : 1e-3 / cm : 1e-2) : ' num2str(unit)]);
fdisp(fid,'-------------------------');
fdisp(fid,['# vias top layer : ' num2str(size(top_via,1))]);
fdisp(fid,['# vias bottom layer : ' num2str(size(bottom_via,1))]);
fdisp(fid,['# tracks top layer : ' num2str(size(top_layer,1))]);
fdisp(fid,['# tracks bottom layer : ' num2str(size(bottom_layer,1))]);
fdisp(fid,'-------------------------');
[l_track,l_via,l_self] = length_pcb(top_layer,bottom_layer,top_via,geom,unit);
fdisp(fid,['length of the tracks [m] : ' num2str(unit*l_track)]);
fdisp(fid,['length of the tracks [unit] : ' num2str(l_track)]);
fdisp(fid,['length of the vias [m] : ' num2str(unit*l_via)]);
fdisp(fid,['length of the vias [unit] : ' num2str(l_via)]);
fdisp(fid,['total length of the conductor [m] : ' num2str(unit*(l_via+l_track))]);
fdisp(fid,['total length of the conductor [unit] : ' num2str(l_via+l_track)]);
fdisp(fid,['self inductance [nH] : ' num2str(l_self)]);
fdisp(fid,'-------------------------');
fdisp(fid,['total elapsed time : ' num2str(toc(tstart))]);
fdisp(fid,'                                                              done')
fclose(fid);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Internal functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% find the track and via coordinates for a layer
function [track, via,thick_track , thick_via]= parse(file_name)

% read the file
fid = fopen (['gerber/' file_name],'r');
if fid==-1
    disp([file_name ' not found'])
    return;
end
txt = fgetl(fid);
i=1;
while txt>0
    file{i}=txt;
    txt = fgetl(fid);
    i=i+1;
end
fclose(fid);

% extract the track and via
i=1;
via_count = 1;
track_count = 1;
% no start point
x = Inf;
y = Inf;
while i<=length(file)
    apretures = load('apretures.mat');
    apretures = apretures.apretures;
    % control block => via or track
    if (file{i}(1)=='D' && file{i}(end)=='*')
        App = file{i}(1:3);
        ind = find(strcmp(App,apretures));
        %Thickness mm
        thick = apretures{ind,3};
        %|| (file{i}(1)=='G' && file{i}(end)=='*')
        % test for via
        if (file{i+1}(1)=='X' || file{i+1}(1)=='Y') && (~isempty(strfind(file{i+1},'D03')))
            %%(file{i+2}(1)~='X' && file{i+2}(1)~='Y')
            %  i+1 is a via
            disp('------------')
            disp(['via ' num2str(i+1) ' : ' file{i+1}]);
            [xn,yn] = parse_line(file{i+1});
            [x,y] = complete_coord(xn,yn,x,y);
            thick_via(via_count,:) = thick;
            via(via_count,:) = [x y];
            disp(num2str([x y]));
            via_count = via_count+1;
        end
        % test for tracks (many are possible)
        while (file{i+1}(1)=='X' || file{i+1}(1)=='Y') && (file{i+2}(1)=='X' || file{i+2}(1)=='Y')
            % i+1 / i+2 is a track
            disp('------------')
            disp(['track ' num2str(i+1) '/' num2str(i+2) ' : ' file{i+1} '  /  ' file{i+2}]);
            [x1,y1] = parse_line(file{i+1});
            [x1,y1] = complete_coord(x1,y1,x,y);
            [x2,y2] = parse_line(file{i+2});
            [x2,y2] = complete_coord(x2,y2,x1,y1);
            x = x2;
            y = y2;
            if strfind(file{i+2},'D01')
                thick_track(track_count,:) = thick;
                track(track_count,:) = [x1 y1 x2 y2];
                disp([num2str([x1 y1]) ' => ' num2str([x2 y2])]);
                if x1==x2 && y1==y2
                    disp('WARNING : null track')
                end
                track_count = track_count+1;
            end
            i = i+1;
        end
        
    end
    i = i+1;
end

end

% extract the coordinate of a line
% X1055800Y995520D02* => x = 1055800 / y = 995520
% X1045800D01* => x = 1045800 / y = Nan
function [x,y] = parse_line(line)

x_pos = strfind(line,'X');
y_pos = strfind(line,'Y');
d_pos = strfind(line,'D');

if isempty(x_pos) && isempty(y_pos)
    x = NaN;
    y = NaN;
elseif ~isempty(x_pos) && isempty(y_pos)
    x = str2double(line(x_pos+1:d_pos-1));
    y = NaN;
elseif isempty(x_pos) && ~isempty(y_pos)
    x = NaN;
    y = str2double(line(y_pos+1:d_pos-1));
else
    x = str2double(line(x_pos+1:y_pos-1));
    y = str2double(line(y_pos+1:d_pos-1));
end

end

% complete a line with xold yold if x or y are undefined
% X1055800Y995520D02* => x = 1055800 / y = 995520 => nothing to do
% X1045800D01* => x = 1045800 / y = Nan then y = yold
function [x,y] = complete_coord(x,y,xold,yold)

if isnan(x)
    x = xold;
end

if isnan(y)
    y = yold;
end
end

% write a output file (reparse for having the desired precision)
function save_file(name,matrix,layer_name)

fid = fopen (['layer/' name '/' name '_' layer_name '.txt'],'w');
for i=1:size(matrix,1)
    fprintf(fid,'%.5f %.5f %.5f %.5f %.5f %.5f\n',matrix(i,1),matrix(i,2),matrix(i,3),...
        matrix(i,4),matrix(i,5),matrix(i,6));
end
fclose(fid);
end

% write a output file (reparse for having the desired precision)
function save_file_odb(name,top_layer,bottom_layer,top_via,geom,pcb)

% track file
fid = fopen (['layer/' name '/' name '_odb_layer.xml'],'w');
copyto(fid,'header.xml');
fprintf(fid,'                        <POLYGON>\n');
fprintf(fid,'                            <OB X="%.5f" Y="%.5f"/>\n',pcb(1),pcb(4));
fprintf(fid,'                            <OS X="%.5f" Y="%.5f"/>\n',pcb(2),pcb(4));
fprintf(fid,'                            <OS X="%.5f" Y="%.5f"/>\n',pcb(2),pcb(3));
fprintf(fid,'                            <OS X="%.5f" Y="%.5f"/>\n',pcb(1),pcb(3));
fprintf(fid,'                            <OS X="%.5f" Y="%.5f"/>\n',pcb(1),pcb(4));
fprintf(fid,'                            <OE/>\n');
fprintf(fid,'                        </POLYGON>\n');
copyto(fid,'mid.xml');

fprintf(fid,'                        <CAD_LYR_F LYR_NAME = "top.layer">\n');
fprintf(fid,'                            <CAD_SET SYM = "r%.5f"/>\n',geom.lcu*1e3);
for i=1:size(top_layer,1)
    fprintf(fid,'                            <CAD_L XS="%.5f" YS="%.5f" XE="%.5f" YE="%.5f"/>\n',...
        top_layer(i,1),top_layer(i,2),top_layer(i,4),top_layer(i,5));
end
fprintf(fid,'                        </CAD_LYR_F>\n');
fprintf(fid,'                        <CAD_LYR_F LYR_NAME = "bottom.layer">\n');
fprintf(fid,'                            <CAD_SET SYM = "r%.5f"/>\n',geom.lcu*1e3);
for i=1:size(bottom_layer,1)
    fprintf(fid,'                            <CAD_L XS="%.5f" YS="%.5f" XE="%.5f" YE="%.5f"/>\n',...
        bottom_layer(i,1),bottom_layer(i,2),bottom_layer(i,4),bottom_layer(i,5));
end
fprintf(fid,'                        </CAD_LYR_F>\n');
fprintf(fid,'                        <CAD_LYR_F LYR_NAME = "vias">\n');
fprintf(fid,'                        </CAD_LYR_F>\n');
copyto(fid,'footer.xml');
fclose(fid);

% via file
fid = fopen (['layer/' name '/' name '_odb_via.xml'],'w');
copyto(fid,'header.xml');
fprintf(fid,'                        <POLYGON>\n');
fprintf(fid,'                            <OB X="%.5f" Y="%.5f"/>\n',pcb(1),pcb(4));
fprintf(fid,'                            <OS X="%.5f" Y="%.5f"/>\n',pcb(2),pcb(4));
fprintf(fid,'                            <OS X="%.5f" Y="%.5f"/>\n',pcb(2),pcb(3));
fprintf(fid,'                            <OS X="%.5f" Y="%.5f"/>\n',pcb(1),pcb(3));
fprintf(fid,'                            <OS X="%.5f" Y="%.5f"/>\n',pcb(1),pcb(4));
fprintf(fid,'                            <OE/>\n');
fprintf(fid,'                        </POLYGON>\n');
copyto(fid,'mid.xml');fprintf(fid,'                        <CAD_LYR_F LYR_NAME = "top.layer">\n');
fprintf(fid,'                        </CAD_LYR_F>\n');
fprintf(fid,'                        <CAD_LYR_F LYR_NAME = "bottom.layer">\n');
fprintf(fid,'                        </CAD_LYR_F>\n');
fprintf(fid,'                        <CAD_LYR_F LYR_NAME = "vias">\n');
fprintf(fid,'                            <CAD_SET NET = "pri1"/>\n');
for i=1:size(top_via,1)
    fprintf(fid,'                            <CAD_P X="%.5f" Y="%.5f" SYM = "r%.5f"/>\n',...
        top_via(i,1),top_via(i,2),geom.lcu*1e3);
end
fprintf(fid,'                        </CAD_LYR_F>\n');
copyto(fid,'footer.xml');
fclose(fid);
end

% copy a file into another
function copyto(fid,file_name)

fidin = fopen (['gerber/' file_name],'r');
if fidin==-1
    disp([file_name ' not found'])
    return;
end
txt = fgetl(fidin);

while txt>0
    fprintf(fid,'%s\n',txt);
    txt = fgetl(fidin);
end
fclose(fidin);
end

function [l_track,l_via,l_self] = length_pcb(top_layer,bottom_layer,top_via,geom,unit)

l_via = size(top_via,1)*(geom.b/unit);

vec = [top_layer(:,1)-top_layer(:,4) top_layer(:,2)-top_layer(:,5)];
length_top = sqrt(vec(:,1).^2+vec(:,2).^2);

for i=1:length(length_top)
    l=length_top(i)*(unit/1e-2);
    if l>0.5
        ll_top(i) = 0.002*l*(log(2*l/((geom.bcu/1e-2)+(geom.lcu/1e-2)))+0.02235*...
            (((geom.bcu/1e-2)+(geom.lcu/1e-2))/l)+0.5)*1000;
    else
        ll_top(i)=0;
    end
end

vec = [bottom_layer(:,1)-bottom_layer(:,4) bottom_layer(:,2)-bottom_layer(:,5)];
length_bottom = sqrt(vec(:,1).^2+vec(:,2).^2);

for i=1:length(length_bottom)
    l=length_bottom(i)*(unit/1e-2);
    if l>0.2
        ll_bottom(i) = 0.002*l*(log(2*l/((geom.bcu/1e-2)+(geom.lcu/1e-2)))+0.02235*...
            (((geom.bcu/1e-2)+(geom.lcu/1e-2))/l)+0.5)*1000;
    else
        ll_top(i)=0;
    end
end

l_self = sum(ll_bottom)+sum(ll_top);

l_track = sum(length_top)+sum(length_bottom);

end

% wrapper for writing on screen and in file
function fdisp(fid,str)
fprintf(fid,'%s\n',str);
disp(str)
end
