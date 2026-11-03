# Wykres 1: Porównanie Dekompozycji Szoków Inflacji w Roku 2022 w Trzech Modelach DSGE

Folder zawiera zestawienie porównawcze, zbiory danych oraz publikacyjne wykresy dekompozycji historycznej inflacji za **rok 2022** (suma 4 kwartałów: 2022Q1–2022Q4) dla trzech wariantów modelu DSGE klasy Smets–Warne–Wouters (2014):

1. **Model 1: Klasyczny SWW (`SWW_klasyczny`)** — bazowy model gospodarki zamkniętej bez wyróżnionego sektora surowcowego (Smets, Warne & Wouters 2014).
2. **Model 2: SWW z funkcją energii (`SWW_energia_w_produkcji`)** — rozszerzenie wprowadzające energię jako wsad w funkcji produkcji dóbr pośrednich ($\nu = 0.05$, $c_{\theta,p} = 0.75$).
3. **Model 3: SWW z funkcją energii i żywności (`SWW_energia_zywnosc`)** — pełna specyfikacja rozszerzona o sektorowe szoki cen energii ($\eta^E$) oraz importowanej żywności ($\eta^F$) w koszyku konsumpcyjnym i strukturze narzutów.

---

## 1. Kluczowe Wnioski Ekonomiczne

### A. Rozwiązanie zagadki pozornego wzrostu marż (*greedflation puzzle*)
- **Klasyczny model SWW** przypisuje dominującą część szoku inflacyjnego roku 2022 (**+7.59 pp** z łącznej inflacji 9.53 pp, czyli **79.6%**) szokom narzutów cenowych ($\eta^p$). Ponieważ model nie posiada kanałów surowcowych, algorytm filtru Kalmana błędnie interpretuje gwałtowny wzrost cen energii jako bezprecedensowy wzrost marż monopolistycznych przedsiębiorstw.
- **Wprowadzenie energii do funkcji produkcji pośredniej ($\nu=0.05, c_{\theta,p}=0.75$)** natychmiast absorbuje **+2.12 pp** w postaci bezpośredniego szoku cen energii ($\eta^E$), dzięki czemu wkład szoku marż cenowych ($\eta^p$) gwałtownie spada z 7.59 pp do **+4.13 pp** (spadek o niemal 46%).
- **Wprowadzenie energii i żywności** kompletnie przekształca strukturę inflacji:
  - Szok cen energii ($\eta^E$) odpowiada za **+6.73 pp**.
  - Szok cen żywności ($\eta^F$) odpowiada za **+4.98 pp**.
  - Szok ogólnych marż cenowych ($\eta^p$) spada do zaledwie **+2.45 pp** (ok. 25% inflacji), co jest w pełni spójne z szacunkami empirycznymi EBC i literaturą makroekonomiczną.

### B. Rola marż płacowych i polityki pieniężnej
- We wszystkich modelach obserwujemy ujemny, dezinflacyjny wkład marż płacowych ($\eta^w$), wynoszący od **-0.75 pp** (w modelu klasycznym), przez **-1.33 pp** (w modelu z energią), do **-2.99 pp** (w modelu z żywnością), co potwierdza spadek realnych wynagrodzeń w okresie kryzysu inflacyjnego.
- W modelu klasycznym polityka pieniężna odpowiada za +0.75 pp, natomiast w modelu z energią w produkcji jej zidentyfikowany wkład wynosi +2.54 pp.

---

## 2. Zbiorcza Tabela Porównawcza dla Roku 2022 (Suma 4 Kwartałów)

| Kategoria szoku / czynnika | Model 1: Klasyczny SWW | Model 2: SWW z funkcją energii ($\nu=0.05$) | Model 3: SWW z energią i żywnością |
|:---|:---:|:---:|:---:|
| **Szok marż cenowych ($\eta^p$)** | **+7.587 pp** *(79.6%)* | **+4.130 pp** *(43.3%)* | **+2.453 pp** *(25.7%)* |
| **Szok cen energii ($\eta^E$)** | *0.000 pp* *(brak)* | **+2.124 pp** *(22.3%)* | **+6.726 pp** *(70.5%)* |
| **Szok cen żywności ($\eta^F$)** | *0.000 pp* *(brak)* | *0.000 pp* *(brak)* | **+4.979 pp** *(52.2%)* |
| **Szok marż płacowych ($\eta^w$)** | **-0.748 pp** | **-1.327 pp** | **-2.992 pp** |
| **Szok polityki pieniężnej ($\eta^r$)** | **+0.747 pp** | **+2.540 pp** | *(w pozostałych)* |
| **Pozostałe szoki i stała / SS** | **+1.949 pp** | **+2.068 pp** | **-1.632 pp** |
| **Inflacja 2022 ogółem (suma modeli)** | **+9.535 pp** | **+9.535 pp** | **+9.535 pp** |

---

## 3. Szczegółowe Rozbicie Kwartalne dla Roku 2022 (Q1–Q4)

### Model 1: Klasyczny SWW
| Kwartał | Marże cenowe $\eta^p$ (pp) | Marże płacowe $\eta^w$ (pp) | Polityka $\eta^r$ (pp) | Pozostałe / SS (pp) | Inflacja łączna $\pi$ (pp) |
|:---:|:---:|:---:|:---:|:---:|:---:|
| **2022Q1** | +1.9405 | -0.1157 | +0.1673 | +0.5339 | +2.5259 |
| **2022Q2** | +2.0286 | -0.2147 | +0.1907 | +0.5031 | +2.5078 |
| **2022Q3** | +1.6665 | -0.2163 | +0.1955 | +0.4284 | +2.0741 |
| **2022Q4** | +1.9514 | -0.2015 | +0.1932 | +0.4837 | +2.4268 |
| **Suma 2022** | **+7.5871** | **-0.7482** | **+0.7468** | **+1.9490** | **+9.5346** |

### Model 2: SWW z funkcją energii w produkcji ($\nu=0.05, c_{\theta,p}=0.75$)
| Kwartał | Marże cenowe $\eta^p$ (pp) | Szok energii $\eta^E$ (pp) | Marże płacowe $\eta^w$ (pp) | Polityka $\eta^r$ (pp) | Pozostałe / SS (pp) | Inflacja łączna $\pi$ (pp) |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **2022Q1** | +0.7068 | +0.9223 | -0.2562 | +0.6201 | +0.5330 | +2.5259 |
| **2022Q2** | +1.0320 | +0.6196 | -0.3656 | +0.7585 | +0.4633 | +2.5078 |
| **2022Q3** | +1.0006 | +0.3271 | -0.3698 | +0.7041 | +0.4121 | +2.0741 |
| **2022Q4** | +1.3904 | +0.2550 | -0.3355 | +0.4574 | +0.6594 | +2.4268 |
| **Suma 2022** | **+4.1298** | **+2.1240** | **-1.3271** | **+2.5401** | **+2.0678** | **+9.5346** |

### Model 3: SWW z energią i żywnością
| Kwartał | Marże cenowe $\eta^p$ (pp) | Szok energii $\eta^E$ (pp) | Szok żywności $\eta^F$ (pp) | Marże płacowe $\eta^w$ (pp) | Pozostałe / polityka (pp) | Inflacja łączna $\pi^c$ (pp) |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **2022Q1** | +0.4302 | +1.1088 | +2.5316 | -0.4525 | -1.0922 | +2.5259 |
| **2022Q2** | +0.7904 | +1.4741 | +1.0189 | -0.7807 | +0.0051 | +2.5078 |
| **2022Q3** | +0.6560 | +1.9235 | +0.5505 | -0.8568 | -0.1991 | +2.0741 |
| **2022Q4** | +0.5766 | +2.2196 | +0.8783 | -0.9022 | -0.3455 | +2.4268 |
| **Suma 2022** | **+2.4532** | **+6.7260** | **+4.9793** | **-2.9923** | **-1.6316** | **+9.5346** |

---

## 4. Zawartość Podfolderu

1. `generate_chart_1.py` — skrypt Python generujący wszystkie wykresy (PNG 300 dpi, PDF), tabele CSV oraz kod LaTeX TikZ.
2. `figure_1_models_comparison_2022.png` / `.pdf` — główny wykres słupkowy skumulowanej dekompozycji w standardzie publikacyjnym (z zachowaniem kolorów: szary, zielony, błękitny, żółty, niebieski, pomarańczowy, czerwony).
3. `figure_1_focus_markup_resolution_2022.png` / `.pdf` — wykres skupiony bezpośrednio na rozwiązaniu zagadki marż cenowych ($\eta^p$ vs $\eta^E$ vs $\eta^F$).
4. `figure_1_combined_decomposition_2022.png` / `.pdf` — dwupanelowy wykres łączący pełną dekompozycję (Panel A) z wykresem skupionym na szokach podażowych (Panel B).
5. `data_models_comparison_2022_annual.csv` — plik CSV ze zagregowanymi danymi rocznymi dla roku 2022.
6. `data_models_comparison_2022_quarterly.csv` — plik CSV ze szczegółowymi danymi kwartalnymi (Q1–Q4 2022) dla wszystkich modeli.
7. `figure_1_models_comparison_2022.tex` — gotowy do wklejenia kod środowiska `\begin{figure}` ze skryptem PGFPlots/TikZ zgodnym z artykułem.
