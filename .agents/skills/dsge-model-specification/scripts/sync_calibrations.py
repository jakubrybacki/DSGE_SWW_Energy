"""
Synchronizacja kalibracji z pliku Excel (Calibrations.xlsx) do pliku formatu Dynare (.mod).
"""

import sys
from pathlib import Path
import pandas as pd


def export_calibrations(
    excel_path: str = "Calibrations.xlsx",
    output_dir: str = "Estimation_Setup",
    country: str = "PL",
    output_filename: str = None
) -> Path:
    excel_file = Path(excel_path)
    if not excel_file.exists():
        raise FileNotFoundError(f"Nie znaleziono pliku kalibracji: {excel_path}")

    df = pd.read_excel(excel_file)
    required_cols = {"Variable", "Description"}
    if not required_cols.issubset(set(df.columns)):
        raise ValueError(f"Arkusz musi zawierać kolumny: {required_cols}. Znaleziono: {list(df.columns)}")

    if country not in df.columns:
        raise ValueError(f"Brak kolumny dla kraju / specyfikacji '{country}' w arkuszu {excel_path}.")

    out_folder = Path(output_dir)
    out_folder.mkdir(parents=True, exist_ok=True)

    if output_filename is None:
        output_filename = f"{country}_calibration.mod"
    target_path = out_folder / output_filename

    lines = [
        f"// Calibrated parameters generated from {excel_path}",
        f"// Country / Specification: {country}",
        ""
    ]

    for idx, row in df.iterrows():
        var_raw = row["Variable"]
        if pd.isna(var_raw):
            continue
        var_name = str(var_raw).strip()
        if not var_name or var_name.startswith(("//", "#", "%")):
            continue

        val = row[country]
        if pd.isna(val):
            raise ValueError(f"Wiersz {idx+2}: Brak wartości kalibracji dla '{var_name}' w kolumnie '{country}'.")

        desc = str(row.get("Description", "")).strip() if pd.notna(row.get("Description")) else ""
        lines.append(f"{var_name} = {float(val):.6g}; % {desc}")

    with open(target_path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")

    print(f"[OK] Wygenerowano plik kalibracji: {target_path} ({len(lines)-3} parametrow)")
    return target_path


if __name__ == "__main__":
    c_arg = sys.argv[1] if len(sys.argv) > 1 else "ALL"
    if c_arg.upper() == "ALL":
        for c in ["PL", "CZ", "HU", "SK", "RO"]:
            export_calibrations(country=c)
    else:
        export_calibrations(country=c_arg)
