%salt_viscosity - explore the deformation map of salt
%   Compares different viscosity models and illustrates the impact of the 
%   various input parameters.
%
%   All these figures are published in Cornet et al, 2018: 
%   Long term creep closure of salt cavities, Int. J. Rock Mech. Min. Sc.
% 
%   TODO: I don't think the next line is a correct statement. e.g. mm is
%   not a standard SI unit, maybe you should call it metric
%   Units used: SI 
%
%   May, 2021, Jan Cornet

%% Constants
Rg      = 8.3144;                        % [J*K-1*mol-1] universal gas constant
C2K     = 273.15;                        % []
year    = 3600*24*365;                   % [s]

%% User Input 
% Used where not overwritten by plot specific choices
T_cel   = 60;                            % [C] temperature
T       = T_cel + C2K;                   % [K] temperature

d       = 3;                             % [mm] grain size

% Dislocation creep parameters
% TODO: units, reference
n   = 4.5;
A01	= 2*1e-4;
Q1  = 62.3*1e3;

% Pressure solution parameters
% TODO: units, reference
A02	= 4.7*1e-4;
Q2  = 24.53*1e3;

%% Viscosity models
A1  = @(T, n) 2./( sqrt(3).^(n+1)*A01.*exp(-Q1./(Rg*T)) );
A2  = @(T, d) 2./( 3*A02*exp(-Q2./(Rg*T)) ./ (T*d.^3) );

mu_app_dislocation	= @(D, T, n) A1(T, n).^(1/n)/2*D.^(1/n-1)*1e6;                                         % nonlinear -  power law - dislocation creep
mu_app_diffusion    = @(T, d) A2(T, d)/2*1e6;                                                              % linear - pressure solution
mu_app_ellis        = @(D, T, n, d) 1 ./ ( 1./mu_app_dislocation(D, T, n) + 1./mu_app_diffusion(T, d) );   % ellis model
mu_app_carreau      = @(Dtrans, D, T, n, d) mu_app_diffusion(T, d).*(1+(D./Dtrans).^2).^((1/n-1)/2);       % carreau model

% Transition rate of deformation between linear and nonlinear behavior
Dtrans              = @(T, d, n) 1./A2(T, d).*(A1(T, n)./A2(T, d)).^(1/(n-1));                             

%% 1. Comparison of Linear, Power Law, Carreau and Ellis
% Figure and axes setup
h_fig1   = figure('Name', 'Viscosity Model Comparison', 'Numbertitle', 'off');
h_ax    = axes(h_fig1);
hold(h_ax, 'on');

% Range of rate of deformation
D_vec = logspace(-15,-6, 1000)';  % [1/s] second invariant of the rate of deformation tensor

% Plot
plot(h_ax, D_vec, mu_app_diffusion(T, d)*ones(size(D_vec)),        'k',   'Linewidth', 1, 'DisplayName', 'Newtonian');
plot(h_ax, D_vec, mu_app_dislocation(D_vec, T, n),                 'k--', 'Linewidth', 1, 'DisplayName', 'Power Law');
plot(h_ax, D_vec, mu_app_carreau(Dtrans(T, d, n), D_vec, T, n, d), 'k',   'Linewidth', 2, 'DisplayName', 'Carreau');
plot(h_ax, D_vec, mu_app_ellis(D_vec, T, n, d),                    'k:',  'Linewidth', 2, 'DisplayName', 'Ellis');

% Ornaments
set(h_ax, 'Yscale', 'log', 'XScale', 'log', 'XLim', [min(D_vec), max(D_vec)], 'Box', 'on');
grid(h_ax, 'on');
xlabel(h_ax, 'D_{II}');
ylabel(h_ax, '\mu_{app}'); % TODO what is mu_app
title(h_ax, ['T = ', num2str(T_cel), ' [C], Grain Size = ', num2str(d), ' [mm] , Power Law n = ', num2str(n), ' []'], 'FontWeight', 'normal');
legend(h_ax);

%% 2. Deformation Map
% Figure and axes setup
h_fig2   = figure('Name', 'Deformation Map', 'Numbertitle', 'off');
h_fig2.Position = h_fig1.Position + [20, -20, 0, 0];
h_ax	= axes(h_fig2);
hold(h_ax, 'on');

% Define plot styles
style = {'k+-', 'k--', 'k-', 'k:', 'k-.'};

% Grain size range
d_vec = logspace(-1, 1, 101); % [mm] grain size

% Contribution comparison of pressure solution and dislocation creep
% essentially mapping the transition between the two deformation mechanisms
Cs = [10, 1, 0.1];
for i = 1:length(Cs)    
    plot(h_ax, d_vec, (Cs(i)*A1(T, n)./A2(T, d_vec)).^(1/(n-1))*1e6, style{i+1}, 'Linewidth', .5, 'DisplayName', ['D_{D-II}/D_{P-II} = ', num2str(Cs(i))]);
end

% Ornaments
set(h_ax, 'Yscale', 'log', 'XScale', 'log', 'XLim', [min(d_vec), max(d_vec)], 'YLim', [1e5 1e8], 'Box', 'on');
grid(h_ax, 'on');
xlabel(h_ax, 'Grain size [mm]');
ylabel(h_ax, '\tau_{II} [Pa]');
title(h_ax, ['T = ', num2str(T_cel), ' [C], Power Law n = ', num2str(n), ' []'], 'FontWeight', 'normal');

legend(h_ax, 'Location', 'southeastoutside');

% Add a second axes on top of the previous one to plot viscosities for 
% specific rates of deformations
h_ax2 = axes(h_fig2);
hold(h_ax2, 'on');

% Range of rate of deformation
D_vec = [1e-6, 1e-8, 1e-9, 1e-10, 1e-12]; % [1/s] second invariant of the rate of deformation tensor
for i = 1:length(D_vec)    
    plot(h_ax2, d_vec, 2*mu_app_carreau( Dtrans(T, d_vec, n), D_vec(i), T, n, d_vec).*D_vec(i), style{i}, 'Linewidth', 1, 'DisplayName', ['D_{II} = ', num2str(D_vec(i), '%g')]);
end

% Ornaments second axes
set(h_ax2, 'Yscale', 'log', 'XScale', 'log', 'XLim', [min(d_vec), max(d_vec)], 'YLim', [1e5 1e8], ...
    'Color', 'none', 'XTick', [], 'YTick', [], 'Box','off');
legend(h_ax2, 'Location', 'northeastoutside', 'Color', 'w');

% Make sure the two axes use the same space.
linkprop([h_ax,h_ax2], 'Position');

%% 3. Influence of Temperature, Grain Size and Dislocation Creep Parameters
% Figure setup
h_fig3   = figure('Name', 'Parameter Influence', 'Numbertitle', 'off');
h_fig3.Position = h_fig2.Position + [20, -20, 0, 0];

% Define plot styles
style = {'k-', 'k-.', 'k:', 'k--'};

% Investigated parameters (n remains 4.5 as before)
d     = 7.5; % [mm] grain size
n     = 4.5; % [] power law exponent
D_vec = logspace(-15, 0, 1000)';  % [1/s] second invariant of the rate of deformation tensor

%% - Temperature influence
% Investigated parameters
T_cel_vec = 20:40:140;                % [C] temperature
T_vec     = T_cel_vec + C2K;              % [K] temperature

% Axes setup
h_ax(1) = subplot(3, 2, 1, 'parent', h_fig3);
h_ax(2) = subplot(3, 2, 2, 'parent', h_fig3);
hold(h_ax, 'on');

% Plot
for i=1:length(T_vec)
    plot(h_ax(1), D_vec,   mu_app_carreau( Dtrans(T_vec(i), d, n), D_vec, T_vec(i), n, d),        style{i}, 'Linewidth', 1, 'DisplayName', ['T = ', num2str(T_cel_vec(i)), ' [C], Carreau']); 
    plot(h_ax(2), D_vec, 2*mu_app_carreau( Dtrans(T_vec(i), d, n), D_vec, T_vec(i), n, d).*D_vec, style{i}, 'Linewidth', 1, 'DisplayName', ['T = ', num2str(T_cel_vec(i)), ' [C], Carreau']); 
end

% Ornaments - general
set(h_ax, 'Yscale', 'log', 'XScale', 'log',  'XLim', [1e-15, 1e-5], 'Box', 'on');
axis(h_ax, 'square');
grid(h_ax, 'on');
xlabel(h_ax, 'D_{II} [s^{-1}]');
title(h_ax, ['Grain Size = ', num2str(d), ' [mm], Power Law n = ', num2str(n), ' []'], 'FontWeight', 'normal');

% Ornaments - axes specific
set(h_ax(1), 'YLim', [1e10 1e20]);
set(h_ax(2), 'YLim', [1e0  1e10]);
ylabel(h_ax(1), '\mu_{app} [Pa*s]');
ylabel(h_ax(2), '\tau_{II} [Pa]');
legend(h_ax(1), 'Location', 'southwest');
legend(h_ax(2), 'Location', 'southeast');

%% - Grain size influence
% Investigated parameters
d_vec = [1e3, 7.5, 1, .1]; % [mm] grain size
T_cel = 60;                % [C] temperature
T     = T_cel + C2K;       % [K] temperature

% Axes setup
h_ax(1) = subplot(3, 2, 3, 'parent', h_fig3);
h_ax(2) = subplot(3, 2, 4, 'parent', h_fig3);
hold(h_ax, 'on');

% Plot
for i=1:length(d_vec)
    plot(h_ax(1), D_vec,   mu_app_carreau( Dtrans(T, d_vec(i), n), D_vec, T, n, d_vec(i)),        style{i}, 'Linewidth', 1, 'DisplayName', ['d = ', num2str(d_vec(i)), ' [mm], Carreau']); 
    plot(h_ax(2), D_vec, 2*mu_app_carreau( Dtrans(T, d_vec(i), n), D_vec, T, n, d_vec(i)).*D_vec, style{i}, 'Linewidth', 1, 'DisplayName', ['d = ', num2str(d_vec(i)), ' [mm], Carreau']);        
end

% Ornaments - general
set(h_ax, 'Yscale', 'log', 'XScale', 'log',  'XLim', [1e-15, 1e-5], 'Box', 'on');
axis(h_ax, 'square');
grid(h_ax, 'on');
xlabel(h_ax, 'D_{II} [s^{-1}]');
title(h_ax, ['T = ', num2str(T_cel), ' [C], Power Law n = ', num2str(n), ' []'], 'FontWeight', 'normal');

% Ornaments - axes specific
set(h_ax(1), 'YLim', [1e10 1e20]);
set(h_ax(2), 'YLim', [1e0  1e10]);
ylabel(h_ax(1), '\mu_{app} [Pa*s]');
ylabel(h_ax(2), '\tau_{II} [Pa]');
legend(h_ax(1), 'Location', 'southwest');
legend(h_ax(2), 'Location', 'southeast');

%% - Dislocation creep parameters influence
% % Investigated parameters: 3 different salts
n_vec   = [3.14, 4.5, 6.25];
A01_vec = [4.12e-4, 2e-4, 8e-4]; % TODO: Why up and down?
Q1_vec  = [54e3, 62.3e3, 82.9e3];

% Axes setup
h_ax(1) = subplot(3, 2, 5, 'parent', h_fig3);
h_ax(2) = subplot(3, 2, 6, 'parent', h_fig3);
hold(h_ax, 'on');

% Plot
for i=1:length(n_vec)
    % Update viscosity functions
    A1     = @(T, n) 2./( sqrt(3).^(n+1)*A01_vec(i).*exp(-Q1_vec(i)./(Rg*T)) );
    Dtrans = @(T, d, n) 1./A2(T, d).*(A1(T, n)./A2(T, d)).^(1/(n-1));
   
    % Plot
    plot(h_ax(1), D_vec,   mu_app_carreau( Dtrans(T, d, n_vec(i)), D_vec, T, n_vec(i), d),    style{i}, 'Linewidth', 1, 'DisplayName', ['Salt ', num2str(i)]);     
    plot(h_ax(2), D_vec, 2*mu_app_carreau( Dtrans(T, d, n_vec(i)), D_vec, T, n_vec(i), d).*D_vec, style{i}, 'Linewidth', 1, 'DisplayName', ['Salt ', num2str(i)]);     
end

% Ornaments - general
set(h_ax, 'Yscale', 'log', 'XScale', 'log',  'XLim', [1e-15, 1e-5], 'Box', 'on');
axis(h_ax, 'square');
grid(h_ax, 'on');
xlabel(h_ax, 'D_{II} [s^{-1}]');
title(h_ax, ['T = ', num2str(T_cel), ' [C], Grain Size = ', num2str(d), ' [mm]'], 'FontWeight', 'normal');

% Ornaments - axes specific
set(h_ax(1), 'YLim', [1e10 1e20]);
set(h_ax(2), 'YLim', [1e0  1e10]);
ylabel(h_ax(1), '\mu_{app} [Pa*s]');
ylabel(h_ax(2), '\tau_{II} [Pa]');
legend(h_ax(1), 'Location', 'southwest');
legend(h_ax(2), 'Location', 'southeast');

%% 4. D_Transition and Tau_transition as a function of temperature, grain size, and different salts
% Figure setup
h_fig4   = figure('Name', 'Transition', 'Numbertitle', 'off');
h_fig4.Position = h_fig3.Position + [20, -20, 0, 0];

% Investigated parameters 
% At this stage we "inherit" Salt 3 parameters A1 and Dtrans from the 
% previous section, but we have to set n to also reflect Salt 3
n     = n_vec(3);                   % [] power law exponent
d_vec = logspace(-1, 1, 1001);      % [mm] grain size

%% - Temperature influence
% Investigated parameters
T_cel_vec   = 20:40:140;                  % [C] temperature
T_vec       = T_cel_vec + C2K;            % [K] temperature

% Axes setup
h_ax(1) = subplot(2, 2, 1, 'parent', h_fig4);
h_ax(2) = subplot(2, 2, 3, 'parent', h_fig4);
hold(h_ax, 'on');

% Plot
for i=1:length(T_vec)
    plot(h_ax(1), d_vec,                                      Dtrans(T_vec(i), d_vec, n)*year, style{i}, 'Linewidth', 1, 'DisplayName', ['T = ', num2str(T_cel_vec(i)), ' [C]']); 
    plot(h_ax(2), d_vec, 2*mu_app_diffusion(T_vec(i), d_vec).*Dtrans(T_vec(i), d_vec, n)/1e6,  style{i}, 'Linewidth', 1, 'DisplayName', ['T = ', num2str(T_cel_vec(i)), ' [C]']); 
end

% Ornaments - general
set(h_ax, 'Yscale', 'log', 'XScale', 'log',  'XLim', [min(d_vec), max(d_vec)], 'Box', 'on');
grid(h_ax, 'on');
xlabel(h_ax, 'Grain size [mm]');
title(h_ax, 'Salt 3', 'FontWeight', 'normal');

% Ornaments - axes specific
set(h_ax(1), 'YLim', [1e-6 1e4]);
set(h_ax(2), 'YLim', [1e-1 1e2]);
ylabel(h_ax(1), 'D_{II}^* [year^{-1}]');
ylabel(h_ax(2), '\tau_{II}^* [MPa]');
legend(h_ax(1), 'Location', 'southwest');
legend(h_ax(2), 'Location', 'southwest');

%% - Different salt influence
% Investigated parameters
T_cel   = 60;                  % [C] temperature
T       = T_cel + C2K;         % [K] temperature

% Axes setup
h_ax(1) = subplot(2, 2, 2, 'parent', h_fig4);
h_ax(2) = subplot(2, 2, 4, 'parent', h_fig4);
hold(h_ax, 'on');

% Plot
for i=1:length(n_vec)
    % Update viscosity functions
    A1     = @(T, n) 2./( sqrt(3).^(n+1)*A01_vec(i).*exp(-Q1_vec(i)./(Rg*T)) );
    Dtrans = @(T, d, n) 1./A2(T, d).*(A1(T, n)./A2(T, d)).^(1/(n-1));
   
    % Plot
    plot(h_ax(1), d_vec,                               Dtrans(T, d_vec, n_vec(i))*year, style{i}, 'Linewidth', 1, 'DisplayName', ['Salt ', num2str(i)]);     
    plot(h_ax(2), d_vec, 2*mu_app_diffusion(T, d_vec).*Dtrans(T, d_vec, n_vec(i))/1e6,  style{i}, 'Linewidth', 1, 'DisplayName', ['Salt ', num2str(i)]);     
end

% Ornaments - general
set(h_ax, 'Yscale', 'log', 'XScale', 'log',  'XLim', [min(d_vec), max(d_vec)], 'Box', 'on');
grid(h_ax, 'on');
xlabel(h_ax, 'Grain size [mm]');
title(h_ax, ['T = ', num2str(T_cel), ' [C]'], 'FontWeight', 'normal');

% Ornaments - axes specific
set(h_ax(1), 'YLim', [1e-6 1e4]);
set(h_ax(2), 'YLim', [1e-1 1e2]);
ylabel(h_ax(1), 'D_{II}^* [year^{-1}]');
ylabel(h_ax(2), '\tau_{II}^* [MPa]');
legend(h_ax(1), 'Location', 'southwest');
legend(h_ax(2), 'Location', 'southwest');