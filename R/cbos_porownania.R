library(dplyr)
library(tidyr)

adres_nieruchomosci <- paste0(
  "https://raw.githubusercontent.com/kflisikowsky/pandas_exercises/",
  "62863036107888c0c7273c40e8d309a43f4da3a9/data/models/real_estate.csv"
)
raw_nier <- read.csv(adres_nieruchomosci, check.names = FALSE)
stopifnot(nrow(raw_nier) == 414, ncol(raw_nier) == 7)

nier <- raw_nier
names(nier) <- c("id", "wiek_lat", "metro_m", "sklepy", "lat", "lon",
                 "cena_10k_twd_ping")
head(nier)

### Zadanie 7 — wieś i duże miasta

#Wybierz respondentów z kategorii `miejscowosc` równych `"wieś"` i `"miasto 500 000 i więcej"`. Dla każdej z tych dwóch grup policz **procent** odpowiedzi na pytanie `kierunek` (procent w obrębie grupy, nie w całej tabeli). Czy udział odpowiedzi „W złym” był taki sam?
  
 # Sprawdź liczbę respondentów w obu grupach. Samo porównanie procentów bez liczebności może być mylące.



# WASZE ROZWIĄZANIE
# filter(...), count(miejscowosc, kierunek), group_by(miejscowosc)

### Zadanie 8 — ocena teraźniejszości a oczekiwania

#Zrób tabelę liczności odpowiedzi na `prognoza`. Następnie ogranicz dane do osób oceniających sytuację w kraju jako `"W złym"` i sprawdź, jak odpowiadały na pytanie o przyszłość. Która odpowiedź była najczęstsza w tej grupie? Czy na podstawie tej tabeli można wyciągać wnioski przyczynowe?
  
# WASZE ROZWIĄZANIE
# filter(kierunek == "W złym"), count(prognoza, sort = TRUE)

#**Uwaga do interpretacji.** Dane pochodzą z roku 2017. Obliczenia na surowych rekordach są ćwiczeniem analitycznym. Nie przedstawiajcie ich jako współczesnych opinii Polaków ani jako reprezentatywnych oszacowań bez sprawdzenia dokumentacji i ewentualnego ważenia próby.
