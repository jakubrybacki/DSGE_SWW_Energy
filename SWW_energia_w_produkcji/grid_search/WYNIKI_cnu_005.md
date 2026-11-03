# Grid search przy cnu = 0,05

Zachowano ostatnia siatke run_004: 2187 kombinacji przy cnu=0,05. Pozostale parametry spoza siedmiu osi, w tym dziewiec odchylen szokow, sa stale na referencji z estymacji przy cnu=0,05.

| Etap | Punkty | Poprawna wiarygodnosc | Najlepszy log likelihood |
|---|---:|---:|---:|
| run_004 | 2187 | 1944 | -776.214369 |

Referencja: log likelihood = -805.216600. Poprawa najlepszego punktu = 29.002231.

| Parametr | Najlepsza wartosc | Granica siatki run_004 |
|---|---:|---|
| cnu | 0.05000000 | staly |
| comegaE | 0.08000000 | nie |
| crhoE | 0.96975604 | nie |
| crpi | 1.10000000 | gorna |
| crhointr | 0.95000000 | nie |
| cthetap | 0.84280200 | nie |
| cthetaw | 0.65000000 | dolna |
| ch | 0.55000000 | dolna |

Odrzucenia w run_004: {('solution_rejected', '4'): 243}. Nie wystapily wyjatki wykonania.

To grid warunkowy, nie ponowna estymacja wszystkich parametrow w kazdym punkcie. Dodatni cnu daje dobre dopasowanie po zmianie kalibracji rdzenia, ale nie mozna przypisac poprawy samemu cnu ani uznac przewagi cnu=0,05 nad cnu=0 bez analogicznego przeszukania dla zera. Diagnostyka Hesjanu punktu gridu jest w runs/run_004/hessian; nie dotyczy pozniejszej estymacji. Najlepszy punkt lezy na granicy niektorych zakresow; nie jest potwierdzonym globalnym optimum.

Konfiguracja: config.json. Ranking, statusy, wykres i wejscia ostatniego przebiegu sa w runs/run_004. Oryginalne wyniki siatki pozostaly bez zmian.
