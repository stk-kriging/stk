% VIEW_INIT_1D view function

% Copyright Notice
%
%    Copyright (C) 2011-2014 SUPELEC
%
%    Authors:   Ivana Aleksovska  <ivanaaleksovska@gmail.com>
%               Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>

% Copying Permission Statement
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

function view_init_1d(algo, xi, zi)

LINE1 = {'-', 'LineWidth', 2, 'Color', [0.39, 0.47, 0.64]};
LINE2 = {'-', 'LineWidth', 3, 'Color', [0.95 0.25 0.3]};
MARKER1 = {'ks','MarkerSize', 7, 'LineWidth', 2, ...
		'MarkerEdgeColor', [0.95 0.25 0.3], 'MarkerFaceColor', [0.8 0.8 0.8]};
	
xt0 = algo.disp_xvals;
zt0 = algo.disp_zvals;

[xt, ind] = sort([xi.data; xt0.data]);
[~, ind]  = sort(ind);
xi_ind_ = ind(1:stk_length(xi));
xt = stk_dataframe(xt);

[zp_, lambda_] = stk_predict(algo.model, xi, zi, xt);

% prediction + (maximizer density) + sampling criterion
if algo.show1dsamplepaths
    
    zsim_ = stk_generate_samplepaths(algo.model, xt, 4000);
	zsimc_ = stk_conditioning (lambda_, zi, zsim_, xi_ind_);
	[~, ind_maximum] = max(zsimc_.data);
   
    figure(1) % prediction + true function
	plot_1(xi, zi, xt, zp_, xt0, zt0);
	stk_labels('x', 'f(x)');
	stk_title('Evaluations and kriging prediction');
	
	figure(2)
    if algo.show1dmaximizerdens == 2, subplot(3,1,1); else subplot(2,1,1); end
	plot_1(xi, zi, xt, zp_);
	hold on
	plot(xt.data, zsimc_.data(:,1:8), LINE1{:})
	plot(xt.data, zp_.mean, LINE2{:})
	plot(xi.data, zi.data, MARKER1{:})
	hold off
	stk_labels('', 'f(x)');
	stk_title('Function to be maximized (dashed blue line) and kriging prediction');
    
    if algo.show1dmaximizerdens > 0
        if algo.show1dmaximizerdens == 1, subplot(2,1,2); end
        if algo.show1dmaximizerdens == 2; subplot(3,1,2); end
        plot(xt.data, ksdensity(xt.data(ind_maximum,:), xt.data, ...
			'width', 20*length(unique(ind_maximum))*(algo.box(2) - algo.box(1))/stk_length(xt0)^2), ...
            LINE1{:})
        stk_labels('x', 'f(x)');
        stk_title('Maximizer density');
        if algo.show1dmaximizerdens == 1, disp('disp maximizer density (pause)'); pause;  end
    end

else
    
    figure(2)
	subplot(2,1,1)
	plot_1(xi, zi, xt, zp_, xt0, zt0); hold on
	plot(xt.data, zp_.mean, LINE2{:});
	plot(xi.data, zi.data, MARKER1{:});
    % plot(xlim(), max(zi.data)*[1 1], '--', 'LineWidth', 2, 'Color', [0.5, 0.5, 0.5]);
    % axis([-1 1 -4.5 3.5])
	hold off
	stk_labels('', 'f(x)');
	stk_title('Function to be maximized (dashed blue line) and kriging prediction');
    h=gca;
    set(h,'Box', 'off')
    set(h,'FontSize', 18)
end
end