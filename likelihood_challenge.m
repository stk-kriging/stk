%% Test...

clear all;  close all;  clc

nb_tests = 20;

rep_mode_list = {'ignore', 'gather'};

n_grd = 100;
n_obs = 100;
SIGMA_NOISE = 2;

for i = 1:nb_tests
    
    x_grd = stk_sampling_regulargrid (n_grd, 1, [-1; 1]);
    x_grd = x_grd.data;
    
    x_obs = x_grd(randi (n_grd, n_obs, 1), 1);
    z_obs = stk_testfun_twobumps (x_obs) + SIGMA_NOISE .* randn (n_obs, 1);
    
    model = stk_model ('stk_materncov52_iso');
    model.param = -2 + 4 * rand (2, 1);
    model.lognoisevariance = 2 * log (SIGMA_NOISE * (0.5 + rand));
    
    ALL(i, 1) = stk_param_relik (model, x_obs, z_obs);
    
    data = stk_iodata (x_obs, z_obs);
    ALL(i, 2) = stk_param_relik (model, data);
    
    data = stk_iodata (x_obs, z_obs, 'rep_mode', 'gather');
    ALL(i, 3) = stk_param_relik (model, data);
    
end

%%
for j = 2:3
    figure (j);
    plot (ALL(:, 1), ALL(:, j), 'k.');
    hold on;
    plot (xlim, xlim, 'r');
end


%#ok<*NOPTS>