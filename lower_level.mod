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

# Auxiliary variable for total load
var p_total {h in H} = p_inf[h] + p_ev[h];

# =============================
# OBJECTIVE
# =============================

minimize Objective: sum{h in H} tau[h]*(p_ev[h] + p_inf[h]);

# =============================
# CONSTRAINTS
# =============================

subject to EV_Energy_Min:
    E_ev_min - e_ev - sum{h in H}p_ev[h] <= 0;

subject to Max_Load_Limit {h in H}:
    p_inf[h] + p_ev[h] - Pmax_total <= 0;
