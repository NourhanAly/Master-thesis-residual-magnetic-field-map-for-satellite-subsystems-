function stack = PosPCB_v2(start , rot, stack)
%rotate
stack(:,1:3) = stack(:,1:3)*rot; 
stack(:,4:6) = stack(:,4:6)*rot;

%position
Sx = min(min(stack(:,1) , stack(:,4)));
Sy = min(min(stack(:,2) , stack(:,5)));
Sz = min(min(stack(:,3) , stack(:,6)));
S = [Sx Sy Sz];

%New loacation
stack(:,1:6) = stack(:,1:6) + [start start] - [S S];

end