clear all
clc
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
num_point = [50 50 150]*4; % no of points for field calculation
% step size for field calculation
Step = [2*DimGeo(1)/num_point(1) 2*DimGeo(2)/num_point(2) 2*DimGeo(3)/num_point(3)];

x = -DimGeo(1) : Step(1) : DimGeo(1);  y = -DimGeo(2) : Step(2) : DimGeo(2);   
z = -DimGeo(3) : Step(3) : DimGeo(3);

%%
%EPS PCB position1 
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
%Reading HYP file for the PCB
[Nets , PIN , PIN_dev , VIA , Device , Layers , padstack] = readHYP('Cutted_PCB.HYP');
%Reading the most significant tracks
[Device_PIN , IO_Type , Current] = Most_Sig_Curr('EPS_pin_curren_20210208.xlsx');
stack = Current_Wires(Nets , PIN , VIA , Current , PIN_dev , Device_PIN);

%inch to cm 
stack(:, 1:6) = stack(:,1:6)*2.54;

rot = [1 0 0 ;0 1 0;0 0 1];
stack = PosPCB_v2(start , rot, stack);
[a , b ] = size(stack);
for i = 1 : a
   h(1) = plot3([stack(i,1) stack(i,4)] , [stack(i,2) stack(i,5)] , [stack(i,3) stack(i,6)]...
       ,'linewidth',2,'color','b');
   hold on
end

[L D] = norm_len(stack);
I = stack(:,7)*1e-3;

%[B_EPS Bx_EPS By_EPS Bz_EPS] = WiresMagField(L , stack , I , -DimGeo(1) , DimGeo(1) , -DimGeo(2) ,...
%     DimGeo(2) , -DimGeo(3) , DimGeo(3) , num_point(1) , num_point(2) , num_point(3) , 10);
T = Torque(L, stack , I  ,[0 , 0 , 0]);

%%
%total field calculation and plot
% B_EPS = B_EPS1 + B_EPS2 + B_EPS3 + B_EPS4;
% Bx_EPS = Bx_EPS1 + Bx_EPS2 + Bx_EPS3 + Bx_EPS4;
% By_EPS = By_EPS1 + By_EPS2 + By_EPS3 + By_EPS4;
% Bz_EPS = Bz_EPS1 + Bz_EPS2 + Bz_EPS3 + Bz_EPS4;
%T = T1 + T2 + T3 + T4;
%plot for magnetic field
H = vol3d('CData',B_EPS, 'XData',[-5 5] , 'YData', [-5 5] , 'ZData',[-15 15],'texture','3D')
colormap hsv
colorbar
view(3)
set(gca,'DataAspectRatio', [1 1 1]);