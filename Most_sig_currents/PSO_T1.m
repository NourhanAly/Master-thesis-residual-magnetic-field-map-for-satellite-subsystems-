clear all
clc
fitness = @Obj_PSO;
nvars = 6;
lb = [-5e-2 , -5e-2 , -15e-2 ,-1e-4 , -1e-4 , -1e-4 ];
ub = [5e-2 , 5e-2 , 15e-2 , 1e-4 , 1e-4 , 1e-4];
options = optimoptions(@particleswarm,'PlotFcn','pswplotbestf' , 'Display' , 'iter' ,...
    'FunctionTolerance' , 1e-20 , 'ObjectiveLimit' , 1e-20)
[x , fval,exitflag,output] = particleswarm(fitness  , nvars ,lb , ub , options)