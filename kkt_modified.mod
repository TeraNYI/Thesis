# =============================
# SETS
# =============================
set H;                        # Set of time periods
set N;                        # Set of consumers

# =============================
# PARAMETERS
# =============================
param Pmax_total >= 0;        # Total transformer capacity [kW]

param p_inf {h in H, n in N} >= 0;    # Inflexible load [kW]
param e_ev {n in N} >= 0;             # Existing EV energy at the start [kWh]
param E_ev_min {n in N} >= 0;         # Minimum EV energy requirement [kWh]
param tau {h in H} >= 0;              # Time-of-use tariff [$ per kWh]

# =============================
# VARIABLES
# =============================
var p_ev {h in H, n in N} >= 0;       # EV charging power [kW]
var p_max {h in H, n in N} >= 0;      # Maximum allowable transformer limit per user per time

# Dual variables (Lagrange multipliers)
var lambda1 {n in N} >= 0;            # Multiplier for energy constraint
var lambda2 {h in H, n in N} >= 0;    # Multiplier for transformer constraint

# Auxiliary variable for total load
var p_total {h in H, n in N} = p_inf[h,n] + p_ev[h,n];

# =============================
# OBJECTIVE
# =============================
maximize Objective {h in H, n in N}: p_max[h,n];

# =============================
# CONSTRAINTS
# =============================

# Upper-Level Transformer Capacity Constraint
subject to TransformerCapacity {h in H}:
    sum {n in N} p_max[h,n] <= Pmax_total;

# --- LOWER LEVEL REFORMULATED WITH KKT CONDITIONS ---

# 1. Stationarity
subject to Stationarity {h in H, n in N}:
    tau[h] - lambda1[n] + lambda2[h,n] = 0;

# 2. Primal Feasibility
subject to EV_Energy_Min {n in N}:
    E_ev_min[n] - e_ev[n] - sum {h in H} p_ev[h,n] <= 0;

subject to Max_Load_Limit {h in H, n in N}:
    p_inf[h,n] + p_ev[h,n] - p_max[h,n] <= 0;

# 3. Dual Feasibility
# Already enforced by `>= 0` in variable declaration

# 4. Complementary Slackness
subject to CompSlack_Energy {n in N}:
    lambda1[n] * (E_ev_min[n] - e_ev[n] - sum {h in H} p_ev[h,n]) = 0;

subject to CompSlack_Transformer {h in H, n in N}:
    lambda2[h,n] * (p_inf[h,n] + p_ev[h,n] - p_max[h,n]) = 0;