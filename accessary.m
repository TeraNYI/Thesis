H = 1:24; % Time in hours
N = 30;   % Number of households

% Define Time-of-Use (TOU) tariff using an anonymous function
TOU_tariff_func = @(t) (t >= 7 & t <= 10) * 0.30 + ... % Peak hours: 7 AM to 10 AM
                       (t >= 17 & t <= 20) * 0.30 + ... % Peak hours: 5 PM to 8 PM
                       (t >= 11 & t <= 16) * 0.20 + ... % Shoulder hours: 11 AM to 4 PM
                       ((t < 7 | t > 20) & (t < 11 | t > 16)) * 0.10; % Off-peak hours

TOU_tariff = TOU_tariff_func(H); % Time-of-Use tariff 

rng(1);                       % Seed for reproducibility
P_flat = zeros(length(H), N); % N demand profiles
P_ev = zeros(length(H), N);   % preallocated EV charging demand profiles

E_ev_max = 50;    % Maximum EV battery capacity (kWh)
E_ev_min = E_ev_max*0.8;     % Minimum EV battery capacity (at least 70% of max)
E_ev = (E_ev_max*0.75)*ones(1, N);           % N EV charging demand profiles

for i = 1:N                   % Generate N random household demand profiles
    P_flat(:, i) = household_demand(H);
    E_ev(i) = E_ev(i)-EV_demand; % initial EV cpacity
end

%a = 1;    % electricity price ($/kWh)
%eff = 1;  % EV charging efficiency
T_limit = max(sum(P_flat,2)) + 1;     % Transformer Thermal Limit (kW)


%%
% AMPL
ampl = AMPL('/Applications/AMPL/');
ampl.read('kkt_modified.mod');
ampl.setOption('solver', 'gurobi');
%ampl.setOption('gurobi_options', 'nonconvex=2');
ampl.eval('option solver;');
% Assign data to AMPL

% Set
ampl.getSet('H').setValues(num2cell(H'))
ampl.getSet('N').setValues(num2cell((1:N)')) 

% Transformer capacity
ampl.getParameter('Pmax_total').set(T_limit);

% Inflexible demand
df = DataFrame(2, 'H', 'N', 'p_inf');
df.setMatrix(P_flat, H, 1:N)
ampl.setData(df)

% EV energy at the start
df = DataFrame(1, 'N', 'e_ev');
df.setMatrix(E_ev, 1:N)
ampl.setData(df)

% EV minimum energy requirement
E_ev_min_vec = E_ev_min * ones(1, N);
df = DataFrame(1, 'N', 'E_ev_min');
df.setMatrix(E_ev_min_vec, 1:N)
ampl.setData(df)

% TOU tariff
df = DataFrame(1, 'H', 'tau');
df.setMatrix(TOU_tariff, H)
ampl.setData(df)

ampl.solve()

sol = ampl.getVariable('p_ev').getValues();
p = sol.getColumnAsDoubles('p_ev.val');
P_ma = reshape(p, N, []).';

P_ma = reshape(p, N, []).';
E_ev_new = E_ev + sum(P_ma)



%% Plotting
% Compute statistics for P_flat
P_cumulative = sum(P_flat, 2);   % Cumulative demand (total load)
P_avg_of_avg = mean(P_cumulative); % Average of cumulative demand
P_peak_of_peaks = max(P_cumulative); % Peak of cumulative demand

% Combine all plots into one figure
figure;

% Subplot 1: Stacked bar chart of household demand profiles
subplot(3, 2, 3);
hold on;
bar(H, P_flat', 'stacked'); % Stacked bar chart for all profiles
plot(H, sum(P_flat, 2), 'w', 'LineWidth', 2); % Total load as a black line
yline(T_limit, 'r--', 'LineWidth', 1.5, 'Label', 'Transformer Limit'); % Transformer thermal limit
xlabel('Time (hours)'); xticks(0:2:24);
ylabel('Power Demand (kW)'); ylim([0 55]);
title('Household Demand Profiles');
grid on;
hold off;

% Subplot 2: Stacked bar chart of demand + EV profiles
subplot(3, 2, 4);
hold on;
bar(H, (P_flat + P_ma)', 'stacked'); % Stacked bar chart for all profiles
plot(H, sum(P_flat, 2), 'w', 'LineWidth', 2); % Total load as a black line
yline(T_limit, 'r--', 'LineWidth', 1.5, 'Label', 'Transformer Limit'); % Transformer thermal limit
xlabel('Time (hours)'); xticks(0:2:24);
ylabel('Power Demand (kW)'); ylim([0 55]);
title('Demand + EV Profiles');
grid on;
hold off;

% Subplot 3: Stacked bar chart of EV charging profiles with TOU zones highlighted
subplot(3, 2, 1);
hold on;

% Highlight TOU zones
fill([6.5 10.5 10.5 6.5], [0 0 55 55], [1 0.8 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.3); % Peak (7-10 AM)
fill([16.5 20.5 20.5 16.5], [0 0 55 55], [1 0.8 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.3); % Peak (5-8 PM)
fill([10.5 16.5 16.5 10.5], [0 0 55 55], [0.8 0.8 1], 'EdgeColor', 'none', 'FaceAlpha', 0.3); % Shoulder (11 AM-4 PM)

% Plot EV charging profiles
bar(H, P_ma, 'stacked'); % Stacked bar chart for EV charging profiles
xlabel('Time (hours)'); xticks(0:2:24);
ylabel('Charging (kW)'); ylim([0 55]);
title('EV Charging Profiles with TOU Zones');
grid on;
hold off;

% Subplot 4: Bar chart of initial EV energy levels
subplot(3, 2, 5);
bar(E_ev);
xlabel('Households'); xticks(1:2:N);
ylabel('Energy (kWh)'); ylim([0 50]);  yline(40, "r--");
title('Initial EV Energy Levels');
grid on;

% Subplot 5: Bar chart of updated EV energy levels
subplot(3, 2, 6);
bar(E_ev_new);
xlabel('Households'); xticks(1:2:N);
ylabel('Energy (kWh)'); ylim([0 50]); yline(40, "r--");
title('Charged EV Energy Levels');
grid on;


%%
function P = household_demand(t)
    % Parameters
    P_base = 0.5;      % Base load (kW)
    P_morning = 1.0 + 0.4 * randn; % Add randomness to morning peak
    P_evening = 1.3 + 0.5 * randn; % Add randomness to evening peak
    t_m = 7;           % Morning peak time (7 AM)
    t_e = 19;          % Evening peak time (7 PM)
    sigma = 2.8 + 0.3 * randn; % Slight randomness in spread

    % Gaussian-based demand model
    P = P_base + P_morning * exp(-((t - t_m).^2) / sigma^2) ...
              + P_evening * exp(-((t - t_e).^2) / sigma^2);
end

function E = EV_demand
    E_base = 6;                 % Base load (kWh)
    E = E_base + 2 * randn; % Random EV charging demand
end