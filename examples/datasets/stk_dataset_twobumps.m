% STK_DATASET_TWOBUMPS defines datasets based on the TwoBumps response function

% Copyright Notice
%
%    Copyright (C) 2016 CentraleSupelec
%
%    Authors:  Julien Bect       <julien.bect@centralesupelec.fr>
%              Emmanuel Vazquez  <emmanuel.vazquez@centralesupelec.fr>

% Copying Permission Statement  (STK toolbox)
%
%    This file is part of
%
%            STK: a Small (Matlab/Octave) Toolbox for Kriging
%               (http://sourceforge.net/projects/kriging)
%
%    STK is free software: you can redistribute it and/or modify it under
%    the terms of the GNU General Public License as published by the Free
%    Software Foundation,  either version 3  of the License, or  (at your
%    option) any later version.
%
%    STK is distributed  in the hope that it will  be useful, but WITHOUT
%    ANY WARRANTY;  without even the implied  warranty of MERCHANTABILITY
%    or FITNESS  FOR A  PARTICULAR PURPOSE.  See  the GNU  General Public
%    License for more details.
%
%    You should  have received a copy  of the GNU  General Public License
%    along with STK.  If not, see <http://www.gnu.org/licenses/>.

% Copying Permission Statement  (this file)
%
%    To the extent possible under law,  Julien Bect  and Emmanuel Vazquez
%    have waived  all copyright  and related  or neighboring rights to
%    stk_dataset_twobumps.m.  This work is published from France.
%
%    License: CC0  <http://creativecommons.org/publicdomain/zero/1.0/>

function [xi, zi, ref] = stk_dataset_twobumps (dataset_name, simulate)

if nargin < 2
    % Default: use saved versions of noisy datasets (for reproducibility)
    simulate = false;
end

ref.f = @stk_testfun_twobumps;

% Factor space (i.e., input space)
ref.box = [-1.0; 1.0];

% Reference dataset
ref.xt = stk_sampling_regulargrid (400, [], ref.box);
ref.zt = stk_feval (ref.f, ref.xt);

switch dataset_name
    
    case 'noiseless'
        
        % Indices of six evaluation points in xt
        ref.xi_ind = [1 20 90 200 300 350];
        
        % Evaluation points
        xi = ref.xt(ref.xi_ind, 1);
        
        % Evaluation results
        zi = stk_feval (ref.f, xi);
        
    case 'noisy1'
        
        % Number of noisy observations
        n = 20;
        
        % Standard deviation of the (Gaussian) observation noise
        ref.noise_std = 0.2;
        
        % Evaluation points on a regular grid
        xi = stk_sampling_regulargrid (n, [], ref.box);
        
        % Standard Gaussian noise
        if simulate
            u = randn (n, 1);
        else
            u = [ ...
                +2.494262357945395; -0.734979628183384; +0.482374373838845; ...
                +0.723297790408916; -0.698828108725056; -0.544234733755390; ...
                +0.200719359571192; +0.114419113713883; -2.430087055004133; ...
                +0.982006706100309; +1.043148691468279; +0.332804939718977; ...
                -0.014386709815515; -0.470223054833317; -0.504604762739981; ...
                +1.214912259853930; -0.514268293209969; +0.195757395918953; ...
                +1.517874831056133; +0.753351049482162];
        end
        
        % Evaluation results with homoscedastic Gaussian noise
        zi = stk_feval (ref.f, xi) + ref.noise_std * u;
        
    case 'noisy2'
        
        % Standard deviation function of the heteroscedastic noise
        ref.noise_std_func = @(x) 0.1 + (x + 1) .^ 2;

        % Evaluation points
        xi1 = stk_sampling_regulargrid (30, [], ref.box);
        xi2 = stk_sampling_regulargrid (50, [], [0; 1]);
        xi = [xi1; xi2];
        n = size (xi, 1);
        
        % Standard deviation of the noise
        ref.noise_std = ref.noise_std_func (xi.data);
                
        % Standard Gaussian noise
        if simulate
            u = randn (n, 1);
        else
            u = [ ...
                -0.791478467901437; -1.762943052690207; -0.001299829346851; ...
                +0.732147620330301; +0.605023011882157; -0.235236784824946; ...
                +1.229945155335280; +0.886837017097442; +0.488261575509975; ...
                +0.424488726533523; +1.754745494583444; -0.441222483623965; ...
                +0.879192878193787; +0.324020151981654; +0.084432929005424; ...
                -0.604693498668125; -0.031299228423533; +0.007433332039656; ...
                -0.107529006311618; +0.890983601251905; -0.696857251549359; ...
                -0.394367071934840; +1.209585103839413; +0.720950468832869; ...
                +0.188359447172079; -0.659677837960163; +0.254008558054221; ...
                -1.264954661580136; +0.816118804592636; +0.202455570359224; ...
                +0.734286747946277; -0.244906212630412; +0.274108676705772; ...
                -0.862005106214534; +0.434343874659720; -0.117332608645138; ...
                -0.914714934350702; +0.115661357086073; -0.325149459903396; ...
                +0.639533386284049; +0.509460672890649; -0.852768546081912; ...
                +0.186192416612840; +0.313594500855111; +0.294019880744365; ...
                -1.130158251045297; -0.766406113410912; -1.866775028802603; ...
                -0.947126212506609; +0.538816492914357; +0.511602507613618; ...
                +0.823135354100495; -1.756797156406481; -0.312291404135173; ...
                +0.087942003030425; +0.567707468547421; +2.032871465968247; ...
                +1.898136463799602; +0.017457787439612; -0.544269383534046; ...
                -0.031505371902443; -0.152838878112194; -1.329039092306233; ...
                +1.080298915753245; +1.010267794177553; -0.786523836101804; ...
                -1.172017693806294; +0.545622109584444; -0.565273496172850; ...
                +1.395393272315889; +2.249339864785413; +1.152166643543791; ...
                -0.529253078296878; -0.550879429738137; -0.658033963155681; ...
                -2.229148823293678; -0.883276090753784; -1.048334125700457; ...
                +0.787058154693710; +2.284606236947447];
        end

        % Evaluation results with homoscedastic Gaussian noise
        zi = stk_feval (ref.f, xi) + ref.noise_std .* u;
        
    otherwise
        
        error ('Unknown dataset name.');
        
end % switch

end % function
