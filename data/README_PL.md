# Dane Eurostat i BIS do modeli SWW

## Codzienna praca

Z głównego katalogu projektu:

```powershell
Rscript data/step1_download_eurostat.R --geo=EA
Rscript data/step2_transfer_to_models.R --geo=EA
```

Pobieranie tworzy główny plik na gospodarkę: `data/output/EA20/dane.rds`
(lub `data/output/PL/dane.rds`). Folder kraju nie zawiera okresu ani timestamptu.
Dane i metadane są razem w RDS. Dodatkowo powstaje czytelny eksport Excel
`data/output/EA20/EA20.xlsx` (lub data/output/PL/PL.xlsx), z zakładkami Dane i Opis.
Ponowne pobranie zastępuje XLSX; przed uruchomieniem zamknij go w Excelu. Pobieranie nie zostawia osobnych CSV, JSON,
XML, RDS diagnostycznych ani plików MATLAB. Robocze pliki powstają w katalogu
systemowym tymczasowym i są usuwane także po błędzie. Poprzedni wynik zastępujemy
dopiero po poprawnym zakończeniu i sprawdzeniu nowego pliku.

RDS jest formatem R. Skrypt transferu czyta go i tworzy `dane.mat` w obu modelach,
zachowując ich dotychczasowe pliki pomocnicze potrzebne do kalibracji i kontroli.
Nie uruchamia estymacji ani nie zmienia kalibracji. Po transferze można odświeżyć
komentarze o średnich danych przez `calibration/generate_mod_inputs.ps1 -Country EA20`.

## Biblioteki R

Korzystamy ze standardowych `.libPaths()`; nie ma lokalnego `data/r-library`.
Wymagane: `jsonlite`, `xml2` (BIS), `seasonal` i `x13binary` (odsezonowanie),
`R.matlab` (transfer) i `openxlsx` (Excel). Biblioteka to katalog z pakietami, a nie plik `.RData`.
Brakujące pakiety można zainstalować opcją `--install=true`; trafiają do
standardowego `R_LIBS_USER`, nie do projektu ani katalogu instalacyjnego R.

```r
.libPaths()
Sys.getenv('R_LIBS_USER')
```

## Parametry pobierania

| Opcja | Domyślnie | Znaczenie |
|---|---|---|
| `--geo` | `EA` | Alias EA20; także np. PL lub DE |
| `--start` | `2009Q1` | Początek próby |
| `--end` | `2025Q4` | Koniec próby i danych do odsezonowania |
| `--price-sa` | `x13` | X-13/X-11; `none` dla danych NSA |
| `--employment-sa` | `auto` | SCA; jawny fallback do SA, gdy cały szereg SCA pusty |
| `--rate-source` | `bis` | Oficjalna stopa banku centralnego; alternatywnie `eurostat` |
| `--rate-code` | `IRT_M3` | Kod tylko dla źródła Eurostat |
| `--rate-csv` | pusty | Własny CSV `quarter,robs`, stopa w procentach rocznie |
| `--out` | `data/output/KRAJ` | Folder na pojedynczy `dane.rds` |
| `--install` | `false` | Instalacja brakujących pakietów w bibliotece użytkownika |

Transfer przyjmuje `--geo=EA`, `--geo=PL` lub `--geo=ALL` oraz `--install=true`.
W RStudio można ustawić katalog roboczy na `data`, wykonać
`source('step1_download_eurostat.R')`, a następnie `main(c('--geo=EA'))`.

## Zawartość jednego pliku

```r
x <- readRDS('data/output/EA20/dane.rds')
x$observations             # gotowe szeregi kwartalne
x$config                   # okres, geografia, jednostki i ustawienia
x$sources                  # źródła, URL, daty pobrań, sumy kontrolne
x$hicp_monthly              # ceny wymagane do mapowania płac w modelu klasycznym
names(x$provenance)         # surowe odpowiedzi i diagnostyka przechowane jako bajty
```

Pole `format` ma wartość `sww-data-v1`. W `provenance` pozostają surowe odpowiedzi,
flagi, raporty, poziomy i obiekty diagnostyczne X-13; nie powstają z nich osobne
pliki w folderze wynikowym. Przykład odczytu raportu bez wypakowania:

```r
cat(rawToChar(x$provenance[['report.txt']]))
```

Istniejące dane PL przeniesiono do RDS bez ponownego pobierania: zachowują swoje
wcześniejsze źródło stopy Eurostat. Kolejne pobranie domyślnie użyje BIS.

## Definicje i jednostki

- PKB, konsumpcja i inwestycje: `namq_10_gdp`, realne poziomy CLV20_MNAC/SCA;
  wzrost to `100*diff(log(poziom))` kwartalnie.
- Konsumpcja obejmuje gospodarstwa domowe i NPISH; inwestycje to nakłady brutto
  na środki trwałe. Nie dzielimy wielkości przez ludność.
- Płace: D1 / liczba pracowników najemnych SAL_DC. D1 obejmuje składki pracodawcy.
- Zatrudnienie: EMP_DC, razem z samozatrudnionymi. Bezrobocie: une_rt_q, Y15-74,
  obie płcie, PC_ACT/SA, w procentach.
- Inflacja: HICP TOTAL, średnie kwartalne odsezonowanych indeksów, różnice log *100.
- Cena energii: `100*log(NRG/TOT_X_NRG)`, odjęta średnia z próby. HICP bez energii
  nadal obejmuje żywność. Detaliczna cena energii jest przybliżeniem wspólnej ceny
  modelowej dla firm i gospodarstw.
- `robs`: nominalna stopa w procentach rocznie. Równanie obu modeli to
  `robs/4=crbar+r`, więc eksport NIE dzieli jej przez 4. Pomocnicze dane z obiema
  jednostkami są wewnątrz `provenance[['processed/policy_rate_quarterly.csv']]`.
- Model klasyczny: `dwobs = nominalny wzrost płacy - zmiana inflacji` zgodnie z
  jego starszym równaniem. Model energetyczny używa nominalnego wzrostu płacy.

EA20 ma w naszym źródle bezrobocie od 2009Q1. Domyślna próba obejmuje 68 kwartałów.
Nie skracamy próby automatycznie i nie wstawiamy zer zamiast braków.
Dane są najnowszą rewizją, nie historycznym zbiorem dostępnym w danym momencie.
X-13 nie dostaje obserwacji po końcu próby. Średnią ceny energii należy zachować
przy późniejszym prognozowaniu, nie przeliczać jej z przyszłymi obserwacjami.

## BIS

Dla strefy euro pobieramy WS_CBPOL, D.XM: MRO do 17.09.2024, następnie stopę
 depozytową EBC. To zmiana instrumentu; cały szereg nie jest jednolitą stopą
 depozytową ani stopą realną po odjęciu inflacji.
Średnie kwartalne liczymy po dniach kalendarzowych, nie z miesięcznych wartości
BIS z końca okresu. Braki weekendowe XM uzupełniamy tylko przy równych wartościach
przed i po weekendzie, najwyżej dwudniowej przerwie i dniach sobota/niedziela.
Zachowujemy oryginalne wartości, flagi i oznaczenia uzupełnień.
Inne braki przerywają pobranie. Nie ma automatycznego przejścia na Eurostat.
Kraje strefy euro po akcesji używają XM; próby przecinające akcesję wymagają
własnego szeregu. Dla innych gospodarek używamy kodu kraju BIS.

Wagi energii HICP podzielone przez 1000 są propozycją kalibracji udziału konsumpcji,
a nie automatyczną zmianą parametrów. Udział energii w produkcji wymaga tablic
podaży i wykorzystania/input-output.

Źródła:
- Eurostat API: https://ec.europa.eu/eurostat/web/user-guides/data-browser/api-data-access/api-introduction
- BIS API: https://stats.bis.org/api-doc/v1/
- Metodyka BIS: https://www.bis.org/statistics/cbpol/cbpol_doc.pdf
- Szczegółowe zapytania: `sources` wewnątrz RDS.

Eksport XLSX bez ponownego pobierania (z katalogu głównego projektu):

```r
source("data/step1_download_eurostat.R")
export_data_xlsx(readRDS("data/output/EA20/dane.rds"), "data/output/EA20/EA20.xlsx")
```
