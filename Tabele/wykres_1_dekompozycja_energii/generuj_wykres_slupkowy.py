import os
import sys
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')

script_dir = os.path.dirname(os.path.abspath(__file__))
cnu_csv = os.path.join(script_dir, 'dekompozycja_cnu.csv')
df = pd.read_csv(cnu_csv)

# Przygotowujemy dane do wykresu słupkowego
nu_labels = [f'{v:.2f}' for v in df['cnu']]
x = np.arange(len(nu_labels))
width = 0.35  # szerokość słupków

fig, ax = plt.subplots(figsize=(10, 6), dpi=200)

# Kolory zgodne z paletą z artykułu
c_markup = '#7F7F7F'  # szary z TikZ
c_energy = '#00B050'  # zielony z TikZ

# 1. Słupki dla 2022 (po lewej stronie dla każdego nu: x - width/2)
# W 2022 oba szoki są dodatnie, więc stackujemy:
p1_2022 = ax.bar(x - width/2, df['etap_2022'], width, label='Szok marży (etap) - 2022', color=c_markup, edgecolor='black', linewidth=0.7)
p2_2022 = ax.bar(x - width/2, df['etaE_2022'], width, bottom=df['etap_2022'], label='Szok energii (etaE) - 2022', color=c_energy, edgecolor='black', linewidth=0.7)

# 2. Słupki dla 2023 (po prawej stronie dla każdego nu: x + width/2)
# W 2023 etap jest dodatni, a etaE jest ujemny (dezinflacja)
p1_2023 = ax.bar(x + width/2, df['etap_2023'], width, label='Szok marży (etap) - 2023', color=c_markup, alpha=0.55, hatch='//', edgecolor='black', linewidth=0.7)
p2_2023 = ax.bar(x + width/2, df['etaE_2023'], width, label='Szok energii (etaE) - 2023 (dezinflacja)', color=c_energy, alpha=0.55, hatch='\\\\', edgecolor='black', linewidth=0.7)

# Linia zerowa
ax.axhline(0, color='black', linewidth=1, linestyle='-')

# Linie pomocnicze siatki
ax.grid(axis='y', linestyle='--', alpha=0.5)

# Opisy osi i tytuł
ax.set_xlabel(r'Udział energii w funkcji produkcji ($\nu$)', fontsize=12, fontweight='bold', labelpad=8)
ax.set_ylabel('Wkład do inflacji HICP (punkty procentowe)', fontsize=12, fontweight='bold', labelpad=8)
ax.set_title('Wkład szoku marży cenowej i szoku energii do inflacji w latach 2022 i 2023\nw zależności od parametru $\\nu$', 
             fontsize=13, fontweight='bold', pad=14)

ax.set_xticks(x)
ax.set_xticklabels(nu_labels, fontsize=11)

# Etykiety nad/pod słupkami
for i in range(len(x)):
    # Suma 2022
    total_2022 = df['etap_2022'].iloc[i] + df['etaE_2022'].iloc[i]
    ax.text(x[i] - width/2, total_2022 + 0.15, f'{total_2022:.2f}', ha='center', va='bottom', fontsize=8.5, fontweight='bold')
    
    # Suma 2023
    total_2023 = df['etap_2023'].iloc[i] + df['etaE_2023'].iloc[i]
    y_pos = total_2023 - 0.25 if total_2023 < 0 else total_2023 + 0.15
    va_pos = 'top' if total_2023 < 0 else 'bottom'
    ax.text(x[i] + width/2, y_pos, f'{total_2023:+.2f}', ha='center', va=va_pos, fontsize=8.5, fontweight='bold')

# Adnotacja lat pod osiami słupków
for i in range(len(x)):
    ax.text(x[i] - width/2, -1.65, "'22", ha='center', va='top', fontsize=8, color='#333333')
    ax.text(x[i] + width/2, -1.65, "'23", ha='center', va='top', fontsize=8, color='#555555')

ax.set_ylim([-2.0, 7.8])

# Legenda
ax.legend(loc='upper right', frameon=True, framealpha=0.9, fontsize=9.5)

plt.tight_layout()
chart_path = os.path.join(script_dir, 'wykres_udzial_marz_vs_cnu.png')
plt.savefig(chart_path, dpi=200)
plt.close()
print("SUKCES: Wykres słupkowy zapisany w:", chart_path)
