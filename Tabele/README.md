# Folder Tabele: Tabele empiryczne i wykresy do artykułu

Główny folder zawiera skrypt orkiestrujący oraz trzy dedykowane podfoldery z kodami i wynikami:

## Uruchomienie całości

Z tego katalogu w PowerShell:
```powershell
.\run_all_tables.ps1
```

Skrypt automatycznie wywołuje skrypty `run.ps1` w każdym podfolderze za pośrednictwem środowiska `uv`.

---

## Struktura podfolderów

### 1. `wykres_1_dekompozycja_energii/`
- **Zakres**: Wpływ udziału energii w funkcji produkcji ($\nu \in [0.00, 0.10]$) na dekompozycję inflacji w latach 2022 i 2023.
- **Skrypty**:
  - `run.ps1` – lokalny runner
  - `generuj_tabele_i_wykres.py` – tabela porównawcza i wykres wieloliniowy
  - `generuj_wykres_slupkowy.py` – skumulowany wykres słupkowy marż i energii
  - `oblicz_dekompozycje_cnu.m` – obliczenia siatki w MATLAB/Dynare
  - `dekompozycja_cnu.csv` – dane wejściowe dla siatki parametrów $\nu$

### 2. `wykres_2_IRF_szoku_energetycznego/`
- **Zakres**: Dekompozycja addytywna impulsów reakcji (IRF) po szoku cen energii i żywności.
- **Skrypty i pliki**:
  - `run.ps1` – lokalny runner
  - `generate_chart_2.py` – dynamiczne wczytywanie wyników Dynare (`.mat`) i generowanie 2- i 3-panelowych wykresów
  - `figure_2_irf_energy_shock.tex` – szablon środowiska LaTeX TikZ

### 3. `wykres_3_dekompozycja_historyczna_inflacja/`
- **Zakres**: 3-panelowe porównanie kwartalnej dekompozycji historycznej inflacji (2020Q1–2026Q2) dla trzech modeli DSGE (klasyczny, z energią, z energią i żywnością).
- **Skrypty i pliki**:
  - `run.ps1` – lokalny runner
  - `generate_chart_3.py` – generowanie wykresów słupkowych i tabel zbiorczych
