function[dCostx , dCosty , dCostz , dCostm , dCostn , dCostp] = cost(mu_a , mu_b , mu_c , m , n , p)
Xs = -5; Xe = 5; Ys = -5 ; Ye = 5; Zs = -15; Ze = 15;
Xs = Xs*0.01; Ys = Ys*0.01; Zs = Zs*0.01;
Xe = Xe*0.01; Ye = Ye*0.01; Ze = Ze*0.01;
mue0 = 1.25663753*10^(-6);
load('EPS_new.mat');
[a b c] = size(B_EPS);
Xincr = (Xe - Xs)/(a-1);
Yincr = (Ye - Ys)/(b-1);
Zincr = (Ze - Zs)/(c-1);
dCostx = zeros(a , b , c); dCostm = zeros(a , b , c);
dCosty = zeros(a , b , c); dCostn = zeros(a , b , c);
dCostz = zeros(a , b , c); dCostp = zeros(a , b , c);
N = a* b * c;
  for i = 1 : a
        for j = 1 : b
            for k = 1 : c
                Ref = [(Xs+((i-1)*Xincr)), (Ys+((j-1)*Yincr)) , (Zs+((k-1)*Zincr))];
                R = sqrt((Ref(1) - mu_a)^2 + (Ref(2) - mu_b)^2 + (Ref(3) - mu_c)^2);
                L = (m*(Ref(1)-mu_a)) + (n*(Ref(2) - mu_b)) + (p*(Ref(3) - mu_c)); 
                C1 = 4*pi*(sqrt((Ref(1)-mu_a)^2 + (Ref(2) - mu_b)^2 + (Ref(3) - mu_c)^2))^3;
                C2 = 4*pi*(sqrt((Ref(1)-mu_a)^2 + (Ref(2) - mu_b)^2 + (Ref(3) - mu_c)^2))^5;
                C3 = 4*pi*(sqrt((Ref(1)-mu_a)^2 + (Ref(2) - mu_b)^2 + (Ref(3) - mu_c)^2))^7;
                dCostx(i , j , k) = 2*((-15*mue0*(Ref(1) - mu_a)^2*L/C3) + (2*3*m*mue0*(Ref(1) - mu_a)/C2) + (3*mue0*L/C2))*...
                    (Bx_EPS(i , j, k) - (3*mue0*(Ref(1) - mu_a)*L/C2) + (m*mue0/C1)) + ...
                    2*((-15*mue0*(Ref(1) - mu_a)*(Ref(2) - mu_b)*L/C3) + (3*mue0*n*(Ref(1) - mu_a)/C2) + (3*m*mue0*(Ref(2) - mu_b)/C2))*...
                    (By_EPS(i , j , k) -(3*mue0*(Ref(2) - mu_b)*L/C2) + (mue0*n/C1)) + ...
                    2*((-15*mue0*(Ref(1) - mu_a)*(Ref(3) - mu_c)*L/C3) + (3*mue0*p*(Ref(1) - mu_a)/C2) + (3*m*mue0*(Ref(3) - mu_c)/C2))*...
                    (Bz_EPS(i , j , k) - (3*mue0*(Ref(3) - mu_c)*L/C2) + (mue0*p/C1));
                
                dCosty(i , j , k) = 2*((-15*mue0*(Ref(1) - mu_a)*(Ref(2) - mu_b)*L/C3) + (3*mue0*n*(Ref(1) - mu_a)/C2) + (3*m*mue0*(Ref(2) - mu_b)/C2))*...
                    (Bx_EPS(i , j , k) - (3*mue0*(Ref(1) - mu_a)*L/C2) + (m*mue0/C1)) + ...
                    2*((-15*mue0*(Ref(2) - mu_b)^2*L/C3) + (2*3*mue0*n*(Ref(2) - mu_b)/C2) + (3*mue0*L/C2))*...
                    (By_EPS(i , j , k) - (3*mue0*(Ref(2) - mu_b)*L/C2) + (mue0*n/C1)) + ...
                    2*((-15*mue0*(Ref(2) - mu_b)*(Ref(3) - mu_c)*L/C3) + (3*mue0*p*(Ref(2) - mu_b)/C2) + (3*mue0*n*(Ref(3) - mu_c)/C2))*...
                    (Bz_EPS(i , j , k) - (3*mue0*(Ref(3) -mu_c)*L/C2) + (mue0*p/C1));
                
                dCostz(i , j , k) = 2*((-15*mue0*(Ref(1) - mu_a)*(Ref(3) - mu_c)*L/C3) + (3*mue0*p*(Ref(1) - mu_a)/C2) + (3*mue0*m*(Ref(3) - mu_c)/C2))*...
                    (Bx_EPS(i , j , k) - (3*mue0*(Ref(1) - mu_a)*L/C2) + (m*mue0/C1)) + ...
                    2*((-15*mue0*(Ref(2) - mu_b)*(Ref(3) - mu_c)*L/C3) + (3*mue0*p*(Ref(2) - mu_b)/C2) + (3*mue0*n*(Ref(3) - mu_c)/C2))*...
                    (By_EPS(i , j , k) - (3*mue0*(Ref(2) - mu_b)*L/C2) + (mue0*n/C1)) + ...
                    2*((-15*mue0*(Ref(3) - mu_c)^2*L/C3) + (3*2*mue0*p*(Ref(3) - mu_c)/C2) + (3*mue0*L/C2))*...
                    (Bz_EPS(i , j , k) - (3*mue0*(Ref(3) - mu_c)*L/C2) + (mue0*p/C1));
                
                dCostm(i , j , k) = 2*((-3*mue0*(Ref(1) - mu_a)^2/C2) + (mue0/C1))*(Bx_EPS(i , j ,k) - (3*mue0*(Ref(1) -mu_a)*L/C2) + (m*mue0/C1)) - ...
                    ((2*3*mue0*(Ref(1) - mu_a)*(Ref(2) - mu_b)/C2)*(By_EPS(i , j , k) - (3*mue0*(Ref(2) - mu_b)*L/C2) + (mue0*n/C1))) -...
                    ((2*3*mue0*(Ref(1) - mu_a)*(Ref(3) - mu_c)/C2)*(Bz_EPS(i , j , k) - (3*mue0*(Ref(3) - mu_c)*L/C2) + (mue0*p/C1)));
                
                dCostn(i , j , k) = ((-2*3*mue0*(Ref(1) - mu_a)*(Ref(2) - mu_b)/C2)*(Bx_EPS(i , j , k) - (3*mue0*(Ref(1) - mu_a)*L/C2) + (m*mue0/C1))) +...
                    2*((-3*mue0*(Ref(2) - mu_b)^2/C2) + (mue0/C1))*(By_EPS(i , j ,k) - (3*mue0*(Ref(2) - mu_b)*L/C2) + (mue0*n/C1)) - ...
                    ((2*3*mue0*(Ref(2) - mu_b)*(Ref(3) - mu_c)/C2)*(Bz_EPS(i , j ,k) - (3*mue0*(Ref(3) - mu_c)*L/C2) + (mue0*p/C1)));
                
                dCostp(i , j , k) = ((-2*3*mue0*(Ref(1) - mu_a)*(Ref(3) - mu_c)/C2)*(Bx_EPS(i , j, k) - (3*mue0*(Ref(1) - mu_a)*L/C2) + (m*mue0/C1))) -...
                    ((2*3*mue0*(Ref(2) - mu_b)*(Ref(3) - mu_c)/C2)*(By_EPS(i , j, k) - (3*mue0*(Ref(2) - mu_b)*L/C2) + (mue0*n/C1))) +...
                    2*((-3*mue0*(Ref(3) - mu_c)^2/C2) + (mue0/C1))*(Bz_EPS(i , j , k) - (3*mue0*(Ref(3) - mu_c)*L/C2) + (mue0*p/C1));
            end
        end
  end
 dCostx_max = [max(dCostx, [] , 'all'),min(dCostx, [] , 'all')];
 [gg ,ff] = max(abs(dCostx_max)); dCostx = gg*sign(dCostx_max(ff));
 dCosty_max = [max(dCosty, [] , 'all'),min(dCosty, [] , 'all')];
 [gg ,ff] = max(abs(dCostx_max)); dCosty = gg*sign(dCosty_max(ff));
 dCostz_max = [max(dCostz, [] , 'all'),min(dCostz, [] , 'all')];
 [gg ,ff] = max(abs(dCostz_max)); dCostz = gg*sign(dCostz_max(ff));
 dCostm_max = [max(dCostm, [] , 'all'),min(dCostm, [] , 'all')];
 [gg ,ff] = max(abs(dCostm_max)); dCostm = gg*sign(dCostm_max(ff));
 dCostn_max = [max(dCostn, [] , 'all'),min(dCostn, [] , 'all')];
 [gg ,ff] = max(abs(dCostn_max)); dCostn = gg*sign(dCostn_max(ff));
 dCostp_max = [max(dCostp, [] , 'all'),min(dCostp, [] , 'all')];
 [gg ,ff] = max(abs(dCostp_max)); dCostp = gg*sign(dCostp_max(ff));
end