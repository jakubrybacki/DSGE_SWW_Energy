# Rozszerzenie replikacji SWW o energię

Plik `sww_energia_w_produkcji.mod` rozszerza lokalny `../SWW_klasyczny/sww_klasyczny.mod`. Wersja bazowa pozostaje bez zmian. Kod bazowy dostępny w katalogu nie zawierał osobnych szoków energii i żywności opisanych w artykule. Nowy plik implementuje strukturalny mechanizm energii na bazie tej replikacji; nie jest modyfikacją nieodnalezionego kodu estymacji z artykułu. Żywność pozostaje częścią dobra nieenergetycznego.

## Uruchomienie

W MATLAB, po przejściu do katalogu tego pliku:

```matlab
addpath('C:/dynare/7.1/matlab');
dynare sww_energia_w_produkcji.mod;
step_2_validate_model;
```

Model liczy IRF na 40 kwartałów po szoku ceny energii. Wykresy są wyłączone (`nograph`); wyniki są w `oo_.irfs` i katalogu `sww_energia_w_produkcji/Output`. Nazwy m.in. `gdp_etaE`, `c_etaE`, `en_etaE`, `piC_etaE`. Nie uruchamia estymacji bez danych. Klasyczną replikację uruchamia `../SWW_klasyczny/step_1_run_model.m`.

## Założenia mechanizmu

1. Firmy używają kapitału, pracy i importowanej energii. Gospodarstwa kupują dobro krajowe i energię.
2. Jedna cena energii obowiązuje firmy i konsumentów. Nie ma podatków energetycznych, marż detalicznych, regulowanych taryf ani opóźnionego przenoszenia cen. To ograniczenie empiryczne, a nie twierdzenie, że ceny importowe i HICP energia są tożsame.
3. Cena energii względem dobra krajowego jest egzogenicznym AR(1). Szok jest innowacją ceny względnej; model nie rozdziela światowych szoków podaży, popytu i geopolityki.
4. W każdym kwartale import energii jest w całości opłacany eksportem dobra krajowego. Zagranica absorbuje ten eksport po cenie krajowej; nie ma osobnej krzywej popytu eksportowego, kursu walutowego ani aktywów zagranicznych. To celowe, silne uproszczenie domykające gospodarkę. Nie należy na tej wersji estymować obserwowanego eksportu, salda handlowego ani długu zagranicznego.
5. Luka produktu odnosi się do realnego PKB i jego odpowiednika przy elastycznych cenach/płacach, przy tej samej egzogenicznej realnej cenie energii. Reguła stopy procentowej reaguje na inflację konsumpcyjną.

## Równania i jednostki

Duże litery oznaczają poziomy. Małe litery w kodzie to odchylenia `100*log(Z/Z_ss)`, a inflacja to kwartalne punkty procentowe względem trendu. `pi` nadal oznacza inflację krajową, `piC` inflację konsumpcyjną, `piE` inflację energii. `pE` to logarytm ceny PE/PD, a nie jej stopa wzrostu. Koszt stały skaluje się z trendem; poniższe poziomy można czytać jako wielkości po usunięciu trendu.

### Produkcja i koszty

`X = A*K^alpha*N^(1-alpha-nu)*En^nu`, `Y = X-Phi`.

`K` oznacza usługi kapitału, a nie sam jego zasób. `En` to energia firm; nazwa `e` pozostaje zatrudnieniem. Przy `X_ss/Y_ss = cpsip`:

```text
y  = cpsip*(alpha*k + (1-alpha-nu)*n + nu*en + a)
mc = alpha*rk + (1-alpha-nu)*w + nu*pE - a
en = mc + y/cpsip - pE
k  = w - rk + n
```

Warunki poziomowe wynikają z minimalizacji `W*N + RK*K + PE*En` przy zadanym X:
`W/PD = MC*(1-alpha-nu)*X/N`, `RK/PD = MC*alpha*X/K`, `PE/PD = MC*nu*X/En`.
Energia wpływa na inflację przez koszt krańcowy w równaniu Calvo; oryginalny szok marży cenowej pozostaje osobnym szokiem.

### Konsumpcja i ceny

Znormalizowany agregator Cobb-Douglasa:
`C=(CN/(1-omegaE))^(1-omegaE)*(CE/omegaE)^omegaE`.
Indeks cen: `PC=PD^(1-omegaE)*PE^omegaE`.

```text
pc = omegaE*pE
cn = c + pc
ce = c + pc - pE
piC = pi + pc - pc(-1)
piE = pi + pE - pE(-1)
wc = w - pc
```

Euler konsumpcji wykorzystuje `r-piC(+1)`. Blok podaży pracy/płac używa płacy w jednostkach koszyka konsumpcji `wc`. Wycena kapitału pozostaje w jednostkach dobra krajowego, więc wykorzystuje `r-pi(+1)`. W bloku elastycznym `rf` jest stopą realną w jednostkach konsumpcji, a wycena kapitału uwzględnia `rf+pc(+1)-pc`. Nie można bez tej korekty użyć starego równania qf.

### Bilans zasobów i PKB

W poziomach `M=En+CE`, `PD*Exports=PE*M`, `Y=CN+I+G+UtilizationCost+Exports`.
Płatności za energię trafiają za granicę; nie są krajowymi zyskami firm energetycznych. W modelu nie ma krajowego sektora wydobycia energii.

`y` to produkcja krajowa przed odjęciem importowanego nakładu pośredniego. Realny PKB liczymy przez podwójną deflację, tj. odejmując zmianę ilości energii firm według cen bazowych:

```text
gdp = (y - sEn*en)/(1-sEn)
ygap = gdp - gdpf
```

Nie odejmujemy ponownie konsumpcyjnej energii importowanej od y; nie należała do krajowej produkcji. Nie odejmujemy też `pE` w równaniu realnego PKB: zmiana ceny importu wpływa na dochód realny i deflator, lecz nie jest zmianą ilości nakładu.

### Stan ustalony i kalibracja

Przy bazowym założeniu zerowych zysków `MC_ss=1/cpsip` oraz `X_ss/Y_ss=cpsip`:

```text
K/Y = alpha/RK
sEn = nu
sGDP = 1-nu
sG = 0.18*sGDP
sI = (tau+delta-1)*K/Y
sC = 1-sI-sG-sEn
sCN = (1-omegaE)*sC
sCE = omegaE*sC
sExports = sEn+sCE
```

Udziały odnoszą się tu do produkcji brutto Y. `nu` jest udziałem energii w kosztach zmiennych oraz elastycznością produkcji. Równość z udziałem wydatków na energię w Y wykorzystuje dodatkowo założenie zerowych zysków i relację kosztów stałych do narzutu. W danych z innymi nakładami pośrednimi trzeba zadbać o zgodny zakres agregacji; nie utożsamiać automatycznie udziału energii w PKB z nu.

Wartości `nu=0.05`, `omegaE=0.10`, `rhoE=0.80`, `sigmaE=10` są WYŁĄCZNIE ilustracyjne. `sigmaE=10` daje skok ceny względnej o 10 log-procent, czyli około 10.52% w poziomach. Chcąc dokładnie 10% wzrostu poziomu, ustaw `csigmaE=100*log(1.10)`. Bazowe parametry odziedziczono z replikacji; nie są to nowe oszacowania modelu energetycznego.

Kalibracja udziałów jest zapisana w `../Calibrations.xlsx` i generowana do `Estimation_Setup/EA20_calibration.mod`. Makra udziałów służą dodatkowo testowi wyłączenia energii. Zmiana parametrów strukturalnych podczas późniejszej estymacji wymaga przeliczania wszystkich zależnych współczynników, np. w pliku steady state lub przez poprawnie zdefiniowane zmienne lokalne modelu. Obecny blok przypisań służy kalibracji i symulacji; nie należy dopisywać `estimated_params` dla alpha/nu/omegaE bez tej przebudowy. Sama deklaracja dziewięciu obserwacji nie dowodzi identyfikacji parametrów.

## Jakie dane dodatkowo pobrać

Minimalnie potrzebne są DWA indeksy cen, z których powstaje JEDNA nowa obserwacja `pEobs`:

| Szereg | Zastosowanie | Sposób przygotowania |
|---|---|---|
| HICP energia, poziom indeksu | Licznik ceny względnej energii | Średnia trzech miesięcznych poziomów indeksu w kwartale |
| HICP wszystkie pozycje bez energii, poziom indeksu | Mianownik tej samej ceny względnej | Ta sama częstotliwość, obszar geograficzny i korekta sezonowa |
| HICP ogółem, poziom indeksu | `piobs`: zastępuje deflator PKB, jeśli używano go w bazie | `100*(log(HICP_q)-log(HICP_q(-1)))`, nie r/r i nie razy cztery |
| Waga energii w HICP lub udział wydatków konsumpcyjnych na energię | Kalibracja `comegaE`, nie dodatkowa obserwacja | Stały reprezentatywny udział dla próby; wagę w promilach podziel przez 1000 |
| Tablice podaży i wykorzystania / input-output: energetyczne nakłady firm, produkcja i wartość dodana | Kalibracja `cnu` i kontrola proporcji PKB/produkcja | Roczne dane wystarczą; nie interpolować mechanicznie do kwartalnej obserwacji |

Dokładna transformacja nowej obserwacji:

```text
relative_energy_q = 100*(log(HICP_energy_q)-log(HICP_ex_energy_q))
pEobs = relative_energy_q - mean(relative_energy_q w wybranej próbie)
```

Demeaning odpowiada przyjętemu stacjonarnemu AR(1). Przed estymacją trzeba sprawdzić, czy ta stacjonarność i jeden reżim cenowy są wiarygodne dla wybranej próby, zwłaszcza obejmującej 2021-2023. Zmiana bazy indeksu nie zmienia szeregu po usunięciu średniej. W prognozowaniu poza próbą średnią wyznaczaj tylko na próbie estymacji.

UWAGA: HICP bez energii zawiera żywność. Nie zastępuj go HICP bez energii i żywności. Obecny model ma dwa składniki koszyka, a nie trzy. Jedna cena dobra krajowego jest przybliżana przez HICP bez energii; jest to empiryczny proxy, nie dokładna równość deflatora produkcji i cen detalicznych. Również stałowagowy indeks modelowy przybliża rzeczywisty łańcuchowy HICP ze zmiennymi wagami. Przygotuj i udokumentuj spójny obszar geograficzny (np. stały skład strefy euro), próbę i odsezonowanie cen.

### Obserwacje zachowane z bazy

Aktywne `varobs` to `dyobs dcobs diobs piobs dwobs deobs uobs robs pEobs`.

| Zmienna | Odpowiednik danych |
|---|---|
| `dyobs` | Kwartalny `100*Delta log` realnego PKB, SA/WDA; w modelu gdp zamiast produkcji brutto y |
| `dcobs` | Kwartalny `100*Delta log` realnej konsumpcji gospodarstw; agregat z energią |
| `diobs` | Kwartalny `100*Delta log` realnych inwestycji |
| `piobs` | Kwartalny `100*Delta log` HICP ogółem; BEZ annualizacji |
| `dwobs` | Kwartalny `100*Delta log` nominalnego wynagrodzenia na zatrudnionego |
| `deobs` | Kwartalny `100*Delta log` zatrudnienia |
| `uobs` | Stopa bezrobocia w procentach |
| `robs` | Nominalna stopa polityki w procentach rocznie, średnia kwartalna |
| `pEobs` | Wycentrowany logarytm relacji cen energii i dóbr nieenergetycznych, razy 100 |

Kod zawiera stałe wzrostu, inflacji, bezrobocia i stóp odziedziczone z replikacji. Nie odejmuj ich drugi raz od danych. Ich wartości wymagają dopasowania/estymacji dla nowej próby. Przyjęty wzrost wynagrodzenia jest wzrostem nominalnym na zatrudnionego; jeśli stara baza zawiera inny szereg, przekształć go lub zmień równanie pomiarowe. Poprawiono w tej wersji tożsamość płacy nominalnej na `dwobs=ctaubar+Delta w+cpibar+pi`; bazowy zapis używał efektywnie opóźnionej inflacji.

`piDobs` oraz `piEobs` są tylko wielkościami diagnostycznymi. Nie dodawaj automatycznie wszystkich trzech inflacji i pEobs do `varobs`: wiążą je dokładne tożsamości modelowe. Więcej obserwacji wymaga przemyślenia identyfikacji, dodatkowych mechanizmów lub uzasadnionych błędów pomiaru.

### Dane przydatne później, lecz nie obowiązkowe w tej wersji

Importowy indeks cen energii, ceny gazu/ropy w EUR oraz ceny energii dla przedsiębiorstw pozwolą ocenić, czy wspólna cena dla firm i konsumentów jest rozsądnym przybliżeniem. NIE podłączaj ich równocześnie z HICP energia jako niezależnych dokładnych obserwacji jednej ceny. Rozbieżności mogą wymagać sektora detalicznego, podatków lub mechanizmu przenoszenia cen. Wolumeny zużycia energii firm i gospodarstw są przydatne do oceny elastyczności i weryfikacji modelu, ale nie są obowiązkowymi obserwacjami tej kalibracji.

## Oficjalne źródła danych

Sprawdzone 19 września 2026. Od 2026 Eurostat udostępnia nową klasyfikację HICP ECOICOP v2; sprawdź pokrycie historyczne i nie łącz bez kontroli klasyfikacji dwóch eksportów danych.

- Indeksy HICP i stopy zmian: https://ec.europa.eu/eurostat/databrowser/view/prc_hicp_minr/default/table?lang=en
- Wagi HICP: https://ec.europa.eu/eurostat/databrowser/view/prc_hicp_iw/default/table?lang=en
- Starsze szeregi HICP: `prc_hicp_midx`, starsze wagi: `prc_hicp_inw` (archiwalne pokrycie do 2025; sprawdzić zakres wybranego eksportu).
- Metodyka i agregacja HICP: https://ec.europa.eu/eurostat/web/hicp/methodology/
- Tablice podaży i wykorzystania oraz FIGARO: https://ec.europa.eu/eurostat/web/esa-supply-use-input-tables/database
- Importowe ceny przemysłowe, opcjonalnie: https://ec.europa.eu/eurostat/databrowser/view/sts_inpi_m/default/table?lang=en

## Weryfikacja

`steady`, `check`, `model_diagnostics` i symulacja pierwszego rzędu sprawdzają lokalne rozwiązanie dla zadanej kalibracji. `step_2_validate_model.m` dodatkowo sprawdza bilans zasobów, warunek popytu na energię, agregację inflacji, PKB i normalizację impulsu. Następnie porównuje IRF 39 zmiennych na osiem oryginalnych szoków z bazową replikacją po ustawieniu obu udziałów energii na zero. Równanie `dwobs` jest wyłączone z porównania z powodu jawnej korekty tożsamości pomiarowej. Wynik jest zapisywany w `walidacja/validation_report.txt`.

Przejście tych testów nie oznacza estymacji, walidacji empirycznej ani potwierdzenia, że model odtworzy dekompozycję inflacji z artykułu. Do tego potrzebne są dane, docelowa kalibracja, priory, sprawdzenie identyfikacji i nowa estymacja.

### Wynik wykonanego testu 19 września 2026

MATLAB R2025b / Dynare 7.2: model został rozwiązany, warunki rzędu i rangi Blancharda–Kahna są spełnione (14 niestabilnych pierwiastków i 14 zmiennych wyprzedzających). `model_diagnostics` nie wykrył oczywistych problemów. Testy tożsamości i skończoności IRF przeszły. Maksymalna różnica względem bazowej replikacji po wyłączeniu energii wynosiła 1.8785e-13 (39 zmiennych, 8 szoków).

Przy ilustracyjnym wzroście realnej ceny energii o 10 log-procent reakcje w pierwszym kwartale wynoszą: konsumpcja -0.6414 log-procent, energia firm -9.2292 log-procent, inflacja konsumpcyjna +1.0196 pp kwartalnie, inflacja krajowa +0.0196 pp kwartalnie, realny PKB +0.7702 log-procent. To NIE jest oszacowanie historycznej kontrybucji energii.

Dodatnia reakcja PKB jest istotnym wynikiem tej specyfikacji, nie założonym celem. Cobb–Douglas umożliwia substytucję energii z jednostkową elastycznością, przyjęty bilans handlowy wiąże eksport z rachunkiem za import, a realny PKB odejmuje importowane nakłady według cen bazowych. Nie należy interpretować wzrostu PKB jako wzrostu dobrobytu: konsumpcja spada. Jeżeli celem empirycznym jest jednoczesny spadek PKB i wzrost inflacji, należy zbadać np. niższą elastyczność substytucji w technologii CES lub bogatszy mechanizm handlu; nie dobierać arbitralnie znaku szoku ani nie przedstawiać obecnych IRF jako potwierdzenia stagflacji.
## Układ katalogów po reorganizacji

Wspólne dane i skrypty R są w ../data. Wyniki sprzed reorganizacji zachowano w wyniki_historyczne pod oryginalnymi nazwami. Nowe uruchomienie tworzy wyniki pod nazwą sww_energia_w_produkcji. Raport z 19.09.2026 powyżej opisuje wcześniejszy test; reorganizacja nie zmienia równań ani kalibracji.


## Źródło kalibracji po modularizacji

Edytuj `../Calibrations.xlsx`, następnie z katalogu głównego uruchom
`./calibration/generate_mod_inputs.ps1 -Country EA20`.
Model dołącza dokładnie trzy pliki `Estimation_Setup/EA20_*.mod`.
Wartości niezależne są w arkuszu, a tożsamości w ../calibration/derived_parameters.py; wygenerowanych modułów nie edytuje się ręcznie.
Metadane LaTeX i etykiety równań są w głównym `.mod`.
Pełna instrukcja: `../calibration/README.md`.



## Estymacja

Aktualną estymację ML przy skalibrowanym `cnu = 0,05` uruchamia
`estymuj.m`. Skrypt wywołuje `diagnostyka.m`; diagnostykę
można też uruchomić osobno na zapisanym wyniku, bez ponownej estymacji.
Wyniki są w `estymacja/` z prefiksem `cnu005`.
Opis: `estymacja/README_cnu005.md`; wynik: `estymacja/cnu005_WYNIKI.md`.
Ostatnia zachowana siatka: `grid_search/runs/run_004`.
