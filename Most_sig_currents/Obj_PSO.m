function[RR] = Obj_PSO(X)
Xs = -5; Xe = 5; Ys = -5 ; Ye = 5; Zs = -15; Ze = 15;
Xs = Xs*0.01; Ys = Ys*0.01; Zs = Zs*0.01;
Xe = Xe*0.01; Ye = Ye*0.01; Ze = Ze*0.01;
mue0 = 1.25663753*10^-6;
load('EPS_new.mat')
[a b c] = size(B_EPS);
Xincr = (Xe - Xs)/(a-1);
Yincr = (Ye - Ys)/(b-1);
Zincr = (Ze - Zs)/(c-1);
Bx = zeros(a , b , c);
By = zeros(a , b , c);
Bz = zeros(a , b , c);
B = zeros(a , b ,c);
mu_a = []; mu_b = []; mu_c = [];
m = []; n = []; p = [];
for i = 1:6:length(X)
mu_a = [mu_a X(i)]; mu_b = [mu_b  X(i+1)]; mu_c = [mu_c X(i+2)];
m = [m X(i+3)]; n = [n X(i+4)]; p = [p X(i+5)];
end

for h = 1 : length(m)
   %S(h) = norm([m(h) ;n(h) ;p(h)]); e(: , h) = [m(h);n(h);p(h)]/S(h);
   %m(h) = e(1, h); n(h) = e(2,h); p(h) = e(3,h); 
    for i = 1 : a
        for j = 1 : b
            for k = 1 : c
                Ref = [(Xs+((i-1)*Xincr)), (Ys+((j-1)*Yincr)) , (Zs+((k-1)*Zincr))];
                R = sqrt((Ref(1) - mu_a(h))^2 + (Ref(2) - mu_b(h))^2 + (Ref(3) - mu_c(h))^2);
                C1 = mue0/(4*pi); C2 = m(h)*(Ref(1)-mu_a(h)) + n(h)*(Ref(2)-mu_b(h)) + p(h)*(Ref(3)-mu_c(h));
                Bx(i , j , k) = Bx(i , j ,k ) + C1*(3*(Ref(1)-mu_a(h))*C2/R^5)- C1*(m(h)/R^3);
                By(i , j , k) = By(i , j ,k ) + C1*(3*(Ref(2)-mu_b(h))*C2/R^5)- C1*(n(h)/R^3);
                Bz(i , j , k) = Bz(i , j ,k ) + C1*(3*(Ref(3)-mu_c(h))*C2/R^5)- C1*(p(h)/R^3);
                B(i , j , k) = B(i , j ,k ) + norm([Bx(i , j , k) , By(i , j , k) , Bz(i , j , k)]);
            
            end
         end
    end
    
end
RMS = sqrt(sum((B - B_EPS).^2 , 'all')/length(m));
RMS_x = sqrt(sum((Bx - Bx_EPS).^2 , 'all')/length(m));
RMS_y = sqrt(sum((By - By_EPS).^2 , 'all')/length(m));
RMS_z = sqrt(sum((Bz - Bz_EPS).^2 , 'all')/length(m));
RR = max([RMS , RMS_x , RMS_y , RMS_z]);
end

