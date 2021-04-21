% clear all
% clc
% Cubesat definition
% The dimensions for 3U is 10by10by30 cm
% center point for the satellite is 5,5,15 so we construct a coordinates set of x[-5,5]
% y[-5,5] z[-15,15]
SatSize = [10 10 30]; %Defining satellite dimension
DimGeo = SatSize/2;  %Placing the refernce axis at the center of the satellite
v = [DimGeo(1) DimGeo(2) -DimGeo(3); -DimGeo(1) DimGeo(2) -DimGeo(3);...
    -DimGeo(1) -DimGeo(2) -DimGeo(3); DimGeo(1) -DimGeo(2) -DimGeo(3);...
    DimGeo(1) DimGeo(2) DimGeo(3); -DimGeo(1) DimGeo(2) DimGeo(3);...
    -DimGeo(1) -DimGeo(2) DimGeo(3); DimGeo(1) -DimGeo(2) DimGeo(3)];
figure
set(gca,'DataAspectRatio', [1 1 1]);
axis([-DimGeo(1) DimGeo(1) -DimGeo(2) DimGeo(2) -DimGeo(3) DimGeo(3)])
hold on
plotCom(v , 'b' , 0.1) %Plotting a cube representing the satellite
xlabel('x axis')
ylabel('y axis')
zlabel('z axis')
view(3)

% Soltion parameters
num_point = [50 50 150]; % no of points for field calculation
% step size for field calculation
Step = [2*DimGeo(1)/num_point(1) 2*DimGeo(2)/num_point(2) 2*DimGeo(3)/num_point(3)];

x = -DimGeo(1) : Step(1) : DimGeo(1);  y = -DimGeo(2) : Step(2) : DimGeo(2);   
z = -DimGeo(3) : Step(3) : DimGeo(3);

%Currents in amps
T_I_coil = 0.04; % max coil 
T_I_panel = 0.5; % max PV 
T_I_OBC = 0.150; % max OBC PCB 
T_I_EPS = 1.375; % max EPS PCB

%%
%Panels and coils
%Information on panels and coils
Dim_cell = [.25 7.8 3.9];%Cell Dimension

%Defining how many horizontal cells per row
no_cell_h = 1; 
%Defining how many vertical cells per column
no_cell_v = 7;
%Number of electric loops in the panel
no_loops = 1;
%Number of cells in each loop
cell_per_loop = 7;
%Matrix defining the connected cells in each loop
loops_conn = [1 ;1; 1; 1; 1 ;1 ;1];

%First panels position (cm)
%Overall place of panel
Dim_panel_full = [0.4 8.25 27]; %overall panel dimension(cm)
start = [DimGeo(1) -(DimGeo(2)-0.775) -(DimGeo(3))];

%plot panel position
Pos_solar = [start(1)-Dim_panel_full(1) start(2) start(3); start(1) start(2) start(3);...
    start(1) start(2)+Dim_panel_full(2) start(3); start(1)-Dim_panel_full(1) start(2)+Dim_panel_full(2) start(3);...
    start(1)-Dim_panel_full(1) start(2) start(3)+Dim_panel_full(3); start(1) start(2) start(3)+Dim_panel_full(3);...
    start(1) start(2)+Dim_panel_full(2) start(3)+Dim_panel_full(3);...
    start(1)-Dim_panel_full(1) start(2)+Dim_panel_full(2) start(3)+Dim_panel_full(3)];
plotCom(Pos_solar ,'k' , 0.01)
hold on
%Place of wires representing panels
start_p = [(DimGeo(1)) -(DimGeo(2)-2.4) -(DimGeo(3))];
End_p = [(DimGeo(1)) -(DimGeo(2)-2.4) (DimGeo(3))];

%Calculating representative wires for the solar panels
[L_PV D_PV] = PV(start_p , End_p , Dim_panel_full , Dim_cell , no_cell_h , no_cell_v ,...
    no_loops , cell_per_loop  , loops_conn);
%Plotting the wires expressing the panels
[a b] = size(L_PV);
for i = 1 : a
   plot3([L_PV(i,1) L_PV(i,4)] , [L_PV(i,2) L_PV(i,5)] , [L_PV(i,3) L_PV(i,6)]...
       ,'linewidth',2,'color','g')
   hold on
end

%magnetic field due to solar panels
% [B_panel1 Bx_panel1 By_panel1 Bz_panel1] = WiresMagField(D_PV , L_PV , T_I_panel , -DimGeo(1) , DimGeo(1) , -DimGeo(2) ,...
%     DimGeo(2) , -DimGeo(3) , DimGeo(3) , num_point(1) , num_point(2) , num_point(3) , 100);

%Coil`s position
%Obtaining coil`s PCB
[top_layer top_via bottom_layer bottom_via] =...
        AdjustedGerberReader('PCB1-version25x75' , Dim_panel_full(1) , 2);
rot = [0 0 1 ;0 1 0;-1 0 0]; %rotation matrix required to adjust coil`s position
%calculation of PCB poition in satellite
[top_layer top_via bottom_layer bottom_via] = PosPCB(start*1e3 , rot , top_layer , top_via , bottom_layer , bottom_via);
stack = [top_layer; top_via; bottom_layer; bottom_via]*1e-3;
%scaling the coil to fit the atelllite dimensions
stack(:,2:3) = 0.9 * stack(:,2:3); stack(:,5:6) = 0.9 * stack(:,5:6);
for i = 1 : length(stack)
   h(1) = plot3([stack(i,1) stack(i,4)] , [stack(i,2) stack(i,5)] , [stack(i,3) stack(i,6)]...
       ,'linewidth',2,'color','b');
   hold on
end


%Extraction of possible start and end points in the pcb
[unique_points] = Uni_P(stack);
%Caluclation of possible wire sequence
[seq L D] = Direction('up' , stack , unique_points);

%total current supplied to PCB
[seq L] = thick2current(seq , L , T_I_coil);

%magnetic field calculation
[B_coil1 Bx_coil1 By_coil1 Bz_coil1] = WiresMagField(L , seq , L(:,5) , -DimGeo(1) , DimGeo(1) , -DimGeo(2) ,...
    DimGeo(2) , -DimGeo(3) , DimGeo(3) , num_point(1) , num_point(2) , num_point(3) , 1);


%For the purposes of comparison , another plot away from
%satellite of the resultant PCB and detected wires
first_panel = figure;
%Original PCB wires
for i = 1 : length(stack)
   h(1) = plot3([stack(i,1) stack(i,4)] , [stack(i,2) stack(i,5)] , [stack(i,3) stack(i,6)]...
       ,'linewidth',2,'color','b');
   hold on
end
set(gca,'DataAspectRatio', [1 1 1]);
%Calculated wires sequence plots
for i = 1 : length(seq)
dp = seq(i,4:6) - seq(i,1:3);
h(1) = quiver3(seq(i,1),seq(i,2),seq(i,3),dp(1),dp(2),dp(3),'linewidth',1,'color','r' );
hold on
end
savefig('1stPanel.fig')
close(first_panel)
%%
%Second panel position
Dim_panel_full = [0.4 8.25 27]; %overall panel dimension
start = [-DimGeo(1) -(DimGeo(2)-0.775) -(DimGeo(3))];
%plot panel position
Pos_solar = [start(1)+Dim_panel_full(1) start(2) start(3); start(1) start(2) start(3);...
    start(1) start(2)+Dim_panel_full(2) start(3); start(1)+Dim_panel_full(1) start(2)+Dim_panel_full(2) start(3);...
    start(1)+Dim_panel_full(1) start(2) start(3)+Dim_panel_full(3); start(1) start(2) start(3)+Dim_panel_full(3);...
    start(1) start(2)+Dim_panel_full(2) start(3)+Dim_panel_full(3);...
    start(1)+Dim_panel_full(1) start(2)+Dim_panel_full(2) start(3)+Dim_panel_full(3)];
plotCom(Pos_solar ,'k' , 0.01)
hold on

%Place of wires representing panels
start_p = [-(DimGeo(1)) -(DimGeo(2)-2.4) -(DimGeo(3))];
End_p = [-(DimGeo(1)) -(DimGeo(2)-2.4) (DimGeo(3))];

%Calculatng representative wires for the solar panels
[L_PV D_PV] = PV(start_p , End_p , Dim_panel_full , Dim_cell , no_cell_h , no_cell_v ,...
    no_loops , cell_per_loop  , loops_conn);
%Plotting the wires expressing the panels
[a b] = size(L_PV);
for i = 1 : a
   plot3([L_PV(i,1) L_PV(i,4)] , [L_PV(i,2) L_PV(i,5)] , [L_PV(i,3) L_PV(i,6)]...
       ,'linewidth',2,'color','g')
   hold on
end

% % %magnetic field due to solar panels
% [B_panel2 Bx_panel2 By_panel2 Bz_panel2] = WiresMagField(D_PV , L_PV , T_I_panel , -DimGeo(1) , DimGeo(1) , -DimGeo(2) ,...
%     DimGeo(2) , -DimGeo(3) , DimGeo(3) , num_point(1) , num_point(2) , num_point(3) , 100);

%Coil`s position
%Obtaining coils`s PCB
[top_layer top_via bottom_layer bottom_via] =...
        AdjustedGerberReader('PCB1-version25x75' , Dim_panel_full(1) , 2);    
rot = [0 0 1 ;0 1 0;-1 0 0];
[top_layer top_via bottom_layer bottom_via] = PosPCB(start*1e3 , rot , top_layer , top_via , bottom_layer , bottom_via);
stack = [top_layer; top_via; bottom_layer; bottom_via]*1e-3;
stack(:,2:3) = 0.9 * stack(:,2:3); stack(:,5:6) = 0.9 * stack(:,5:6);
for i = 1 : length(stack)
   h(1) = plot3([stack(i,1) stack(i,4)] , [stack(i,2) stack(i,5)] , [stack(i,3) stack(i,6)]...
       ,'linewidth',2,'color','b');
   hold on
end

%Extraction of possible start and end points in the pcb
[unique_points] = Uni_P(stack);
%Caluclation of possible wire sequence
[seq L D] = Direction('up' , stack , unique_points);

%total current supplied to PCB
[seq L] = thick2current(seq , L , T_I_coil);
[B_coil2 Bx_coil2 By_coil2 Bz_coil2] = WiresMagField(L , seq , L(:,5) , -DimGeo(1) , DimGeo(1) , -DimGeo(2) ,...
    DimGeo(2) , -DimGeo(3) , DimGeo(3) , num_point(1) , num_point(2) , num_point(3) , 10);

%For the purposes of comparison , another plot away from
%satellite of the resultant PCB and detected wires
second_panel = figure;
%Original PCB wires
for i = 1 : length(stack)
   h(1) = plot3([stack(i,1) stack(i,4)] , [stack(i,2) stack(i,5)] , [stack(i,3) stack(i,6)]...
       ,'linewidth',2,'color','b');
   hold on
end
set(gca,'DataAspectRatio', [1 1 1]);
%Calculated wires sequence plots
for i = 1 : length(seq)
dp = seq(i,4:6) - seq(i,1:3);
h(1) = quiver3(seq(i,1),seq(i,2),seq(i,3),dp(1),dp(2),dp(3),'linewidth',1,'color','r' );
hold on
end
savefig('2ndPanel.fig')
close(second_panel)
 %%   
%Third panel position
Dim_panel_full = [8.25 0.4 27]; %overall panel dimension
Dim_cell = [7.8 .25 3.9];%Cell Dimension
start = [-(DimGeo(2)-0.775) -DimGeo(1) -(DimGeo(3))];
%plot panel position
Pos_solar = [start(1) start(2) start(3); start(1)+Dim_panel_full(1) start(2) start(3);...
    start(1)+Dim_panel_full(1) start(2)+Dim_panel_full(2) start(3); start(1) start(2)+Dim_panel_full(2) start(3);...
    start(1) start(2) start(3)+Dim_panel_full(3); start(1)+Dim_panel_full(1) start(2) start(3)+Dim_panel_full(3);...
    start(1)+Dim_panel_full(1) start(2)+Dim_panel_full(2) start(3)+Dim_panel_full(3);...
    start(1) start(2)+Dim_panel_full(2) start(3)+Dim_panel_full(3)];
plotCom(Pos_solar ,'k' , 0.01)
hold on

%Place of wires representing panels
start_p = [-(DimGeo(2)-2.4) -DimGeo(1) -(DimGeo(3))];
End_p = [-(DimGeo(2)-2.4) -DimGeo(1) (DimGeo(3))];
%Calculatng representative wires for the solar panels
[L_PV D_PV] = PV(start_p , End_p , Dim_panel_full , Dim_cell , no_cell_h , no_cell_v ,...
    no_loops , cell_per_loop  , loops_conn);
[a b] = size(L_PV);
for i = 1 : a
   plot3([L_PV(i,1) L_PV(i,4)] , [L_PV(i,2) L_PV(i,5)] , [L_PV(i,3) L_PV(i,6)]...
       ,'linewidth',2,'color','g')
   hold on
end


% %magnetic field due to solar panels
% [B_panel3 Bx_panel3 By_panel3 Bz_panel3] = WiresMagField(D_PV , L_PV , T_I_panel , -DimGeo(1) , DimGeo(1) , -DimGeo(2) ,...
%     DimGeo(2) , -DimGeo(3) , DimGeo(3) , num_point(1) , num_point(2) , num_point(3) , 100);

%Coil`s position
%Obtaining coil`s PCB
[top_layer top_via bottom_layer bottom_via] =...
        AdjustedGerberReader('PCB1-version25x75' , Dim_panel_full(2) , 2);
rot = [0 0 1 ;0 1 0;-1 0 0]*[0 1 0;-1 0 0;0 0 1];%rotation matrix
[top_layer top_via bottom_layer bottom_via] = PosPCB(start*1e3 , rot , top_layer , top_via , bottom_layer , bottom_via);
stack = [top_layer; top_via; bottom_layer; bottom_via]*1e-3;
%scaling
stack(:,2:3) = 0.9 * stack(:,2:3); stack(:,5:6) = 0.9 * stack(:,5:6);
for i = 1 : length(stack)
   h(1) = plot3([stack(i,1) stack(i,4)] , [stack(i,2) stack(i,5)] , [stack(i,3) stack(i,6)]...
       ,'linewidth',2,'color','b');
   hold on
end

%Extraction of possible start and end points in the pcb
[unique_points] = Uni_P(stack);
%Caluclation of possible wire sequence
[seq L D] = Direction('up' , stack , unique_points);

%total current supplied to PCB
[seq L] = thick2current(seq , L , T_I_coil);
[B_coil3 Bx_coil3 By_coil3 Bz_coil3] = WiresMagField(L , seq , L(:,5) , -DimGeo(1) , DimGeo(1) , -DimGeo(2) ,...
    DimGeo(2) , -DimGeo(3) , DimGeo(3) , num_point(1) , num_point(2) , num_point(3) , 1);

%For the purposes of comparison , another plot away from
%satellite of the resultant PCB and detected wires
third_panel = figure;
%Original PCB wires
for i = 1 : length(stack)
   h(1) = plot3([stack(i,1) stack(i,4)] , [stack(i,2) stack(i,5)] , [stack(i,3) stack(i,6)]...
       ,'linewidth',2,'color','b');
   hold on
end
set(gca,'DataAspectRatio', [1 1 1]);
%Calculated wires sequence plots
for i = 1 : length(seq)
dp = seq(i,4:6) - seq(i,1:3);
h(1) = quiver3(seq(i,1),seq(i,2),seq(i,3),dp(1),dp(2),dp(3),'linewidth',1,'color','r' );
hold on
end
savefig('3rdPanel.fig')
close(third_panel)
%%
%Fourth panel position
Dim_panel_full = [8.25 0.4 27]; %overall panel dimension
start = [-DimGeo(2)+0.775 DimGeo(1) -(DimGeo(3))];
%plot panel position
Pos_solar = [start(1)+Dim_panel_full(1) start(2)-Dim_panel_full(2) start(3)+Dim_panel_full(3);...
    start(1) start(2)-Dim_panel_full(2) start(3)+Dim_panel_full(3);...
    start(1) start(2) start(3)+Dim_panel_full(3); start(1)+Dim_panel_full(1) start(2) start(3)+Dim_panel_full(3);...
    start(1)+Dim_panel_full(1) start(2)-Dim_panel_full(2) start(3);...
    start(1) start(2)-Dim_panel_full(2) start(3);...
    start(1) start(2) start(3);...
    start(1)+Dim_panel_full(1) start(2) start(3)];
plotCom(Pos_solar ,'k' , 0.01)
hold on

%Place of wires representing panels
start_p = [-(DimGeo(2)-2.4) DimGeo(1) -(DimGeo(3))];
End_p = [-(DimGeo(2)-2.4) DimGeo(1) (DimGeo(3))];
%Calculatng representative wires for the solar panels
[L_PV D_PV] = PV(start_p , End_p , Dim_panel_full , Dim_cell , no_cell_h , no_cell_v ,...
    no_loops , cell_per_loop  , loops_conn);
[a b] = size(L_PV);
for i = 1 : a
   plot3([L_PV(i,1) L_PV(i,4)] , [L_PV(i,2) L_PV(i,5)] , [L_PV(i,3) L_PV(i,6)]...
       ,'linewidth',2,'color','g')
   hold on
end

% %magnetic field due to solar panels
% [B_panel4 Bx_panel4 By_panel4 Bz_panel4] = WiresMagField(D_PV , L_PV , T_I_panel , -DimGeo(1) , DimGeo(1) , -DimGeo(2) ,...
%     DimGeo(2) , -DimGeo(3) , DimGeo(3) , num_point(1) , num_point(2) , num_point(3) , 100);

%Coil`s position
%Obtaining coil`s PCB
[top_layer top_via bottom_layer bottom_via] =...
        AdjustedGerberReader('PCB1-version25x75' , Dim_panel_full(2) , 2);
rot = [0 0 1 ;0 1 0;-1 0 0]*[0 1 0;-1 0 0;0 0 1];
[top_layer top_via bottom_layer bottom_via] = PosPCB(start*1e3 , rot , top_layer , top_via , bottom_layer , bottom_via);
stack = [top_layer; top_via; bottom_layer; bottom_via]*1e-3;
%scaling
stack(:,2:3) = 0.9 * stack(:,2:3); stack(:,5:6) = 0.9 * stack(:,5:6);
for i = 1 : length(stack)
   h(1) = plot3([stack(i,1) stack(i,4)] , [stack(i,2) stack(i,5)] , [stack(i,3) stack(i,6)]...
       ,'linewidth',2,'color','b');
   hold on
end
%Extraction of possible start and end points in the pcb
[unique_points] = Uni_P(stack);
%Caluclation of possible wire sequence
[seq L D] = Direction('up' , stack , unique_points);

%total current supplied to PCB
[seq L] = thick2current(seq , L , T_I_coil);
[B_coil4 Bx_coil4 By_coil4 Bz_coil4] = WiresMagField(L , seq , L(:,5) , -DimGeo(1) , DimGeo(1) , -DimGeo(2) ,...
    DimGeo(2) , -DimGeo(3) , DimGeo(3) , num_point(1) , num_point(2) , num_point(3) , 1);

%For the purposes of comparison , another plot away from
%satellite of the resultant PCB and detected wires
fourth_panel = figure;
%Original PCB wires
for i = 1 : length(stack)
   h(1) = plot3([stack(i,1) stack(i,4)] , [stack(i,2) stack(i,5)] , [stack(i,3) stack(i,6)]...
       ,'linewidth',2,'color','b');
   hold on
end
set(gca,'DataAspectRatio', [1 1 1]);
%Calculated wires sequence plots
for i = 1 : length(seq)
dp = seq(i,4:6) - seq(i,1:3);
h(1) = quiver3(seq(i,1),seq(i,2),seq(i,3),dp(1),dp(2),dp(3),'linewidth',1,'color','r' );
hold on
end
savefig('4thPanel.fig')
close(fourth_panel)
%%    
    
%OBC Position
Dim_OBC = [8.226 9.321 0.207];
start = [-(DimGeo(1)-0.887) -(DimGeo(2)-0.3395)   DimGeo(3)-18.725];
%plot panel position
Pos_OBC = [start(1) start(2)+Dim_OBC(2) start(3); start(1)+Dim_OBC(1) start(2)+Dim_OBC(2) start(3);...
    start(1)+Dim_OBC(1) start(2) start(3); start(1) start(2) start(3);...
    start(1) start(2)+Dim_OBC(2) start(3)-Dim_OBC(3); start(1)+Dim_OBC(1) start(2)+Dim_OBC(2) start(3)-Dim_OBC(3);...
    start(1)+Dim_OBC(1) start(2) start(3)-Dim_OBC(3);start(1) start(2) start(3)-Dim_OBC(3)];
plotCom(Pos_OBC ,'g' , 0.01)
hold on

%Obtaining panel`s PCB
[top_layer top_via bottom_layer bottom_via mid1_layer mid1_via mid2_layer mid2_via] =...
        AdjustedGerberReader('OBC_PCB' , Dim_OBC(3) , 4);
rot = [1 0 0 ;0 1 0;0 0 1];
[top_layer top_via bottom_layer bottom_via mid1_layer mid1_via mid2_layer mid2_via] =...
    PosPCB(start*1e3 , rot , top_layer , top_via , bottom_layer , bottom_via , mid1_layer ,...
    mid1_via , mid2_layer , mid2_via);
stack = [top_layer; top_via; bottom_layer; bottom_via ;mid1_layer ;mid1_via ;mid2_layer; mid2_via]*1e-3;
stack = unique(stack , 'rows');
for i = 1 : length(stack)
   h(1) = plot3([stack(i,1) stack(i,4)] , [stack(i,2) stack(i,5)] , [stack(i,3) stack(i,6)]...
       ,'linewidth',2,'color','b');
   hold on
end
%For the purposes of extracting the direction , another plot away from
%satellite
obc = figure;
for i = 1 : length(stack)
   h(1) = plot3([stack(i,1) stack(i,4)] , [stack(i,2) stack(i,5)] , [stack(i,3) stack(i,6)]...
       ,'linewidth',2,'color','b');
   hold on
end
set(gca,'DataAspectRatio', [1 1 1]);
%Determination of power side from user input
%[x y] = ginput(2);
%Side = SourceSide(x,y,stack);
%Extraction of possible start and end points
[unique_points] = Uni_P(stack);
[seq L D] = Direction('right' , stack , unique_points);

%total current supplied to PCB
[seq L] = thick2current(seq , L , T_I_OBC);

for i = 1 : length(seq)
dp = seq(i,4:6) - seq(i,1:3);
h(1) = quiver3(seq(i,1),seq(i,2),seq(i,3),dp(1),dp(2),dp(3),'linewidth',1,'color','r' );
hold on
end
savefig('OBC.fig')
close(obc)
% [B_OBC Bx_OBC By_OBC Bz_OBC] = WiresMagField(L , seq , L(:,5) , -DimGeo(1) , DimGeo(1) , -DimGeo(2) ,...
%     DimGeo(2) , -DimGeo(3) , DimGeo(3) , num_point(1) , num_point(2) , num_point(3) , 10);

%%
%EPS PCB position
Dim_EPS = [8.778 9.334 0.207];
start = [-(DimGeo(1)-0.611) -(DimGeo(2)-0.333) DimGeo(3)-28.039];
%plot panel position
Pos_EPS = [start(1) start(2)+Dim_EPS(2) start(3); start(1)+Dim_EPS(1) start(2)+Dim_EPS(2) start(3);...
    start(1)+Dim_EPS(1) start(2) start(3); start(1) start(2) start(3);...
    start(1) start(2)+Dim_EPS(2) start(3)-Dim_EPS(3); start(1)+Dim_EPS(1) start(2)+Dim_EPS(2) start(3)-Dim_EPS(3);...
    start(1)+Dim_EPS(1) start(2) start(3)-Dim_EPS(3);...
    start(1) start(2) start(3)-Dim_EPS(3)];
plotCom(Pos_EPS ,'g' , 0.01)

%Obtaining panel`s PCB
[top_layer top_via bottom_layer bottom_via mid1_layer mid1_via mid2_layer mid2_via] =...
        AdjustedGerberReader('Cutted_PCB' , Dim_EPS(3) , 4);
rot = [1 0 0 ;0 1 0;0 0 1];
[top_layer top_via bottom_layer bottom_via mid1_layer mid1_via mid2_layer mid2_via] =...
    PosPCB(start*1e3 , rot , top_layer , top_via , bottom_layer , bottom_via , mid1_layer ,...
    mid1_via , mid2_layer , mid2_via);
stack = [top_layer; top_via; bottom_layer; bottom_via ;mid1_layer ;mid1_via ;mid2_layer; mid2_via]*1e-3;
for i = 1 : length(stack)
   h(1) = plot3([stack(i,1) stack(i,4)] , [stack(i,2) stack(i,5)] , [stack(i,3) stack(i,6)]...
       ,'linewidth',2,'color','b');
   hold on
end
%For the purposes of extracting the direction , another plot away from
%satellite
EPS = figure;
for i = 1 : length(stack)
   h(1) = plot3([stack(i,1) stack(i,4)] , [stack(i,2) stack(i,5)] , [stack(i,3) stack(i,6)]...
       ,'linewidth',2,'color','b');
   hold on
end
set(gca,'DataAspectRatio', [1 1 1]);
%Determination of power side from user input
%[x y] = ginput(2);
%Side = SourceSide(x,y,stack);
%Extraction of possible start and end points
[unique_points] = Uni_P(stack);
[seq L D] = Direction('up' , stack , unique_points);

%total current supplied to PCB
[seq L] = thick2current(seq , L , T_I_EPS);

for i = 1 : length(seq)
dp = seq(i,4:6) - seq(i,1:3);
h(1) = quiver3(seq(i,1),seq(i,2),seq(i,3),dp(1),dp(2),dp(3),'linewidth',1,'color','r' );
hold on
end
savefig('EPS.fig')
close(EPS)
% [B_EPS Bx_EPS By_EPS Bz_EPS] = WiresMagField(L , seq , L(:,5) , -DimGeo(1) , DimGeo(1) , -DimGeo(2) ,...
%     DimGeo(2) , -DimGeo(3) , DimGeo(3) , num_point(1) , num_point(2) , num_point(3) , 10);
%%
%total field calculation and plot
B = B_coil1 + B_coil2 + B_coil3 + B_coil4 + B_panel1 + B_panel2 +...
    B_panel3 + B_panel4 + B_OBC + B_EPS;

%plot for magnetic field
H = vol3d('CData',B, 'XData',[-5 5] , 'YData', [-5 5] , 'ZData',[-15 15],'texture','3D')
colormap hsv
colorbar
view(3)
set(gca,'DataAspectRatio', [1 1 1]);