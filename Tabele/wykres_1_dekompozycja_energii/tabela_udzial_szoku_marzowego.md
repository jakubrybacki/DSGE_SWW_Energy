# Ćwiczenie empiryczne: Wpływ udziału energii w produkcji ($
u$) na diagnozę „Greedflation”

## 1. Główne wyniki ilościowe (Lata 2022–2023)

Poniższa tabela przedstawia dekompozycję skumulowanej inflacji w strefie euro w 2022 r. i 2023 r. w zależności od struktury modelu DSGE:

| Model / Wariant | $\nu$ (prod.) | $\omega_E$ (kons.) | $\omega_F$ (żywność) | Wkład marży 2022 (pp) | Udział marży w inflacji 2022 | Wkład energii 2022 (pp) | Udział marży w 2023 |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Klasyczny SWW (2014)** | **0.00** | **0.00** | **0.00** | **10.00 pp** | **92.5%** | **0.00 pp** | **99.0%** |
| SWW Energia (tylko koszyk kons.) | 0.00 | 0.08 | 0.00 | 4.44 pp | 46.5% | 1.78 pp | 35.5% |
| SWW Energia (w produkcji $\nu=0.01$) | 0.01 | 0.08 | 0.00 | 4.40 pp | 46.1% | 1.87 pp | 35.1% |
| SWW Energia (w produkcji $\nu=0.03$) | 0.03 | 0.08 | 0.00 | 4.31 pp | 45.1% | 2.05 pp | 34.2% |
| **SWW Energia (kalibracja $\nu=0.05$)** | **0.05** | **0.08** | **0.00** | **4.22 pp** | **44.2%** | **2.23 pp** | **33.2%** |
| SWW Energia (w produkcji $\nu=0.08$) | 0.08 | 0.08 | 0.00 | 4.08 pp | 42.7% | 2.51 pp | 31.5% |
| SWW Energia (w produkcji $\nu=0.10$) | 0.10 | 0.08 | 0.00 | 3.98 pp | 41.7% | 2.68 pp | 30.2% |
| **Pełny SWW Energia + Żywność** | **0.05** | **0.08** | **0.05** | **2.45 pp** | **22.7%** | **6.73 pp** | **30.4%** |

## 2. Kluczowe wnioski makroekonomiczne do artykułu

1. **Efekt iluzji „Greedflation” (*Markup Identification Bias*)**:
   - W standardowym modelu SWW (2014) pominięcie surowców importowanych powoduje, że filtr Kalmana przypisuje aż **92.5% inflacji w 2022 r.** wzrostowi marż firm (`etap`).
   - Jest to zniekształcenie ekonometryczne: w obliczu spadających w 2022 r. płac realnych (kosztów pracy) model bez energii zakłada, że koszty firm spadły, a 10% inflacji mogło powstać wyłącznie poprzez agresywne windowanie marż zysku.

2. **Rola energii w funkcji produkcji ($
u$)**:
   - Sam kanał koszykowy ($\omega_E = 0.08$) obniża wkład marż z 92.5% do 46.5%.
   - Dołączenie energii do funkcji produkcji ($
u \in [0.01, 0.10]$) systematycznie przejmuje część szoku kosztowego: wkład szoku energetycznego $\eta^E$ wzrasta z 1.78 pp do 2.68 pp, redukując wkład szoku marżowego o kolejne 0.5 pp.

3. **Efekt rozszerzenia o żywność**:
   - W pełnym modelu uwzględniającym zarówno energię w produkcji i konsumpcji, jak i importowaną żywność, rzeczywisty wkład szoków marżowych w 2022 r. wynosi zaledwie **2.45 pp (ok. 22.7% całkowitej inflacji)**, co jest w pełni spójne z analizami empirycznymi MFW i EBC (Hansen et al., 2023; Bernanke and Blanchard, 2023).
