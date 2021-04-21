function[L D] = norm_len(stack)

%Wire length calculation
L(:,1) = sqrt((stack(:,1) - stack(:,4)).^2 + (stack(:,2) - stack(:,5)).^2 + (stack(:,3) - stack(:,6)).^2);    
%Wire length vector
L(:,2:4) = stack(:,1:3) - stack(:,4:6);

%Current unit vector
D(:,1:3) = L(:,2:4) ./ L(:,1);
end