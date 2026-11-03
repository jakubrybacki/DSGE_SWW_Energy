# Grid Search (`run_grid_search.m`)

Jeden skrypt (`run_grid_search.m`) i jedna konfiguracja (`config.json`) wykonujące warunkowy przegląd na 8-wymiarowej siatce parametrów (wraz z udziałem energii w produkcji `cnu`).

## Uruchomienie w MATLAB (z głównego katalogu projektu)

```matlab
addpath('C:/dynare/7.1/matlab');
addpath(fullfile(pwd, 'SWW_energia_w_produkcji', 'grid_search'));
run_grid_search;
```

## Osie siatki (`config.json`)

Siatka obejmuje 8 parametrów strukturalnych:
* `cnu` ($\nu$) — elastyczność produkcji względem energii (`[0.0, 0.03, 0.05, 0.08, 0.10]`),
* `comegaE` ($\omega_E$) — udział energii w koszyku konsumpcji (`[0.06, 0.08, 0.10]`),
* `crhoE` ($\rho_E$) — persystencja względnej ceny energii,
* `crpi` ($r_\pi$) — reakcja reguły Taylora na inflację,
* `crhointr` ($\rho_R$) — wygładzanie stóp procentowych,
* `cthetap` ($\theta_p$) — sztywność cen Calvo,
* `cthetaw` ($\theta_w$) — sztywność płac Calvo,
* `ch` ($h$) — zewnętrzny nawyk konsumpcyjny.

Dla każdego punktu skrypt przelicza stan ustalony i udziały pochodne (`sww_energia_w_produkcji_steadystate.m`), weryfikuje warunki determinacji Blancharda–Kahna (`resol`), wylicza wartość funkcji wiarygodności (`dsge_likelihood`), zapisuje tabelę `points.csv`, `ranking.csv`, `summary.json`, `results.mat` oraz wykres profili marginalnych dla wszystkich 8 osi (`grid_summary.png`).
