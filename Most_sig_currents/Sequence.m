function [ordered , Nets] = Sequence(point , Nets , Current)
ind1 = find(ismember(Nets(: , 1:3), point, 'row'));
ind2 = find(ismember(Nets(: , 4:6), point, 'row'));
%i = 0;
ordered = [];
if ~isempty(ind1) && ~isempty(ind2)
    for j = 1: length(ind1)
        iind1 = ind1(j);
        if any(isnan(Nets(iind1 , :)))
            continue
        else
        [i k] = size(ordered);
        i = i + 1;
        ordered(i , :) = [Nets(iind1 , 1:6) , Current];
        Nets(iind1 , :) = NaN;
        point = ordered(end , 4:6);
        [ans , Nets] = Sequence(point , Nets , Current);
        ordered = [ordered ;ans];
        end
    end    
        for j = 1: length(ind2)
        iind2 = ind2(j);
        if any(isnan(Nets(iind2 , :)))
            continue
        else
        [i k] = size(ordered);
        i = i + 1;
        ordered(i , :) = [Nets(iind2 , 4:6) , Nets(iind2 , 1:3) , Current];
        Nets(iind2 , :) = NaN;
        point = ordered(end ,4:6);
        [ans , Nets] = Sequence(point , Nets , Current);
        ordered = [ordered ;ans];
        end
    end
elseif ~isempty(ind1) && isempty(ind2)
    for j = 1: length(ind1)
        iind1 = ind1(j);
        
        if any(isnan(Nets(iind1 , :)))
            continue
        else
        [i k] = size(ordered);
        i = i + 1;
        ordered(i , :) = [Nets(iind1 , 1:6) , Current];
        Nets(iind1 , :) = NaN;
        point = ordered(end , 4:6);
        [ans , Nets] = Sequence(point , Nets , Current);
        ordered = [ordered ;ans];
        end
    end
elseif ~isempty(ind2) && isempty(ind1)
    for j = 1: length(ind2)
        iind2 = ind2(j);
        
        if any(isnan(Nets(iind2 , :)))
            continue
        else
        [i k] = size(ordered);
        i = i + 1;
        ordered(i , :) = [Nets(iind2 , 4:6) , Nets(iind2 , 1:3) , Current];
        Nets(iind2 , :) = NaN;
        point = ordered(end , 4:6);
        [ans , Nets] = Sequence(point , Nets , Current);
        ordered = [ordered ;ans];
        end
    end
else
    return
end

end