# SWW — model klasyczny

Główny model: `sww_klasyczny.mod` (dawniej EA_SWW14_rep.mod).
To replikacja Smetsa–Warne'a–Woutersa; brak odrębnego szoku energii.
Równania i kalibracja zostały zachowane.

W MATLAB dodaj zainstalowany Dynare do ścieżki i uruchom `step_1_run_model.m`.
`step_2_plot_irf.m` uruchamia model i rysuje wykresy replikacji. Oś czasu jest dopasowana
do długości IRF (dawny skrypt miał 21 punktów przy 40-elementowym wyniku modelu).

`materialy_zrodlowe` zawiera oryginalną implementację Modelbase EA_SWW14.mod,
parametry, opis replikacji i publikacje. Implementacja Modelbase wymaga
zewnętrznego policy_param.mat i środowiska Modelbase; nie jest trzecim modelem
energetycznym ani domyślnym plikiem uruchomieniowym.

`wyniki_historyczne` zawiera wcześniejsze wyniki i wygenerowany kod pod oryginalnymi
nazwami. Nowe uruchomienia zapisują wyniki jako sww_klasyczny.
Wspólne skrypty pobierania danych: `../data`.

## Źródło kalibracji po modularizacji

Edytuj `../Calibrations.xlsx`, następnie z katalogu głównego uruchom
`./calibration/generate_mod_inputs.ps1 -Country EA20`.
Model dołącza dokładnie trzy pliki `Estimation_Setup/EA20_*.mod`.
Wartości niezależne są w arkuszu, a tożsamości w ../calibration/derived_parameters.py; wygenerowanych modułów nie edytuje się ręcznie.
Metadane LaTeX i etykiety równań są w głównym `.mod`.
Pełna instrukcja: `../calibration/README.md`.

