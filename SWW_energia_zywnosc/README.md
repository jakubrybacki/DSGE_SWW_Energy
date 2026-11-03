# SWW: energia w produkcji i globalne ceny żywności

Działający prototyp do symulacji, utworzony 2026-09-26. Model ma 77 zmiennych i równań przed transformacjami Dynare oraz 10 niezależnych innowacji. Dynare dodaje 6 zmiennych pomocniczych.

## Kalibracja

Bazą jest ostatni wariant `diagnostyka/runs/ceny_roczne_phi15/model_roczne`, z wartościami z `fitted_calibration.json`. Sztywność cen `cthetap=0.75` oznacza przeciętny czas między zmianami cen równy 4 kwartałom; reakcja reguły polityki na inflację `crpi=1.5`. Pozostałe parametry odziedziczono z tego wariantu. Nie przeprowadzono ponownej estymacji rozszerzonego modelu.

Nowe założenia robocze:

| Parametr | Wartość | Znaczenie |
|---|---:|---|
| comegaF | 0.05 | Udział importowanej żywności w wydatkach konsumpcyjnych |
| crhoF | 0.8 | Kwartalna trwałość względnej ceny żywności |
| csigmaF | 5 | Odchylenie innowacji w jednostkach 100 × log |

Udział 5% nie jest udziałem całej żywności w HICP. Wszystkie trzy parametry żywności są ilustracyjne. Wielkości ilościowe i ceny względne są w log-procentach; inflacja i stopy kwartalne w punktach procentowych. Wykres stopy pokazuje `4*r`.

## Nowe równania

W zapisie pliku Dynare:

```text
pF = crhoF*pF(-1) + etaF;
pc = comegaE*pE + comegaF*pF;
cfood = c + pc - pF;
cfoodf = cf + pc - pF;
piF = pi + pF - pF(-1);
piC = pi + pc - pc(-1);
exports = cweightXE*(pE+etot) + cweightXF*(pF+cfood);
exportsf = cweightXE*(pE+etotf) + cweightXF*(pF+cfoodf);
pFobs = pF;
piFobs = cpibar + piF;
```

Koszyk konsumpcji ma jednostkową elastyczność substytucji. `pF` oznacza cenę importowanej żywności względem krajowych dóbr, w walucie krajowej. Innowacja `etaF` jest egzogenicznym szokiem ceny; model nie rozróżnia globalnego szoku podaży żywności od globalnego szoku popytu. Nie ma osobnego sektora rolnego, kursu walutowego ani opóźnionego przenoszenia cen na ceny detaliczne.

Rozszerzono zarówno gospodarkę ze sztywnościami, jak i gospodarkę przy elastycznych cenach. Import finansuje bieżący eksport, zgodnie z domknięciem modelu energetycznego. Wagi eksportu są udziałami wartości importu energii i żywności w całkowitym imporcie w stanie ustalonym. Wagi wewnątrz agregatu energii nadal sumują się względem samego importu energii.

```text
cshareN = (1-comegaE-comegaF)*ccy;
cshareCF = comegaF*ccy;
cshareME = cshareEn+cshareCe;
cshareX = cshareME+cshareCF;
cweightXE = cshareME/cshareX;
cweightXF = cshareCF/cshareX;
```

Generator obsługuje też przypadek zerowego mianownika. Tożsamość udziałów to `cshareN+ciy+cgy+cshareX=1`. Import żywności konsumpcyjnej nie jest ponownie odejmowany od krajowej wartości dodanej. W definicji PKB odliczany pozostaje importowany wkład energetyczny produkcji.

## Pliki i uruchomienie

- `sww_energia_zywnosc.mod`: główny model i symulacja wszystkich 10 szoków przez 200 kwartałów.
- `Calibrations.xlsx`: 50 niezależnych parametrów; edytuj kolumnę EA20 arkusza Parameters.
- `calibration/derived_parameters.py`: tożsamości parametrów pochodnych.
- `calibration/generate_mod_inputs.py`: odczyt arkusza i walidacja; wymaga Python >=3.10 oraz openpyxl.
- `Estimation_Setup/EA20_calibration.mod`, `EA20_measurement.mod`, `EA20_shocks.mod`: dokładnie trzy moduły dołączane przez model.
- `sww_energia_zywnosc_steadystate.m`: generowana funkcja stanu ustalonego, przeliczająca parametry pochodne.
- `step_1_run_model.m`: uruchomienie modelu w Dynare.
- `step_2_validate_model.m`: porównania, zapis wykresów oraz wyników kontroli (dawniej step_2_validate_model.m).
- `run_steps.ps1`: automatyczny skrypt PowerShell uruchamiający krok 1 i 2.
- `results/food_irf.csv`: odpowiedzi na żywność, kwartały 0–199; PNG/PDF pokazują pierwsze 40.
- `sww_energia_zywnosc/Output/sww_energia_zywnosc_results.mat`: pełne wyniki Dynare, w tym IRF wszystkich szoków.
- `sww_energia_zywnosc/latex/`: skompilowane `original.pdf`, `static.pdf`, `dynamic.pdf` z równaniami.

Z katalogu tego modelu:

```powershell
python calibration/generate_mod_inputs.py --country EA20
```

Następnie w MATLAB, również z katalogu modelu:

```matlab
addpath('C:/dynare/7.1/matlab');
step_1_run_model;
step_2_validate_model;
```

Sama symulacja jest niezależna od starszych folderów. Test porównawczy w `step_2_validate_model` potrzebuje zachowanego sąsiedniego katalogu `diagnostyka/runs/ceny_roczne_phi15/model_roczne`. Kopie do porównań zapisuje w `validation/`.

## Wyniki kontroli

Dynare 7.1 / MATLAB R2026a:

- Warunki Blancharda–Kahna i rzędu spełnione: 14 pierwiastków niestabilnych na 14 zmiennych wybiegających w przyszłość.
- `model_diagnostics`: brak oczywistych problemów.
- Po ustawieniu udziału żywności na zero: największa różnica wobec bazowego modelu energii `4.45e-13`, porównano 639 serii po 200 kwartałów.
- Wpływ szoku żywności na agregaty przy zerowym udziale żywności: maksymalnie `1.24e-15`.
- Błędy badanych tożsamości CPI, popytu i eksportu poniżej `2.26e-15`; suma udziałów w stanie ustalonym równa 1.
- Generator daje identyczne pliki przy ponownym uruchomieniu. Odrzuca ujemny udział żywności, udział naruszający dodatni udział dóbr krajowych, niestacjonarną trwałość i ujemne odchylenie szoku.
- Wszystkie trzy dokumenty LaTeX skompilowano do PDF.

Ostrzeżenie preprocesora o parametrach niewystępujących bezpośrednio w równaniach dotyczy parametrów używanych do wyznaczania współczynników pochodnych lub wariancji szoków.

## Pierwsza odpowiedź na szok żywności

Szok: +5 log-procent do ceny względnej, czyli około +5.13% poziomu ceny.

| Wielkość | Reakcja w kwartale szoku |
|---|---:|
| Kwartalna inflacja CPI | +0.25235 pkt proc. |
| Kwartalna inflacja krajowa | +0.00235 pkt proc. |
| Stopa nominalna, annualizowana | +0.05302 pkt proc. |
| Konsumpcja | -0.15391 log-procent |
| PKB | +0.06579 log-procent |
| Konsumpcja importowanej żywności | -4.90391 log-procent |

PKB ma początkowo dodatnią odpowiedź, po czym spada. Ta reakcja wymaga interpretacji przez domknięcie bilansu handlowego i przesunięcie popytu na dobra krajowe; nie narzucamy ujemnego znaku z góry. Po początkowym wzroście inflacja CPI spada poniżej ścieżki bazowej, ponieważ proces AR(1) oznacza powrót poziomu ceny względnej do stanu ustalonego. Symulacje i testy algebraiczne nie zastępują oceny empirycznej wszystkich IRF.

## Co jest potrzebne do estymacji

Nie dodano fikcyjnej serii cen żywności ani nie skopiowano starych danych jako kompletnego zbioru nowego modelu. `varobs` zawiera docelowo `pFobs`, ale plik nie wykonuje estymacji.

Należy przygotować kwartalną cenę żywności wyrażoną w walucie krajowej, spójny deflator krajowych dóbr oraz transformację 100 × log ich ilorazu z uzgodnionym centrowaniem. Szereg globalnych surowców rolnych i detaliczny indeks HICP żywności nie są automatycznie tą samą zmienną. Wybór wymaga dopasowania definicji do równań i ewentualnego dodania bloku przenoszenia cen.

Dopiero po przygotowaniu wspólnej próby i estymacji można porównać wiarygodność, AIC/BIC, reszty, identyfikację i hesjan. Dodatnia określoność hesjanu modelu energetycznego nie przenosi się na to rozszerzenie. Ta wersja jest prototypem do dalszej pracy nad rozdziałem książki.