clear all 
clc
Xs = -5; Xe = 5; Ys = -5 ; Ye = 5; Zs = -15; Ze = 15;
Xs = Xs*0.01; Ys = Ys*0.01; Zs = Zs*0.01;
Xe = Xe*0.01; Ye = Ye*0.01; Ze = Ze*0.01
mue0 = 1.25663753*10^-6;
load('EPS_new.mat');
[a b c] = size(B_EPS);
Xincr = (Xe - Xs)/(a-1);
Yincr = (Ye - Ys)/(b-1);
Zincr = (Ze - Zs)/(c-1);
dBxx = zeros(a , b , c); dBxm = zeros(a , b , c);
dByy = zeros(a , b , c); dByn = zeros(a , b , c);
dBzz = zeros(a , b , c); dBzp = zeros(a , b , c);
N = a* b * c;

alpha = 0.001; %learning rate
[dCostx , dCosty , dCostz , dCostm , dCostn , dCostp] = deal(100);
%this would be the starting values
load('dipole_PSO_1e-4')
%x = [-2.0013    1.7974  -12.9950    0.0001    0.0001   -0.0001];
mu_a = x(1); mu_b = x(2); mu_c = x(3);
m = x(4); n = x(5); p = x(6);
out = [];

while any(abs([dCostx , dCosty , dCostz , dCostm , dCostn , dCostp]) > 1e-12)
[dCostx , dCosty , dCostz , dCostm , dCostn , dCostp] = cost(mu_a , mu_b , mu_c , m , n , p);

mu_a = mu_a - (alpha*dCostx); m = m - (alpha*dCostm);
mu_b = mu_b - (alpha*dCosty); n = n - (alpha*dCostn);
mu_c = mu_c - (alpha*dCostz); p = p - (alpha*dCostp);
x_new = [mu_a , mu_b , mu_c , m , n , p];
S = max([dCostx , dCosty , dCostz , dCostm , dCostn , dCostp])
out = [out; S , x_new];
end

[e1 , e2 , e3 , e4] = FitFnc(x_new)