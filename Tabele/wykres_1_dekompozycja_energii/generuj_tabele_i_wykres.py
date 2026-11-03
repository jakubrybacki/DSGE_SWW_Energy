import os
import sys
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')

script_dir = os.path.dirname(os.path.abspath(__file__))
cnu_csv = os.path.join(script_dir, 'dekompozycja_cnu.csv')

df_cnu = pd.read_csv(cnu_csv)

# 1. Tworzymy tabelę porównawczą zawierającą:
# - Klasyczny SWW (z dekompozycji historycznej paper Fig. 1)
# - Model energetyczny z różnymi cnu (0.00 do 0.10)
# - Pełny model rozszerzony o żywność (paper Fig. 2)

rows = []

# Klasyczny SWW (z tekstu artykułu i Fig. 1)
rows.append({
    'Model': 'Classical SWW (2014)',
    'cnu': 0.00,
    'omega_E': 0.00,
    'omega_F': 0.00,
    'Infl_2022': 10.81,
    'etap_2022': 10.00,
    'Share_etap_2022': 92.5,
    'etaE_2022': 0.00,
    'etaF_2022': 0.00,
    'etaw_2022': -2.79,
    'Infl_2023_H1': 2.32,
    'etap_2023_H1': 2.30,
    'Share_etap_2023_H1': 99.0
})

# Model energetyczny (różne cnu)
for _, r in df_cnu.iterrows():
    nu = r['cnu']
    desc = f'SWW Energy (nu={nu:.2f})' if nu > 0 else 'SWW Energy (nu=0.00, consumption only)'
    rows.append({
        'Model': desc,
        'cnu': nu,
        'omega_E': 0.08,
        'omega_F': 0.00,
        'Infl_2022': r['Infl_2022'],
        'etap_2022': r['etap_2022'],
        'Share_etap_2022': r['Share_etap_2022'],
        'etaE_2022': r['etaE_2022'],
        'etaF_2022': 0.00,
        'etaw_2022': r['etaw_2022'],
        'Infl_2023_H1': r['Infl_2023'] / 2, # przybliżenie H1 lub pełny 2023
        'etap_2023_H1': r['etap_2023'] / 2,
        'Share_etap_2023_H1': r['Share_etap_2023']
    })

# Pełny model z energią i żywnością (Fig. 2)
rows.append({
    'Model': 'SWW Energy + Food (nu=0.05)',
    'cnu': 0.05,
    'omega_E': 0.08,
    'omega_F': 0.05,
    'Infl_2022': 10.81,
    'etap_2022': 2.45,
    'Share_etap_2022': 22.7,
    'etaE_2022': 6.73,
    'etaF_2022': 4.98,
    'etaw_2022': -2.99,
    'Infl_2023_H1': 2.32,
    'etap_2023_H1': 0.70,
    'Share_etap_2023_H1': 30.4
})

comp_df = pd.DataFrame(rows)
comp_csv = os.path.join(script_dir, 'tabela_udzial_szoku_marzowego.csv')
comp_df.to_csv(comp_csv, index=False)

# 2. Generowanie tabeli LaTeX
tex_file = os.path.join(script_dir, 'tabela_udzial_szoku_marzowego.tex')
with open(tex_file, 'w', encoding='utf-8') as f:
    f.write(r'''\begin{table}[H]
\centering
\small
\caption{The ``Greedflation'' Bias: Contribution of Price-Markup Shocks to Eurozone Inflation across Model Specifications (2022--2023)}
\label{tab:greedflation_bias}
\begin{tabular}{@{}l ccc cccc ccc@{}}
\toprule
\multirow{2}{*}{\textbf{Model Specification}} & \multicolumn{3}{c}{\textbf{Parameters}} & \multicolumn{4}{c}{\textbf{2022 Inflation Decomposition (pp)}} & \multicolumn{3}{c}{\textbf{2023 Inflation}} \\
\cmidrule(lr){2-4} \cmidrule(lr){5-8} \cmidrule(l){9-11}
 & $\nu$ & $\omega_E$ & $\omega_F$ & Total & Markup ($\hat{\varepsilon}_t^p$) & Energy ($\hat{\varepsilon}_t^E$) & Share (\%) & Total & Markup ($\hat{\varepsilon}_t^p$) & Share (\%) \\
\midrule
''')
    for _, r in comp_df.iterrows():
        mod_name = r['Model'].replace('_', r'\_')
        nu_str = f"{r['cnu']:.2f}"
        oe_str = f"{r['omega_E']:.2f}"
        of_str = f"{r['omega_F']:.2f}"
        inf22 = f"{r['Infl_2022']:.2f}"
        etap22 = f"{r['etap_2022']:.2f}"
        etae22 = f"{r['etaE_2022']:.2f}"
        sh22 = f"{r['Share_etap_2022']:.1f}\\%"
        inf23 = f"{r['Infl_2023_H1']:.2f}"
        etap23 = f"{r['etap_2023_H1']:.2f}"
        sh23 = f"{r['Share_etap_2023_H1']:.1f}\\%"
        
        # Pogrubienie dla klasycznego, bazowego i pełnego
        if 'Classical' in r['Model'] or '0.05' in r['Model'] and 'Food' not in r['Model'] or 'Food' in r['Model']:
            f.write(f"\\textbf{{{mod_name}}} & {nu_str} & {oe_str} & {of_str} & {inf22} & \\textbf{{{etap22}}} & {etae22} & \\textbf{{{sh22}}} & {inf23} & \\textbf{{{etap23}}} & \\textbf{{{sh23}}} \\\\\n")
        else:
            f.write(f"{mod_name} & {nu_str} & {oe_str} & {of_str} & {inf22} & {etap22} & {etae22} & {sh22} & {inf23} & {etap23} & {sh23} \\\\\n")
            
    f.write(r'''\bottomrule
\end{tabular}
\par\smallskip
\footnotesize\raggedright 
\textit{Notes:} Contributions in percentage points summed over the four quarters of 2022 and annual rate / H1 2023. $\nu$ denotes the energy share in intermediate gross output, $\omega_E$ the energy share in the HICP consumption basket, and $\omega_F$ the imported food share. The markup share (\%) measures $(\hat{\varepsilon}_t^p\text{ contribution}) / (\text{Total inflation}) \times 100$. When intermediate energy and imported food are omitted ($\nu = \omega_E = \omega_F = 0$), the standard Smets-Wouters filter attributes over 92\% of 2022 inflation to price markups (``greedflation''). Introducing energy in production ($\nu > 0$) and food ($\omega_F > 0$) reduces the markup contribution to $\approx 22.7\%$.
\end{table}
''')

# 3. Generowanie wykresu słupkowego skumulowanego
nu_labels = [f'{v:.2f}' for v in df_cnu['cnu']]
x = np.arange(len(nu_labels))
width = 0.35

fig, ax = plt.subplots(figsize=(10, 6), dpi=200)
c_markup = '#7F7F7F'
c_energy = '#00B050'

ax.bar(x - width/2, df_cnu['etap_2022'], width, label='Szok marży (etap) - 2022', color=c_markup, edgecolor='black', linewidth=0.7)
ax.bar(x - width/2, df_cnu['etaE_2022'], width, bottom=df_cnu['etap_2022'], label='Szok energii (etaE) - 2022', color=c_energy, edgecolor='black', linewidth=0.7)

ax.bar(x + width/2, df_cnu['etap_2023'], width, label='Szok marży (etap) - 2023', color=c_markup, alpha=0.55, hatch='//', edgecolor='black', linewidth=0.7)
ax.bar(x + width/2, df_cnu['etaE_2023'], width, label='Szok energii (etaE) - 2023 (dezinflacja)', color=c_energy, alpha=0.55, hatch='\\\\', edgecolor='black', linewidth=0.7)

ax.axhline(0, color='black', linewidth=1, linestyle='-')
ax.grid(axis='y', linestyle='--', alpha=0.5)

ax.set_xlabel(r'Udział energii w funkcji produkcji ($\nu$)', fontsize=12, fontweight='bold', labelpad=8)
ax.set_ylabel('Wkład do inflacji HICP (punkty procentowe)', fontsize=12, fontweight='bold', labelpad=8)
ax.set_title('Wkład szoku marży cenowej i szoku energii do inflacji w latach 2022 i 2023\nw zależności od parametru $\\nu$', 
             fontsize=13, fontweight='bold', pad=14)

ax.set_xticks(x)
ax.set_xticklabels(nu_labels, fontsize=11)

for i in range(len(x)):
    total_2022 = df_cnu['etap_2022'].iloc[i] + df_cnu['etaE_2022'].iloc[i]
    ax.text(x[i] - width/2, total_2022 + 0.15, f'{total_2022:.2f}', ha='center', va='bottom', fontsize=8.5, fontweight='bold')
    total_2023 = df_cnu['etap_2023'].iloc[i] + df_cnu['etaE_2023'].iloc[i]
    y_pos = total_2023 - 0.25 if total_2023 < 0 else total_2023 + 0.15
    va_pos = 'top' if total_2023 < 0 else 'bottom'
    ax.text(x[i] + width/2, y_pos, f'{total_2023:+.2f}', ha='center', va=va_pos, fontsize=8.5, fontweight='bold')
    ax.text(x[i] - width/2, -1.65, "'22", ha='center', va='top', fontsize=8, color='#333333')
    ax.text(x[i] + width/2, -1.65, "'23", ha='center', va='top', fontsize=8, color='#555555')

ax.set_ylim([-2.0, 7.8])
ax.legend(loc='upper right', frameon=True, framealpha=0.9, fontsize=9.5)
plt.tight_layout()

chart_path = os.path.join(script_dir, 'wykres_udzial_marz_vs_cnu.png')
plt.savefig(chart_path, dpi=200)
chart_path_alt = os.path.join(script_dir, 'wykres_slupkowy_marze_energia.png')
plt.savefig(chart_path_alt, dpi=200)
plt.close()

# 4. Generowanie pliku Markdown z wnioskami
md_file = os.path.join(script_dir, 'tabela_udzial_szoku_marzowego.md')
with open(md_file, 'w', encoding='utf-8') as f:
    f.write(f'''# Ćwiczenie empiryczne: Wpływ udziału energii w produkcji ($\nu$) na diagnozę „Greedflation”

## 1. Główne wyniki ilościowe (Lata 2022–2023)

Poniższa tabela przedstawia dekompozycję skumulowanej inflacji w strefie euro w 2022 r. i 2023 r. w zależności od struktury modelu DSGE:

| Model / Wariant | $\\nu$ (prod.) | $\\omega_E$ (kons.) | $\\omega_F$ (żywność) | Wkład marży 2022 (pp) | Udział marży w inflacji 2022 | Wkład energii 2022 (pp) | Udział marży w 2023 |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Klasyczny SWW (2014)** | **0.00** | **0.00** | **0.00** | **10.00 pp** | **92.5%** | **0.00 pp** | **99.0%** |
| SWW Energia (tylko koszyk kons.) | 0.00 | 0.08 | 0.00 | 4.44 pp | 46.5% | 1.78 pp | 35.5% |
| SWW Energia (w produkcji $\\nu=0.01$) | 0.01 | 0.08 | 0.00 | 4.40 pp | 46.1% | 1.87 pp | 35.1% |
| SWW Energia (w produkcji $\\nu=0.03$) | 0.03 | 0.08 | 0.00 | 4.31 pp | 45.1% | 2.05 pp | 34.2% |
| **SWW Energia (kalibracja $\\nu=0.05$)** | **0.05** | **0.08** | **0.00** | **4.22 pp** | **44.2%** | **2.23 pp** | **33.2%** |
| SWW Energia (w produkcji $\\nu=0.08$) | 0.08 | 0.08 | 0.00 | 4.08 pp | 42.7% | 2.51 pp | 31.5% |
| SWW Energia (w produkcji $\\nu=0.10$) | 0.10 | 0.08 | 0.00 | 3.98 pp | 41.7% | 2.68 pp | 30.2% |
| **Pełny SWW Energia + Żywność** | **0.05** | **0.08** | **0.05** | **2.45 pp** | **22.7%** | **6.73 pp** | **30.4%** |

## 2. Kluczowe wnioski makroekonomiczne do artykułu

1. **Efekt iluzji „Greedflation” (*Markup Identification Bias*)**:
   - W standardowym modelu SWW (2014) pominięcie surowców importowanych powoduje, że filtr Kalmana przypisuje aż **92.5% inflacji w 2022 r.** wzrostowi marż firm (`etap`).
   - Jest to zniekształcenie ekonometryczne: w obliczu spadających w 2022 r. płac realnych (kosztów pracy) model bez energii zakłada, że koszty firm spadły, a 10% inflacji mogło powstać wyłącznie poprzez agresywne windowanie marż zysku.

2. **Rola energii w funkcji produkcji ($\nu$)**:
   - Sam kanał koszykowy ($\omega_E = 0.08$) obniża wkład marż z 92.5% do 46.5%.
   - Dołączenie energii do funkcji produkcji ($\nu \in [0.01, 0.10]$) systematycznie przejmuje część szoku kosztowego: wkład szoku energetycznego $\\eta^E$ wzrasta z 1.78 pp do 2.68 pp, redukując wkład szoku marżowego o kolejne 0.5 pp.

3. **Efekt rozszerzenia o żywność**:
   - W pełnym modelu uwzględniającym zarówno energię w produkcji i konsumpcji, jak i importowaną żywność, rzeczywisty wkład szoków marżowych w 2022 r. wynosi zaledwie **2.45 pp (ok. 22.7% całkowitej inflacji)**, co jest w pełni spójne z analizami empirycznymi MFW i EBC (Hansen et al., 2023; Bernanke and Blanchard, 2023).
''')

print("SUKCES: Wygenerowano tabelę CSV, plik LaTeX, wykres PNG oraz raport Markdown!")
