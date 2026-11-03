---
name: dsge-model-specification
description: >-
  Standard i wytyczne tworzenia oraz formatowania plików modeli DSGE w środowisku Dynare (.mod).
  Stosuj ten skill zawsze, gdy:
  - Tworzysz, edytujesz, refaktoryzujesz lub walidujesz pliki modeli DSGE / Dynare (.mod).
  - Deklarujesz zmienne (var, varobs, varexo) i parametry w Dynare, dbając o symbole LaTeX (${...}$) oraz opisy słowne (long_name = '...') zapewniające czysty eksport do LaTeX/PDF.
  - Używasz komend write_latex_original_model, write_latex_static_model, write_latex_dynamic_model lub kompilujesz wygenerowaną dokumentację do PDF.
  - Synchronizujesz kalibrację z pliku Excel (Calibrations.xlsx) do formatu Dynare za pomocą Pythona i dołączasz ją dyrektywą #include (@#include).
  - Zarządzasz modułami zewnętrznymi (@#include): wymóg dokładnie jednego pliku kalibracji, jednego pliku równań pomiaru (measurement equations) oraz jednego pliku szoków.
---

# Standard Tworzenia Modeli DSGE w Dynare (.mod)

Niniejszy skill definiuje oficjalne wymagania projektowe dla plików modeli DSGE (`.mod`) uruchamianych w środowisku Dynare, ze szczególnym uwzględnieniem pełnego opisu zmiennych dla raportów LaTeX/PDF oraz zautomatyzowanego zarządzania parametrami z arkusza Excel.

---

## 1. Wymóg 1: Deklaracje zmiennych pod kątem raportów LaTeX / PDF

Każda zmienna endogeniczna (`var`), egzogeniczna / szokowa (`varexo`) oraz obserwowalna (`varobs`) **musi** być w pełni udokumentowana. Zaleca się stosowanie tej samej zasady do bloku parametrów (`parameters`).

### 1.1. Składnia trójelementowa w Dynare

W Dynare po nazwie zmiennej umieszcza się kolejno:
1. **Symbol LaTeX** w nawiasach `${...}$` (math mode).
2. **Czytelną nazwę słowną / opis** jako metadaną `(long_name = '...')`.

```dynare
var
    n            ${n}$                    (long_name = 'Hours worked')
    c            ${c}$                    (long_name = 'Aggregate consumption')
    c_o          ${c^o}$                  (long_name = 'Ricardian optimizing households consumption')
    c_r          ${c^r}$                  (long_name = 'Rule-of-thumb households consumption')
    pi           ${\pi}$                  (long_name = 'CPI inflation rate')
    k            ${k}$                    (long_name = 'Installed capital stock')
    w            ${w}$                    (long_name = 'Real wage rate')
    r            ${r}$                    (long_name = 'Nominal interest rate')
    y            ${y}$                    (long_name = 'Gross domestic product')
;

varexo
    e_a          ${\varepsilon_a}$        (long_name = 'TFP technology shock')
    e_r          ${\varepsilon_r}$        (long_name = 'Monetary policy shock')
    e_c          ${\varepsilon_c}$        (long_name = 'Preference consumption shock')
    e_pi         ${\varepsilon_{\pi}}$    (long_name = 'Cost-push price markup shock')
;

varobs
    dy_obs       ${\Delta y^{obs}}$       (long_name = 'Observed quarterly GDP growth')
    pi_obs       ${\pi^{obs}}$            (long_name = 'Observed quarterly CPI inflation')
    r_obs        ${r^{obs}}$              (long_name = 'Observed short-term policy interest rate')
    dc_obs       ${\Delta c^{obs}}$       (long_name = 'Observed consumption growth')
;
```

> [!NOTE]
> Jeżeli zmienne obserwowalne (`varobs`) zostały już zadeklarowane w bloku `var` (co jest częstą praktyką w modelach szacowanych w Dynare), ich definicja `${...}$` i `long_name` w bloku `var` zostanie automatycznie wykorzystana w raportach.

### 1.2. Komendy generujące LaTeX i PDF

W głównym pliku `.mod` (zazwyczaj po bloku `model;` lub po definicji szoków / symulacji) należy umieścić następujące komendy:

```dynare
write_latex_original_model;
write_latex_static_model;
write_latex_dynamic_model;
```

Opcjonalne, przydatne komendy uzupełniające:
```dynare
write_latex_parameter_table;
write_latex_definitions;
```

### 1.3. Wymagania techniczne gwarantujące poprawny i estetyczny PDF

1. **Poprawność składni matematycznej LaTeX**:
   - Wszystkie symbole w `${...}$` muszą tworzyć poprawną składnię LaTeX w trybie matematycznym.
   - Używaj nawiasów klamrowych dla indeksów dolnych i górnych: `${c_{t}}$`, `${e_{a,t}}$`, `${r^{\ast}}$`.
   - Stosuj standardowe komendy LaTeX: `${\pi}$`, `${\alpha}$`, `${\beta}$`, `${\Delta y}$`, `${\varepsilon_a}$`.
2. **Bezpieczne opisy w `long_name`**:
   - W wartości `long_name = '...'` **nie** używaj niesformatowanych znaków specjalnych LaTeX (takich jak surowy `%`, `&`, `_`, `#`, `$`), ponieważ Dynare wstawia je do tabel w plikach `.tex` bez ich automatycznego escapowania.
3. **Etykietowanie równań w bloku `model` (`[name = '...']`)**:
   - Każde równanie w bloku `model;` powinno posiadać etykietę `[name = 'Nazwa równania']`. Dynare drukuje te etykiety bezpośrednio przy równaniach w wygenerowanym dokumencie LaTeX:
   ```dynare
   model(linear);
       [name = 'Capital accumulation']
       k = (1-delta)*k(-1) + delta*i;

       [name = 'New Keynesian Phillips Curve']
       pi_h = gamma_f*pi_h(+1) + gamma_b*pi_h(-1) + kappa*mc;
   end;
   ```
4. **Kompilacja do PDF**:
   - Po uruchomieniu Dynare w katalogu roboczym powstaną pliki:
     `<NAZWA_MODELU>_original.tex`
     `<NAZWA_MODELU>_static.tex`
     `<NAZWA_MODELU>_dynamic.tex`
   - Kompilację wykonuje się poleceniem:
     ```bash
     pdflatex NAZWA_MODELU_original.tex
     pdflatex NAZWA_MODELU_dynamic.tex
     ```

---

## 2. Wymóg 2: Pipeline kalibracji z `Calibrations.xlsx` przez Python i `#include`

Zgodnie z zasadą *Single Source of Truth*, żadne wartości parametrów skalibrowanych nie mogą być wpisywane ręcznie "na sztywno" w głównym pliku `.mod`.

### 2.1. Standard pliku `Calibrations.xlsx`

Plik `Calibrations.xlsx` przechowuje definicje i wartości liczbowe parametrów. Standardowa struktura tabeli:

| Variable | Description | PL | CZ | HU | SK | RO |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `alpha` | Production function - Capital elasticity | 0.360 | 0.350 | 0.350 | 0.380 | 0.340 |
| `beta` | Discount factor | 0.990 | 0.992 | 0.990 | 0.991 | 0.985 |
| `delta` | Depreciation rate of capital | 0.025 | 0.025 | 0.025 | 0.025 | 0.030 |
| `gamma_g` | Share of government spending in GDP | 0.213 | 0.205 | 0.210 | 0.214 | 0.183 |
| `theta` | Calvo price stickiness parameter | 0.750 | 0.750 | 0.750 | 0.750 | 0.680 |
| `lambda` | Share of rule-of-thumb households | 0.350 | 0.350 | 0.350 | 0.350 | 0.500 |

### 2.2. Rola skryptu Python (`generate_mod_inputs.py`)

Skrypt w Pythonie odpowiada za wczytanie pliku `Calibrations.xlsx` i wygenerowanie pliku tekstowego `.mod` (lub `.inc`).

Format każdej wygenerowanej linii w pliku `.mod`:
```matlab
<nazwa_parametru> = <wartość_liczbowa>; % <opis_z_kolumny_Description>
```

#### Przykładowa funkcja generatora w Pythonie:
```python
import pandas as pd
from pathlib import Path

def export_calibrations_to_mod(
    excel_path: str = "Calibrations.xlsx",
    output_dir: str = "Estimation_Setup",
    country_col: str = "PL",
    output_filename: str = None
):
    df = pd.read_excel(excel_path)
    
    if output_filename is None:
        output_filename = f"{country_col}_calibration.mod"
        
    out_path = Path(output_dir) / output_filename
    out_path.parent.mkdir(parents=True, exist_ok=True)
    
    lines = [
        f"// Calibrated parameters automatically generated from {excel_path}",
        f"// Specification / Country: {country_col}",
        ""
    ]
    
    for _, row in df.iterrows():
        var_name = str(row["Variable"]).strip()
        if not var_name or var_name.startswith(("//", "#")):
            continue
            
        val = row[country_col]
        desc = str(row.get("Description", "")).strip()
        
        if pd.isna(val):
            raise ValueError(f"Brakująca wartość kalibracji dla parametru '{var_name}' w kolumnie '{country_col}'.")
            
        lines.append(f"{var_name} = {float(val):.6g}; % {desc}")
        
    with open(out_path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")
        
    print(f"Pomyślnie wygenerowano kalibrację: {out_path}")
```

### 2.3. Dołączenie kalibracji w głównym pliku `.mod` (`#include` / `@#include`)

W środowisku Dynare makroprocesor dołącza pliki zewnętrzne za pomocą dyrektywy `@#include` (często określanej w specyfikacji jako `#include`).

#### Wariant A: Bezpośrednie dołączenie pliku kalibracji
```dynare
parameters alpha beta delta gamma_g theta lambda phi_pi phi_y;

// Dołączenie wygenerowanego pliku kalibracji
@#include "Estimation_Setup/PL_calibration.mod"

// Obliczenia parametrów zależnych / stanów ustalonych po załadowaniu kalibracji bazowej
rho = 1/beta - 1;
gamma_i = delta*alpha / ((rho + delta));
gamma_c = 1 - gamma_g - gamma_i;
```

#### Wariant B: Dynamiczne dołączenie na podstawie zmiennej makroprocesora
```dynare
@#ifndef COUNTRY
    @#define COUNTRY = "PL"
@#endif

@#define CALIBRATION_FILE = "Estimation_Setup/" + COUNTRY + "_calibration.mod"

parameters alpha beta delta gamma_g theta lambda phi_pi phi_y;

// Dołączenie zależne od wybranego kraju
@#include CALIBRATION_FILE
```

> [!IMPORTANT]
> Plik z kalibracjami musi być dołączony **po** zadeklarowaniu nazw parametrów w bloku `parameters ...;`, ale **przed** blokiem `model;` oraz przed równaniami wyliczającymi parametry pochodne stanu ustalonego.

---

## 3. Wymóg 3: Zasada jednego pliku per domena (Single-File per Domain)

W architekturze modelu DSGE obowiązuje ścisła zasada unikania wielokrotnych, rozproszonych plików pomocniczych tego samego typu. Dla każdego kraju/specyfikacji w modelu mogą występować **dokładnie trzy zewnętrzne moduły** dołączane dyrektywą `@#include`:

```
Estimation_Setup/
├── {KRAJ}_calibration.mod    # DOKŁADNIE JEDEN plik kalibracji (wszystkie parametry)
├── {KRAJ}_measurement.mod    # DOKŁADNIE JEDEN plik równań pomiaru (zarówno dla symulacji, jak i estymacji)
└── {KRAJ}_shocks.mod         # DOKŁADNIE JEDEN plik definiujący blok szoków dla danego kraju
```

### 3.1. Tylko jeden plik z kalibracjami (`CALIBRATION_FILE`)
- Wszystkie parametry modelu (zarówno parametry rdzenia modelu, jak i rozszerzeń otwartej gospodarki / sektorowych) muszą znajdować się w **jednym** pliku: `{kraj}_calibration.mod`.
- **Zakaz rozbijania**: Niedopuszczalne jest dzielenie kalibracji na plik bazowy i rozszerzający (np. `{kraj}_calibration.mod` oraz `{kraj}_soe_calibration.mod`).
- Wszystkie wartości pochodzą w 100% z pliku `Calibrations.xlsx`.
- W głównym pliku `.mod`:
  ```dynare
  @#define CALIBRATION_FILE = "Estimation_Setup/" + COUNTRY + "_calibration.mod"
  @#include CALIBRATION_FILE
  ```

### 3.2. Tylko jeden plik z równaniami pomiaru (`MEASUREMENT_EQ_FILE`)
- Wszystkie równania pomiaru łączące zmienne modelowe ze zmiennymi obserwowalnymi (wraz ze średnimi ze zbioru danych) muszą znajdować się w **jednym** pliku: `{kraj}_measurement.mod`.
- **Zakaz rozgałęzień estymacja/symulacja**: Niedopuszczalne jest tworzenie odrębnych plików pomiarowych dla estymacji i symulacji (np. zakaz `@#if RUN_ESTIMATION` ładującego inny plik niż w trybie symulacji). Ten sam plik pomiaru obowiązuje w całym cyklu pracy modelu.
- Potok danych (np. `prepare_soe_data.m`) wylicza średnie i zapisuje je bezpośrednio do `{kraj}_measurement.mod`.
- W bloku `model;`:
  ```dynare
  @#define MEASUREMENT_EQ_FILE = "Estimation_Setup/" + COUNTRY + "_measurement.mod"
  ...
  model(linear);
      ...
      @#include MEASUREMENT_EQ_FILE
  end;
  ```

### 3.3. Tylko jeden plik z szokami (`SHOCKS_FILE`)
- Odchylenia standardowe (i ewentualne korelacje) wszystkich szoków egzogenicznych muszą być zdefiniowane w **jednym** pliku z przedrostkiem kraju: `{kraj}_shocks.mod`.
- **Zakaz duplikowania**: Wszelkie skale innowacji szokowych znajdują się w tym jednym dedykowanym pliku dla danego kraju.
- W głównym pliku `.mod`:
  ```dynare
  @#define SHOCKS_FILE = "Estimation_Setup/" + COUNTRY + "_shocks.mod"
  ...
  @#include SHOCKS_FILE
  ```

---

## 4. Kompletny szablon referencyjny pliku `.mod`

Poniższy szablon przedstawia prawidłową strukturę pliku DSGE zgodną z obydwoma założeniami:

```dynare
// =========================================================================
// Wzorcowy model DSGE zgodny ze standardem dsge-model-specification
// =========================================================================

// 1. Deklaracja zmiennych endogenicznych (z symbolami LaTeX i long_name)
var
    c            ${c}$                    (long_name = 'Consumption')
    n            ${n}$                    (long_name = 'Hours worked')
    y            ${y}$                    (long_name = 'Output')
    w            ${w}$                    (long_name = 'Real wage')
    r            ${r}$                    (long_name = 'Nominal interest rate')
    pi           ${\pi}$                  (long_name = 'Inflation rate')
    k            ${k}$                    (long_name = 'Capital stock')
    i            ${i}$                    (long_name = 'Investment')
    epsilon_a    ${\varepsilon_a}$        (long_name = 'TFP shock process')
;

// 2. Deklaracja zmiennych obserwowalnych
varobs
    dy_obs       ${\Delta y^{obs}}$       (long_name = 'Output growth observed')
    dc_obs       ${\Delta c^{obs}}$       (long_name = 'Consumption growth observed')
    pi_obs       ${\pi^{obs}}$            (long_name = 'Inflation observed')
    r_obs        ${r^{obs}}$              (long_name = 'Policy rate observed')
;

// 3. Deklaracja szoków egzogenicznych
varexo
    e_a          ${e_a}$                  (long_name = 'TFP innovation shock')
    e_r          ${e_r}$                  (long_name = 'Monetary policy shock')
;

// 4. Deklaracja parametrów
parameters
    alpha        ${\alpha}$               (long_name = 'Capital share in production')
    beta         ${\beta}$                (long_name = 'Household discount factor')
    delta        ${\delta}$               (long_name = 'Capital depreciation rate')
    phi_pi       ${\phi_{\pi}}$           (long_name = 'Taylor rule inflation feedback')
    phi_y        ${\phi_{y}}$             (long_name = 'Taylor rule output gap feedback')
    rho_r        ${\rho_r}$               (long_name = 'Taylor rule smoothing')
    rho_a        ${\rho_a}$               (long_name = 'AR(1) persistence of TFP')
    rho          ${\rho}$                 (long_name = 'Steady state discount rate')
;

// 5. Dołączenie DOKŁADNIE JEDNEGO pliku kalibracji ze wszystkimi parametrami
@#define CALIBRATION_FILE = "Estimation_Setup/PL_calibration.mod"
@#include CALIBRATION_FILE

// 6. Wyliczanie parametrów zależnych
rho = 1/beta - 1;

// 7. Blok modelu z nazwanymi równaniami oraz DOKŁADNIE JEDNYM plikiem pomiarów
@#define MEASUREMENT_EQ_FILE = "Estimation_Setup/PL_measurement.mod"
@#define SHOCKS_FILE = "Estimation_Setup/PL_shocks.mod"

model(linear);
    [name = 'Production function']
    y = (1-alpha)*n + alpha*k(-1) + epsilon_a;

    [name = 'Labor supply']
    w = c + n;

    [name = 'Euler consumption equation']
    c = c(+1) - (r - pi(+1));

    [name = 'Taylor monetary policy rule']
    r = rho_r*r(-1) + (1-rho_r)*(phi_pi*pi + phi_y*y) + e_r;

    [name = 'Technology shock AR(1) process']
    epsilon_a = rho_a*epsilon_a(-1) + e_a;

    // Dołączenie jedynego pliku równań pomiaru
    @#include MEASUREMENT_EQ_FILE
end;

// 8. Dołączenie DOKŁADNIE JEDNEGO pliku szoków dla danego kraju
@#include SHOCKS_FILE

// 9. Komendy generujące dokumentację LaTeX do kompilacji do PDF
write_latex_original_model;
write_latex_static_model;
write_latex_dynamic_model;

// 10. Rozwiązanie i symulacja
steady;
check;
stoch_simul(order=1, irf=40);
```

---

## 5. Procedura weryfikacji i Checklist

Przy tworzeniu lub modyfikacji pliku modelu wykonaj poniższe kroki kontrolne:

1. [ ] **Czy `Calibrations.xlsx` jest zaktualizowany?** Wszystkie parametry kalibracji (zarówno podstawowe, jak i rozszerzeń) znajdują się w tym jednym arkuszu.
2. [ ] **Czy jest DOKŁADNIE JEDEN plik kalibracji?** Wygenerowano jeden plik `Estimation_Setup/<COUNTRY>_calibration.mod` (brak plików `_soe_calibration.mod`).
3. [ ] **Czy jest DOKŁADNIE JEDEN plik pomiarów?** Występuje jeden plik `Estimation_Setup/<COUNTRY>_measurement.mod` wspólny dla symulacji i estymacji (brak rozgałęzień `@#if RUN_ESTIMATION` dla plików pomiaru).
4. [ ] **Czy jest DOKŁADNIE JEDEN plik szoków?** Blok `shocks;` dołączany jest z jednego pliku z przedrostkiem kraju: `Estimation_Setup/<COUNTRY>_shocks.mod`.
5. [ ] **Czy każda zmienna posiada `${...}$` i `long_name`?** Brak gołych nazw zmiennych w blokach `var`, `varexo`, `varobs`.
6. [ ] **Czy dodano polecenia `write_latex_*`?** Umieszczono polecenia `write_latex_original_model;`, `write_latex_static_model;`, `write_latex_dynamic_model;`.
7. [ ] **Czy pliki `.tex` kompilują się bez błędów?** Uruchomienie `pdflatex <model>_original.tex` tworzy elegancki plik PDF bez błędów niesformatowanych znaków specjalnych.
