<script type="text/javascript"
  async src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js">
</script>

# Nomenclature

| Symbol           | Description                                                  |
|------------------|--------------------------------------------------------------|
| `H`              | Set of time slots (`h`)                                      |
| `N`              | Set of prosumers (`n`)                                       |
| `\tau_h`         | Time-of-use tariff at time slot `h`                          |
| `p^{inf}_{h,n}`  | Load demand of prosumer `n` at time slot `h`                 |
| `p^{ev}_{h,n}`   | EV (flexible) demand of prosumer `n` at time slot `h`        |
| `e^{ev}_n`       | EV battery state of charge of prosumer `n`                   |
| `E^{ev}_{min}`   | EV minimum state of charge                                   |
| `P^{max}`        | Transformer thermal limit                                    |
| `p^{max}_{h,n}`  | Power limit for prosumer `n` at time slot `h`                |

# Lower Level Optimization Problem

Minimize:

$$
\min_{p^{\text{ev}}_h} \sum_{h \in H} \tau_h (p^{\text{inf}}_h + p^{\text{ev}}_h)
$$

Subject to:

$$
E^{\text{ev}}_{\min} - e^{\text{ev}} - \sum_{h \in H} p^{\text{ev}}_h \leq 0
$$

$$
p^{\text{inf}}_h + p^{\text{ev}}_h - p^{\max}_h \leq 0 \quad \forall h \in H
$$

⸻

## KKT Conditions

Lagrangian:

$$
\mathcal{L}(p^{\text{ev}}_h, \lambda) =
\sum_{h \in H} \tau_h(p^{\text{inf}}_h + p^{\text{ev}}_h)
+ \lambda^1 \left( E^{\text{ev}}_{\min} - e^{\text{ev}} - \sum_{h \in H} p^{\text{ev}}_h \right)
+ \sum_{h \in H} \lambda^2_h \left( p^{\text{inf}}_h + p^{\text{ev}}_h - p^{\max}_h \right)
$$

Stationarity:

$$
\frac{\partial \mathcal{L}}{\partial p^{\text{ev}}_h} = \tau_h - \lambda^1 + \lambda^2_h = 0 \quad \forall h \in H
$$

Primal Feasibility:

$$
E^{\text{ev}}_{\min} - e^{\text{ev}} - \sum_{h \in H} p^{\text{ev}}_h \leq 0
$$

$$
p^{\text{inf}}_h + p^{\text{ev}}_h - p^{\max}_h \leq 0 \quad \forall h \in H
$$

Dual Feasibility:

$$
\lambda^1 \geq 0
$$

$$
\lambda^2_h \geq 0 \quad \forall h \in H
$$

Complementary Slackness:

$$
\lambda^1 \left( E^{\text{ev}}_{\min} - e^{\text{ev}} - \sum_{h \in H} p^{\text{ev}}_h \right) = 0
$$

$$
\lambda^2_h \left( p^{\text{inf}}_h + p^{\text{ev}}_h - p^{\max}_h \right) = 0 \quad \forall h \in H
$$

⸻

# Bi-level Reformulation with KKT

Maximize:

$$
\max_{p^{\max}_{h,n}} \quad \sum_{h \in H} \sum_{n \in N} p^{\max}_{h,n}
$$

Subject to:

$$
\sum_{n \in N} p^{\max}_{h,n} - P^{\max} \leq 0 \quad \forall h \in H
$$

Stationarity:

$$
\tau_h - \lambda^1_n + \lambda^2_{h,n} = 0 \quad \forall h \in H, \forall n \in N
$$

Primal Feasibility:

$$
E^{\text{ev}}_{\min} - e^{\text{ev}}_n - \sum_{h \in H} p^{\text{ev}}_{h,n} \leq 0 \quad \forall n \in N
$$

$$
p^{\text{inf}}_{h,n} + p^{\text{ev}}_{h,n} - p^{\max}_{h,n} \leq 0 \quad \forall h \in H, \forall n \in N
$$

Dual Feasibility:

$$
\lambda^1_n \geq 0 \quad \forall n \in N
$$

$$
\lambda^2_{h,n} \geq 0 \quad \forall h \in H, \forall n \in N
$$

Complementary Slackness:

$$
\lambda^1_n \left( E^{\text{ev}}_{\min} - e^{\text{ev}}_n - \sum_{h \in H} p^{\text{ev}}_{h,n} \right) = 0 \quad \forall n \in N
$$

$$
\lambda^2_{h,n} \left( p^{\text{inf}}_{h,n} + p^{\text{ev}}_{h,n} - p^{\max}_{h,n} \right) = 0 \quad \forall h \in H, \forall n \in N
$$