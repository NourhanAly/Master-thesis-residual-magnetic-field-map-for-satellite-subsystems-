function [B Bx By Bz] = fieldAtPoint(D ,L , I , Ref , seg_num)
mue0 = 1.25663753*10^-6;
%conversion to m
D = D*1e-2; L = L*1e-2; Ref = Ref*1e-2;
[a b c] = size(L);
%point of magnetic field calculation
Bx = 0; By = 0 ; Bz = 0 ;  B = 0;         
          for f = 1 : c
            for v = 1 :a
            idx = find(D(v,2:4,f)~=0, 2); %locating the dimension which the wire is extended through
            idxx = find(D(v,2:4,f)==0); %locating the directin where the wire dimensions are the same
            if sum(isnan(L(v,:,:))) ~= 0
                continue
            end
            %Condition to consider the different dimensions of wire
            %extension
            if length(idx)>1
                %if the wire moves in two directions
                SegS(:,idx(1)) = linspace(L(v,idx(1)+3,f) ,L(v,idx(1),f),seg_num+1);
                SegS(:,idx(2)) = linspace(L(v,idx(2)+3,f) ,L(v,idx(2),f),seg_num+1);
                SegS(:,idxx) = repelem(L(v,idxx,f),seg_num+1,1); 
            elseif length(idxx) >1
                %if the wire moves in only one dimension
                SegS(:,idx) = linspace(L(v,idx+3,f) ,L(v,idx,f),seg_num+1);
                SegS(:,idxx(1)) = repelem(L(v,idxx(1),f),seg_num+1,1);
                SegS(:,idxx(2)) = repelem(L(v,idxx(2),f),seg_num+1,1);
            end
            %Segmenting wire based on user input
            SegE = SegS(2:end,:);
            vec = SegE - SegS(1:end-1 , :);
            if length(idx)>1
                mid(:,idx(1)) = (SegS(1:end-1,idx(1)) + SegE(:,idx(1)))/2;
                mid(:,idx(2)) = (SegS(1:end-1,idx(2)) + SegE(:,idx(2)))/2;
                mid(:,idxx) = repelem(L(v,idxx,f),seg_num,1);
            elseif length(idxx) >1
                mid(:,idx) = (SegS(1:end-1,idx) + SegE(:,idx))/2;
                mid(:,idxx(1)) = repelem(L(v,idxx(1),f),seg_num,1);
                mid(:,idxx(2)) = repelem(L(v,idxx(2),f),seg_num,1);
            end
            r = Ref - mid;
            C = cross(vec,(r./sqrt(sum(r.^2,2)).^3));
            %magnetic field of one wire at one point
            if length(I) > 1
            B = (mue0*I(v)/(4*pi))*sum(C,1);
            else
            B = (mue0*I/(4*pi))*sum(C,1);    
            end
            Bx = B(1)+ Bx;
            By = B(2)+ By ;
            Bz = B(3)+ Bz ;

            end

 end
%amplititude of magnetic field
B = sqrt(Bx.^2 + By.^2 + Bz.^2);
end
