<script type="text/javascript"
  async src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js">
</script>

# Nomenclature

| Symbol           | Description                                                  |
|------------------|--------------------------------------------------------------|
| `H`              | Set of time slots (`h`)                                      |
| `N`              | Set of prosumers (`n`)                                       |
| `	au_h`         | Time-of-use tariff at time slot `h`                          |
| `p^{inf}_{h,n}`  | Load demand of prosumer `n` at time slot `h`                 |
| `p^{ev}_{h,n}`   | EV (flexible) demand of prosumer `n` at time slot `h`        |
| `e^{ev}_n`       | EV battery state of charge of prosumer `n`                   |
| `E^{ev}_{min}`   | EV minimum state of charge                                   |
| `P^{max}`        | Transformer thermal limit                                    |
| `p^{max}_{h,n}`  | Power limit for prosumer `n` at time slot `h`                |

# Lower Level Optimization Problem

Minimize:

```math
\min_{p^{ev}_h} \quad \sum_{h\in H} \tau_h(p^{inf}_{h} + p^{ev}_{h})
```

Subject to:

```math
E^{ev}_{min} - e^{ev} - \sum_{h \in H} p^{ev}_h \leq 0
```

```math
p^{inf}_h + p^{ev}_h - p^{max}_h \leq 0 \quad \forall h \in H
```

# KKT Conditions

## Lagrangian Function

```math
\mathcal{L}(p^{ev}_h, \lambda^1, \lambda^2_h) =
\sum_{h \in H} \tau_h(p^{inf}_h + p^{ev}_h)
+ \lambda^1 \left( E^{ev}_{min} - e^{ev} - \sum_{h \in H} p^{ev}_h \right)
+ \sum_{h \in H} \lambda^2_h \left( p^{inf}_h + p^{ev}_h - p^{max}_h \right)
```

### 1. Stationarity

```math
\frac{\partial \mathcal{L}}{\partial p^{ev}_h} = \tau_h - \lambda^1 + \lambda^2_h = 0 \quad \forall h \in H
```

### 2. Primal Feasibility

```math
E^{ev}_{min} - e^{ev} - \sum_{h \in H} p^{ev}_h \leq 0
```

```math
p^{inf}_h + p^{ev}_h - p^{max}_h \leq 0 \quad \forall h \in H
```

### 3. Dual Feasibility

```math
\lambda^1 \geq 0
```

```math
\lambda^2_h \geq 0 \quad \forall h \in H
```

### 4. Complementary Slackness

```math
\lambda^1 \left( E^{ev}_{min} - e^{ev} - \sum_{h \in H} p^{ev}_h \right) = 0
```

```math
\lambda^2_h \left( p^{inf}_h + p^{ev}_h - p^{max}_h \right) = 0 \quad \forall h \in H
```
