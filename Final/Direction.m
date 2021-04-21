function [seq L D] = Direction(Side , stack , unique_points)
%This function is to calculate the direction of current in pcb wires
%Side --> definition of the side where the power source is placed
%stack --> PCB tracks
%unique_points --> set of points with only one wire connectin (possible
%start and end points)
start = [];
c = 1;
seq = [];
if strfind(Side, 'right')
  for i = 1 : length(unique_points)
  [a b] = max(unique_points(:,1)); %start from max x
  start(c,:) = unique_points(b,:);%take first point at the right
  unique_points(b,:) = nan;%remove taken point
  if ~ismember(unique_points(i,1:3) , start(:,1:3),'rows') 
      %sequence following the point
  [seq stack] = extract_seq(start(c,:), stack , unique_points , seq);
  c = c + 1;
      else
          continue
      end
  end
elseif strfind(Side, 'left')
      for i = 1 : length(unique_points)%start from min x
  [a b] = min(unique_points(:,1)); 
  start(c,:) = unique_points(b,:);
  unique_points(b,:) = nan;
  if ~ismember(unique_points(i,1:3) , start(:,1:3),'rows')
  [seq stack] = extract_seq(start(c,:), stack , unique_points , seq);
  c = c + 1;
      else
          continue
      end
      end
  
 elseif strfind(Side, 'up')
      for i = 1 : length(unique_points)%start from max y
  [a b] = max(unique_points(:,2)); 
  start(c,:) = unique_points(b,:);
  unique_points(b,:) = nan;
  if ~ismember(unique_points(i,1:3) , start(:,1:3),'rows')
  [seq stack] = extract_seq(start(c,:), stack , unique_points , seq);
  c = c + 1;
      else
          continue
      end
      end
 elseif strfind(Side, 'down')
      for i = 1 : length(unique_points)
  [a b] = min(unique_points(:,2));  %start from min y
  start(c,:) = unique_points(b,:);
  unique_points(b,:) = nan;
  if ~ismember(unique_points(i,1:3) , start(:,1:3),'rows')
  [seq] = extract_seq(start(c,:), stack , unique_points , seq);
  c = c + 1;
      else
          continue
      end
  end
end

    %Wire length calculation
    L(:,1) = sqrt((seq(:,1) - seq(:,4)).^2 + (seq(:,2) - seq(:,5)).^2 + (seq(:,3) - seq(:,6)).^2);    
    %Wire length vector
    L(:,2:4) = seq(:,1:3) - seq(:,4:6);
    
    %Removing null tracks
    idx = find(all(L(:,1:4) == 0,2));
    seq(idx,:) = nan;
    L(idx,:) = nan;
    L(:,5) = seq(:,7);
    %Current unit vector
    D(:,1:3) = L(:,2:4) ./ L(:,1);
end