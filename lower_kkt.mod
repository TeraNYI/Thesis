# =============================
# SETS
# =============================
set H;                        # Set of time periods

# =============================
# PARAMETERS
# =============================
param Pmax_total = 2.4;        # Total transformer capacity [kW]

param p_inf {h in H} >= 0;    # Inflexible load [kW]
param e_ev = 20;             # Existing EV energy at the start [kWh]
param E_ev_min = 40;         # Minimum EV energy requirement [kWh]
param tau {h in H} >= 0;              # Time-of-use tariff [$ per kWh]

# =============================
# VARIABLES
# =============================
var p_ev {h in H} >= 0;       # EV charging power [kW]
var p_max {h in H} >= 0;      # Maximum allowable transformer limit per user per time

# Dual variables (Lagrange multipliers)
var lambda {h in H} >= 0;    # Multiplier for transformer constraint
var lambda1 >= 0;            # Multiplier for energy constraint
var lambda2 {h in H} >= 0;    # Multiplier for transformer constraint

# Auxiliary variable for total load
var p_total {h in H} = p_inf[h] + p_ev[h];

# =============================
# OBJECTIVE
# =============================

minimize Objective: 0;

# =============================
# CONSTRAINTS
# =============================


# --- LOWER LEVEL REFORMULATED WITH KKT CONDITIONS ---

# 1. Stationarity
subject to Stationarity {h in H}:
    tau[h] - lambda[h] - lambda1 + lambda2[h] = 0;
    #tau[h] - lambda1 + lambda2[h] = 0; # without Time of Use Tariff

# 2. Primal Feasibility
subject to EV_Energy_Min:
    E_ev_min - e_ev - sum{h in H}p_ev[h] <= 0;

subject to Max_Load_Limit {h in H}:
    p_inf[h] + p_ev[h] - Pmax_total <= 0;

# 3. Dual Feasibility
# Already enforced by `>= 0` in variable declaration

# 4. Complementary Slackness

subject to CompSlack_Bound {h in H}:  # Add this constraint
    lambda[h] * p_ev[h] = 0;


subject to CompSlack_Energy:
    lambda1 * (E_ev_min - e_ev - sum{h in H}p_ev[h]) = 0;


subject to CompSlack_Transformer {h in H}:
    lambda2[h] * (p_inf[h] + p_ev[h] - Pmax_total) = 0;


#param M = 1e14;  # A large constant for the reformulation
#var z1 {n in N}, binary;
#
#subject to CompSlack_Energy_Reform1 {n in N}:
#    E_ev_min[n] - e_ev[n] - sum {h in H} p_ev[h,n] <= M * z1[n];
#
#subject to CompSlack_Energy_Reform2 {n in N}:
#    lambda1[n] <= M * (1 - z1[n]);

#var z2 {h in H, n in N}, binary;
#
#subject to CompSlack_Transformer_Reform1 {h in H, n in N}:
#    p_inf[h,n] + p_ev[h,n] - Pmax_total <= M * z2[h,n];
#
#subject to CompSlack_Transformer_Reform2 {h in H, n in N}:
#    lambda2[h,n] <= M * (1 - z2[h,n]);