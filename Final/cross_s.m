function [v] = cross_s(a , b)
v(1) = a(2)* b(3) - a(3) * b(2);
v(2) = a(3)* b(1) - a(1) * b(3);
v(3) = a(1)* b(2) - a(2) * b(1);
end