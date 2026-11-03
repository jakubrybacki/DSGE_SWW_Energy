import os
import sys
import numpy as np
import pandas as pd
import scipy.io as sio
import matplotlib.pyplot as plt

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')

# ---------------------------------------------------------
# Ścieżki katalogów
# ---------------------------------------------------------
subfolder = os.path.dirname(os.path.abspath(__file__))
paper_root = os.path.abspath(os.path.join(subfolder, '..', '..'))

mat_path_energy = os.path.join(paper_root, 'SWW_energia_w_produkcji', 'sww_energia_w_produkcji', 'Output', 'sww_energia_w_produkcji_results.mat')
mat_path_food = os.path.join(paper_root, 'SWW_energia_zywnosc', 'sww_energia_zywnosc', 'Output', 'sww_energia_zywnosc_results.mat')

if not os.path.exists(mat_path_energy):
    raise FileNotFoundError(f"Nie znaleziono pliku wyników modelu energii: {mat_path_energy}")
if not os.path.exists(mat_path_food):
    raise FileNotFoundError(f"Nie znaleziono pliku wyników modelu żywności: {mat_path_food}")

# ---------------------------------------------------------
# Ładowanie wyników Modelu 2: SWW_energia_w_produkcji
# ---------------------------------------------------------
mat_e = sio.loadmat(mat_path_energy, struct_as_record=False, squeeze_me=True)
M_e = mat_e['M_']
param_names_e = list(M_e.param_names)
params_e = M_e.params

def get_param_e(name):
    idx = param_names_e.index(name)
    return float(params_e[idx])

omega_e_m2 = get_param_e('c_omega_e')      # Udział energii w koszyku konsumpcyjnym (0.09148)
nu_m2 = get_param_e('c_nu')                # Udział energii w produkcji (0.05000)
omega_core_m2 = 1.0 - omega_e_m2           # Udział dóbr bazowych (0.90852)

irfs_e = mat_e['oo_'].irfs
horizon = 16
quarters = np.arange(horizon)

pi_c_m2 = irfs_e.pi_c_eta_e[:horizon]
pi_m2 = irfs_e.pi_eta_e[:horizon]
pi_e_m2 = irfs_e.pi_e_eta_e[:horizon]

cum_pi_c_m2 = np.cumsum(pi_c_m2)
cum_pi_m2 = np.cumsum(pi_m2)
cum_pi_e_m2 = np.cumsum(pi_e_m2)

cum_contrib_energy_m2 = omega_e_m2 * cum_pi_e_m2
cum_contrib_core_m2 = omega_core_m2 * cum_pi_m2

diff_m2 = np.max(np.abs(cum_pi_c_m2 - (cum_contrib_energy_m2 + cum_contrib_core_m2)))
assert diff_m2 < 1e-10, f"Błąd tożsamości w Modelu 2: {diff_m2}"

# ---------------------------------------------------------
# Ładowanie wyników Modelu 3: SWW_energia_zywnosc
# ---------------------------------------------------------
mat_f = sio.loadmat(mat_path_food, struct_as_record=False, squeeze_me=True)
M_f = mat_f['M_']
param_names_f = list(M_f.param_names)
params_f = M_f.params

def get_param_f(name):
    idx = param_names_f.index(name)
    return float(params_f[idx])

omega_e_m3 = get_param_f('c_omega_e')      # Udział energii w koszyku (0.07751)
omega_f_m3 = get_param_f('c_omega_f')      # Udział żywności w koszyku (0.05000)
nu_m3 = get_param_f('c_nu')                # Udział energii w produkcji (0.05000)
omega_core_m3 = 1.0 - omega_e_m3 - omega_f_m3  # Udział dóbr bazowych (0.87249)

irfs_f = mat_f['oo_'].irfs

# Szok cen energii eta_e
pi_c_m3 = irfs_f.pi_c_eta_e[:horizon]
pi_m3 = irfs_f.pi_eta_e[:horizon]
pi_e_m3 = irfs_f.pi_e_eta_e[:horizon]
pi_f_m3 = irfs_f.pi_f_eta_e[:horizon]

cum_pi_c_m3 = np.cumsum(pi_c_m3)
cum_pi_m3 = np.cumsum(pi_m3)
cum_pi_e_m3 = np.cumsum(pi_e_m3)
cum_pi_f_m3 = np.cumsum(pi_f_m3)

cum_contrib_energy_m3 = omega_e_m3 * cum_pi_e_m3
cum_contrib_core_m3 = omega_core_m3 * cum_pi_m3
cum_contrib_food_m3 = omega_f_m3 * cum_pi_f_m3

diff_m3_e = np.max(np.abs(cum_pi_c_m3 - (cum_contrib_energy_m3 + cum_contrib_core_m3 + cum_contrib_food_m3)))
assert diff_m3_e < 1e-10, f"Błąd tożsamości w Modelu 3 (eta_e): {diff_m3_e}"

# Szok cen żywności eta_f
pi_c_m3_f = irfs_f.pi_c_eta_f[:horizon]
pi_m3_f = irfs_f.pi_eta_f[:horizon]
pi_e_m3_f = irfs_f.pi_e_eta_f[:horizon]
pi_food_m3_f = irfs_f.pi_f_eta_f[:horizon]

cum_pi_c_m3_f = np.cumsum(pi_c_m3_f)
cum_contrib_energy_m3_f = omega_e_m3 * np.cumsum(pi_e_m3_f)
cum_contrib_core_m3_f = omega_core_m3 * np.cumsum(pi_m3_f)
cum_contrib_food_m3_f = omega_f_m3 * np.cumsum(pi_food_m3_f)

diff_m3_f = np.max(np.abs(cum_pi_c_m3_f - (cum_contrib_energy_m3_f + cum_contrib_core_m3_f + cum_contrib_food_m3_f)))
assert diff_m3_f < 1e-10, f"Błąd tożsamości w Modelu 3 (eta_f): {diff_m3_f}"

print("Pomyślnie zweryfikowano tożsamości addytywne skumulowanych IRF dla obu modeli.")

# ---------------------------------------------------------
# ZAPIS DANYCH CSV
# ---------------------------------------------------------
df_m2 = pd.DataFrame({
    'quarter': quarters,
    'cum_headline_hicp_pp': cum_pi_c_m2,
    'cum_contrib_energy_pp': cum_contrib_energy_m2,
    'cum_contrib_core_pp': cum_contrib_core_m2,
    'pct_contrib_energy': cum_contrib_energy_m2 / cum_pi_c_m2 * 100,
    'pct_contrib_core': cum_contrib_core_m2 / cum_pi_c_m2 * 100,
    'quarterly_pi_c_pp': pi_c_m2,
    'quarterly_pi_core_pp': pi_m2,
    'quarterly_pi_e_pp': pi_e_m2
})
csv_m2_path = os.path.join(subfolder, 'data_irf_decomposition_energy_model.csv')
df_m2.to_csv(csv_m2_path, index=False)

df_m3 = pd.DataFrame({
    'quarter': quarters,
    'cum_headline_hicp_pp': cum_pi_c_m3,
    'cum_contrib_energy_pp': cum_contrib_energy_m3,
    'cum_contrib_core_pp': cum_contrib_core_m3,
    'cum_contrib_food_pp': cum_contrib_food_m3,
    'pct_contrib_energy': cum_contrib_energy_m3 / cum_pi_c_m3 * 100,
    'pct_contrib_core': cum_contrib_core_m3 / cum_pi_c_m3 * 100,
    'pct_contrib_food': cum_contrib_food_m3 / cum_pi_c_m3 * 100,
    'quarterly_pi_c_pp': pi_c_m3,
    'quarterly_pi_core_pp': pi_m3,
    'quarterly_pi_e_pp': pi_e_m3,
    'quarterly_pi_f_pp': pi_f_m3
})
csv_m3_path = os.path.join(subfolder, 'data_irf_decomposition_food_model.csv')
df_m3.to_csv(csv_m3_path, index=False)

df_m3_f = pd.DataFrame({
    'quarter': quarters,
    'cum_headline_hicp_pp': cum_pi_c_m3_f,
    'cum_contrib_food_pp': cum_contrib_food_m3_f,
    'cum_contrib_core_pp': cum_contrib_core_m3_f,
    'cum_contrib_energy_pp': cum_contrib_energy_m3_f,
    'pct_contrib_food': cum_contrib_food_m3_f / cum_pi_c_m3_f * 100,
    'pct_contrib_core': cum_contrib_core_m3_f / cum_pi_c_m3_f * 100,
    'pct_contrib_energy': cum_contrib_energy_m3_f / cum_pi_c_m3_f * 100
})
csv_m3_f_path = os.path.join(subfolder, 'data_irf_decomposition_food_shock.csv')
df_m3_f.to_csv(csv_m3_f_path, index=False)

df_comp = pd.DataFrame({
    'quarter': quarters,
    'M2_energy_model_hicp_pp': cum_pi_c_m2,
    'M2_energy_contrib_pp': cum_contrib_energy_m2,
    'M2_core_contrib_pp': cum_contrib_core_m2,
    'M3_food_model_hicp_pp': cum_pi_c_m3,
    'M3_energy_contrib_pp': cum_contrib_energy_m3,
    'M3_core_contrib_pp': cum_contrib_core_m3,
    'M3_food_contrib_pp': cum_contrib_food_m3
})
csv_comp_path = os.path.join(subfolder, 'data_irf_decomposition_comparison.csv')
df_comp.to_csv(csv_comp_path, index=False)

print("Zapisano pliki CSV z danymi.")

# ---------------------------------------------------------
# PALETA KOLORÓW I STYLE PUBLIKACYJNE
# ---------------------------------------------------------
c_cpi = '#000000'       # Headline HICP - czarny
c_energy = '#2CA02C'    # Energy - publikacyjna zieleń
c_core = '#1F497D'      # Core / Domestic - granat
c_food = '#E46C0A'      # Food - ciepły bursztyn/pomarańcz

plt.rcParams['font.family'] = 'DejaVu Sans'
plt.rcParams['mathtext.fontset'] = 'cm'

width = 0.62
y_max = 0.385

# =========================================================================
# WYKRES 1: MODEL 2 (SWW Z ENERGIĄ W PRODUKCJI) - BEZ STRZAŁEK
# =========================================================================
fig1, ax1 = plt.subplots(figsize=(8.8, 5.6), dpi=300)

ax1.bar(quarters, cum_contrib_core_m2, width,
        label=r'Cumulative Core goods ($(1-\omega_e)\sum \pi_t$)',
        color=c_core, alpha=0.90, edgecolor='black', linewidth=0.6)
ax1.bar(quarters, cum_contrib_energy_m2, width,
        bottom=cum_contrib_core_m2,
        label=r'Cumulative Energy ($\omega_e \sum \pi^e_t$)',
        color=c_energy, alpha=0.90, edgecolor='black', linewidth=0.6)

ax1.plot(quarters, cum_pi_c_m2, color=c_cpi, marker='o', markersize=4.8, linewidth=2.3,
         label=r'Cumulative Headline HICP ($\sum \pi^c_t$)', zorder=6)

ax1.axhline(0, color='black', linewidth=0.8)
ax1.set_xlim([-0.6, 15.6])
ax1.set_ylim([0.0, y_max])
ax1.set_xticks(quarters)
ax1.set_xlabel('Quarters after shock ($t$)', fontsize=11, fontweight='semibold')
ax1.set_ylabel('Cumulative contribution to HICP (pp)', fontsize=11, fontweight='semibold')
ax1.set_title(r'Cumulative Additive Decomposition of Headline HICP ($\sum \pi^c_t$)' + '\n' +
              r'SWW Model with Energy in Production (Energy Shock, $\sigma_e = 3.17\%$)',
              fontsize=12, fontweight='bold', pad=12)
ax1.grid(axis='y', linestyle='--', alpha=0.5)
ax1.legend(loc='upper right', frameon=True, framealpha=0.96, fontsize=9.8)

plt.tight_layout()
png_m2_path = os.path.join(subfolder, 'figure_2a_irf_decomposition_energy_model.png')
pdf_m2_path = os.path.join(subfolder, 'figure_2a_irf_decomposition_energy_model.pdf')
plt.savefig(png_m2_path, dpi=300)
plt.savefig(pdf_m2_path)
plt.close()
print(f"Zapisano wykres dla Modelu z energią w produkcji: {png_m2_path}")

# =========================================================================
# WYKRES 2: MODEL 3 (SWW Z ENERGIĄ I ŻYWNOŚCIĄ) - SZOK ENERGII - BEZ STRZAŁEK
# =========================================================================
fig2, ax2 = plt.subplots(figsize=(8.8, 5.6), dpi=300)

ax2.bar(quarters, cum_contrib_core_m3, width,
        label=r'Cumulative Core goods ($(1-\omega_e-\omega_f)\sum \pi_t$)',
        color=c_core, alpha=0.90, edgecolor='black', linewidth=0.6)
ax2.bar(quarters, cum_contrib_food_m3, width,
        bottom=cum_contrib_core_m3,
        label=r'Cumulative Food ($\omega_f \sum \pi^f_t$)',
        color=c_food, alpha=0.90, edgecolor='black', linewidth=0.6)
ax2.bar(quarters, cum_contrib_energy_m3, width,
        bottom=cum_contrib_core_m3 + cum_contrib_food_m3,
        label=r'Cumulative Energy ($\omega_e \sum \pi^e_t$)',
        color=c_energy, alpha=0.90, edgecolor='black', linewidth=0.6)

ax2.plot(quarters, cum_pi_c_m3, color=c_cpi, marker='o', markersize=4.8, linewidth=2.3,
         label=r'Cumulative Headline HICP ($\sum \pi^c_t$)', zorder=6)

ax2.axhline(0, color='black', linewidth=0.8)
ax2.set_xlim([-0.6, 15.6])
ax2.set_ylim([0.0, y_max])
ax2.set_xticks(quarters)
ax2.set_xlabel('Quarters after shock ($t$)', fontsize=11, fontweight='semibold')
ax2.set_ylabel('Cumulative contribution to HICP (pp)', fontsize=11, fontweight='semibold')
ax2.set_title(r'Cumulative Additive Decomposition of Headline HICP ($\sum \pi^c_t$)' + '\n' +
              r'SWW Model with Intermediate Energy and Imported Food (Energy Shock, $\sigma_e = 3.15\%$)',
              fontsize=12, fontweight='bold', pad=12)
ax2.grid(axis='y', linestyle='--', alpha=0.5)
ax2.legend(loc='upper right', frameon=True, framealpha=0.96, fontsize=9.8)

plt.tight_layout()
png_m3_path = os.path.join(subfolder, 'figure_2b_irf_decomposition_food_model_energy_shock.png')
pdf_m3_path = os.path.join(subfolder, 'figure_2b_irf_decomposition_food_model_energy_shock.pdf')
plt.savefig(png_m3_path, dpi=300)
plt.savefig(pdf_m3_path)
plt.close()
print(f"Zapisano poprawiony wykres dla Modelu z energią i żywnością: {png_m3_path}")

# =========================================================================
# WYKRES 3: MODEL 3 (SWW Z ENERGIĄ I ŻYWNOŚCIĄ) - SZOK ŻYWNOŚCIOWY - BEZ STRZAŁEK
# =========================================================================
fig3, ax3 = plt.subplots(figsize=(8.8, 5.6), dpi=300)

ax3.bar(quarters, cum_contrib_core_m3_f, width,
        label=r'Cumulative Core goods ($(1-\omega_e-\omega_f)\sum \pi_t$)',
        color=c_core, alpha=0.90, edgecolor='black', linewidth=0.6)
ax3.bar(quarters, cum_contrib_food_m3_f, width,
        bottom=cum_contrib_core_m3_f,
        label=r'Cumulative Food ($\omega_f \sum \pi^f_t$)',
        color=c_food, alpha=0.90, edgecolor='black', linewidth=0.6)
ax3.bar(quarters, cum_contrib_energy_m3_f, width,
        bottom=cum_contrib_core_m3_f + cum_contrib_food_m3_f,
        label=r'Cumulative Energy ($\omega_e \sum \pi^e_t$)',
        color=c_energy, alpha=0.90, edgecolor='black', linewidth=0.6)

ax3.plot(quarters, cum_pi_c_m3_f, color=c_cpi, marker='o', markersize=4.8, linewidth=2.3,
         label=r'Cumulative Headline HICP ($\sum \pi^c_t$)', zorder=6)

ax3.axhline(0, color='black', linewidth=0.8)
ax3.set_xlim([-0.6, 15.6])
ax3.set_ylim([0.0, y_max])
ax3.set_xticks(quarters)
ax3.set_xlabel('Quarters after shock ($t$)', fontsize=11, fontweight='semibold')
ax3.set_ylabel('Cumulative contribution to HICP (pp)', fontsize=11, fontweight='semibold')
ax3.set_title(r'Cumulative Additive Decomposition of Headline HICP ($\sum \pi^c_t$)' + '\n' +
              r'SWW Model with Intermediate Energy and Imported Food (Food Shock, $\sigma_f$)',
              fontsize=12, fontweight='bold', pad=12)
ax3.grid(axis='y', linestyle='--', alpha=0.5)
ax3.legend(loc='upper right', frameon=True, framealpha=0.96, fontsize=9.8)

plt.tight_layout()
png_m3_f_path = os.path.join(subfolder, 'figure_2c_irf_decomposition_food_shock.png')
pdf_m3_f_path = os.path.join(subfolder, 'figure_2c_irf_decomposition_food_shock.pdf')
plt.savefig(png_m3_f_path, dpi=300)
plt.savefig(pdf_m3_f_path)
plt.close()
print(f"Zapisano wykres dla Modelu z żywnością (szok żywności): {png_m3_f_path}")

# =========================================================================
# WYKRES 4: BEZPOŚREDNIE PORÓWNANIE OBOK SIEBIE (PANEL 2-WYKRESOWY) - BEZ STRZAŁEK
# =========================================================================
fig4, (ax_comp1, ax_comp2) = plt.subplots(1, 2, figsize=(15, 5.8), dpi=300, sharey=True)

# Lewy panel: Model 2 (Tylko energia w produkcji)
ax_comp1.bar(quarters, cum_contrib_core_m2, width,
             label=r'Cumulative Core goods ($(1-\omega_e)\sum \pi_t$)',
             color=c_core, alpha=0.90, edgecolor='black', linewidth=0.6)
ax_comp1.bar(quarters, cum_contrib_energy_m2, width,
             bottom=cum_contrib_core_m2,
             label=r'Cumulative Energy ($\omega_e \sum \pi^e_t$)',
             color=c_energy, alpha=0.90, edgecolor='black', linewidth=0.6)
ax_comp1.plot(quarters, cum_pi_c_m2, color=c_cpi, marker='o', markersize=4.5, linewidth=2.2,
              label=r'Cumulative Headline HICP ($\sum \pi^c_t$)', zorder=6)

ax_comp1.axhline(0, color='black', linewidth=0.8)
ax_comp1.set_xlim([-0.6, 15.6])
ax_comp1.set_ylim([0.0, y_max])
ax_comp1.set_xticks(quarters[::2])
ax_comp1.set_xlabel('Quarters after shock ($t$)', fontsize=11, fontweight='semibold')
ax_comp1.set_ylabel('Cumulative contribution to HICP (pp)', fontsize=11, fontweight='semibold')
ax_comp1.set_title(r'(a) Model with Energy in Production ($\nu=0.05, \omega_e=0.078$)', fontsize=11.5, fontweight='bold', pad=10)
ax_comp1.grid(axis='y', linestyle='--', alpha=0.5)
ax_comp1.legend(loc='upper right', frameon=True, framealpha=0.96, fontsize=9.2)

# Prawy panel: Model 3 (Energia w produkcji + żywność)
ax_comp2.bar(quarters, cum_contrib_core_m3, width,
             label=r'Cumulative Core goods ($(1-\omega_e-\omega_f)\sum \pi_t$)',
             color=c_core, alpha=0.90, edgecolor='black', linewidth=0.6)
ax_comp2.bar(quarters, cum_contrib_food_m3, width,
             bottom=cum_contrib_core_m3,
             label=r'Cumulative Food ($\omega_f \sum \pi^f_t$)',
             color=c_food, alpha=0.90, edgecolor='black', linewidth=0.6)
ax_comp2.bar(quarters, cum_contrib_energy_m3, width,
             bottom=cum_contrib_core_m3 + cum_contrib_food_m3,
             label=r'Cumulative Energy ($\omega_e \sum \pi^e_t$)',
             color=c_energy, alpha=0.90, edgecolor='black', linewidth=0.6)
ax_comp2.plot(quarters, cum_pi_c_m3, color=c_cpi, marker='o', markersize=4.5, linewidth=2.2,
              label=r'Cumulative Headline HICP ($\sum \pi^c_t$)', zorder=6)

ax_comp2.axhline(0, color='black', linewidth=0.8)
ax_comp2.set_xlim([-0.6, 15.6])
ax_comp2.set_xticks(quarters[::2])
ax_comp2.set_xlabel('Quarters after shock ($t$)', fontsize=11, fontweight='semibold')
ax_comp2.set_title(r'(b) Model with Energy & Imported Food ($\nu=0.05, \omega_e=0.078, \omega_f=0.05$)', fontsize=11.5, fontweight='bold', pad=10)
ax_comp2.grid(axis='y', linestyle='--', alpha=0.5)
ax_comp2.legend(loc='upper right', frameon=True, framealpha=0.96, fontsize=9.2)

fig4.suptitle(r'Comparison of Cumulative Additive Decomposition of Headline HICP to 1 s.d. Energy Shock ($\eta^e_t$)' + '\n' +
              'Cross-Model Perspective: Transmission into Core Goods Inflation',
              fontsize=13, fontweight='bold', y=0.985)

plt.tight_layout(rect=[0, 0, 1, 0.93])
png_comp_path = os.path.join(subfolder, 'figure_2_comparison_energy_vs_food_models.png')
pdf_comp_path = os.path.join(subfolder, 'figure_2_comparison_energy_vs_food_models.pdf')
plt.savefig(png_comp_path, dpi=300)
plt.savefig(pdf_comp_path)
plt.close()
print(f"Zapisano zestawienie porównawcze 2-panelowe: {png_comp_path}")

# =========================================================================
# GENEROWANIE KODU LATEX
# =========================================================================
tex_content = r"""% LaTeX Figure: Cumulative Additive Decomposition of Headline HICP (Energy Shock)
\begin{figure}[H]
\centering
\caption{Cumulative additive decomposition of headline HICP inflation response to an energy price shock ($\eta^e_t$).}
\label{fig:cumulative_irf_decomposition}
\includegraphics[width=0.90\textwidth]{Tabele/wykres_2_IRF_szoku_energetycznego/figure_2b_irf_decomposition_food_model_energy_shock.pdf}
\par\smallskip
\footnotesize\raggedright \textit{Source:} Own calculations based on the extended SWW (2014) DSGE model with intermediate energy ($\nu = 0.05$) and imported food basket ($\omega_f = 0.05, \omega_e = 0.0775$). 
The chart presents the exact additive decomposition of the cumulative headline HICP inflation response: $\sum_{k=0}^t \pi^c_k = (1-\omega_e-\omega_f)\sum_{k=0}^t \pi_k + \omega_e \sum_{k=0}^t \pi^e_k + \omega_f \sum_{k=0}^t \pi^f_k$. 
On impact ($t=0$), energy accounts for $94.7\%$ ($+0.245$ pp) of the headline price increase. After one year ($t=4$), persistent cost-push transmission via intermediate production increases the contribution of core domestic goods to $20.8\%$ ($+0.058$ pp), illustrating the gradual emergence of second-round effects.
\end{figure}

% Alternative: Comparison between Model with Energy vs Model with Energy & Food
\begin{figure}[H]
\centering
\caption{Cross-model comparison of cumulative HICP decomposition following an energy price shock ($\eta^e_t$).}
\label{fig:cumulative_irf_decomposition_comparison}
\includegraphics[width=0.98\textwidth]{Tabele/wykres_2_IRF_szoku_energetycznego/figure_2_comparison_energy_vs_food_models.pdf}
\par\smallskip
\footnotesize\raggedright \textit{Source:} Own calculations. Panel (a) shows the model with energy in intermediate production only ($\nu=0.05, \omega_e=0.0915$). Panel (b) shows the extended model with both intermediate energy and an imported food basket ($\omega_f=0.05, \omega_e=0.0775$).
\end{figure}
"""

tex_path = os.path.join(subfolder, 'figure_2_irf_energy_shock.tex')
with open(tex_path, 'w', encoding='utf-8') as f:
    f.write(tex_content)
print(f"Zaktualizowano kod LaTeX: {tex_path}")

print("WSZYSTKIE WYKRESY ZOSTAŁY WYGENEROWANE BEZ STRZAŁEK!")
