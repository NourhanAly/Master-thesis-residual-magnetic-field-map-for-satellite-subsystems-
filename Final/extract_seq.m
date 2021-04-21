function [seq stack] = extract_seq(point , stack , Temp , seq)
%given a start point (point) , follow the tracks to get the sequence
i = length (seq) + 1;
%
while isempty(intersect(Temp(:,1:2) , point(1:2) , 'rows')) 
    seq(i,1:3) = point;
    %checking where the point is in the stack of wires
    A1 = ismember(stack(:, 1:3) , point , 'row'); 
    A2 = ismember(stack(:, 4:6) , point , 'row');
    S1 = find(A1 ==1);
    S2 = find(A2 ==1);
    %if the point is no where to be found, then this is the sequence end
    if isempty(S1) && isempty(S2) 
    seq(i,1:6) = nan;
    break
    %if the point is in the stack, store the other connection point 
    elseif isempty(S1)
    seq(i,4:6) = stack(S2(1),1:3);
    seq(i,7) = stack(S2(1),7);
    stack(S2(1) , 1:7) = nan;%remove already read wires
    point = seq(i , 4:6);%reassign new point
    i = i + 1;
    else
    seq(i,4:6) = stack(S1(1),4:6);
    seq(i,7) = stack(S1(1),7);
    stack(S1(1) , 1:7) = nan;
    point = seq(i , 4:6);
    i = i + 1;
    end
    
end
end