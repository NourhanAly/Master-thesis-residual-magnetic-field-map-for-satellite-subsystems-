clear all
clc
%Reading HYP file for the PCB
[Nets , PIN , PIN_dev , VIA , Device , Layers , padstack] = readHYP('Cutted_PCB.HYP');
%Reading the most significant tracks
[Device_PIN , IO_Type , Current] = Most_Sig_Curr('EPS_pin_curren_20210208.xlsx');

% 
% for i = 1 : length(Nets)
%    plot3([Nets{i,1} Nets{i,4}] , [Nets{i,2} Nets{i,5}] , [Nets{i,3} Nets{i,6}]...
%        ,'linewidth',2,'color','g')
%    hold on
% end
% for i = 1 : length(VIA)
%    plot3([VIA{i,1} VIA{i,4}] , [VIA{i,2} VIA{i,5}] , [VIA{i,3} VIA{i,6}]...
%        ,'linewidth',2,'color','g')
%    hold on
% end
% for i = 1 : length(PIN)
%    plot3([PIN{i,1} PIN{i,4}] , [PIN{i,2} PIN{i,5}] , [PIN{i,3} PIN{i,6}]...
%        ,'linewidth',2,'color','g')
%    hold on
% end
%%
stack =[];
Temp = [cell2mat(Nets(: , 1:6)); cell2mat(PIN(: , 1:6)); cell2mat(VIA(: , 1:6))];
for d = 1: length(Current)
    f = find(ismember(PIN_dev(: , 1) , char(Device_PIN(d , 1))));
    if isempty(f)
        continue
    else
        for n = 1 : length(f)
            [ans1 Temp] = Sequence(cell2mat(PIN(f , 1:3)) ,  Temp , Current(d));
            stack = [stack ; ans1];
            [ans2 Temp] = Sequence(cell2mat(PIN(f , 4:6)) ,  Temp , Current(d));
            stack = [stack ; ans2];            
        end
    end
end
Stack = [];
for k = 1: length(stack)
   if stack(k , 7) < 0
       temp = stack(k , :);
       stack(k , :) = [temp(4:6) , temp(1:3), -temp(7)];       
   end
   if stack(k, 1:3) - stack(k , 4:6) == [ 0 0 0]
       continue
   else
       Stack = [Stack ; stack(k , :)];
   end
end
%%
figure
for i = 1 : length(Stack)
dp = Stack(i,4:6) - Stack(i,1:3);
h(1) = plot3([Stack(i,1), Stack(i ,4)],[Stack(i,2),Stack(i , 5)],[Stack(i,3),Stack(i , 6)],'linewidth',1,'color','r' );
hold on
end
