function [branch_points] = Branch(stack)
%function to detect branching points (for future work not important now)
branch_points = [];
c = 1;
for i = 1: length(stack)
    A1 = ismember(stack(:, 1:3) , stack(i,1:3) , 'row'); 
    A2 = ismember(stack(:, 4:6) , stack(i,1:3) , 'row');
    S1 = find(A1 ==1);
    S2 = find(A2 ==1); 
    S = [S1;S2];
    if length(S) > 1
       branch_points(c , : ) =  stack(i,1:3);
       stack(i, 1:3) = nan; stack(S1 , 1:3) = nan; stack(S2 , 4:6) = nan;
       c = c+1;
       
    end
    A1 = ismember(stack(:, 1:3) , stack(i,4:6) , 'row'); 
    A2 = ismember(stack(:, 4:6) , stack(i,4:6) , 'row');
    S1 = find(A1 ==1);
    S2 = find(A2 ==1); 
    S = [S1;S2];
    if length(S) > 1
       branch_points(c , : ) =  stack(i,4:6);
       stack(i, 4:6) = nan; stack(S1 , 1:3) = nan; stack(S2 , 4:6) = nan;
       c = c+1;
    end
end
end