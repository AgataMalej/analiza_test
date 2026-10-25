#| B | `R/cbos_opis.R` | zadania 5–6 |
install.packages(c("dplyr", "tidyr", "haven"))


#Źródło: [Real Estate Valuation (UCI)](https://archive.ics.uci.edu/dataset/477/real+estate+valuation+data+set), [plik CSV w repozytorium prowadzącego](https://github.com/kflisikowsky/pandas_exercises/blob/62863036107888c0c7273c40e8d309a43f4da3a9/data/models/real_estate.csv). To **414 historycznych obserwacji** z rynku nieruchomości w New Taipei (Tajwan). Zmienna ceny oznacza 10 000 TWD za ping, a nie cenę całej nieruchomości. Przyjmujemy 1 ping ≈ 3,3 m².

{r nieruchomosci-dane}
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
```


#| Zmienna | Znaczenie |
# |:--|:--|
#| `wiek_lat` | wiek budynku w latach |
#  | `metro_m` | odległość do najbliższej stacji MRT w metrach |
#| `sklepy` | liczba sklepów w otoczeniu |
# | `lat`, `lon` | współrzędne geograficzne |
# | `cena_10k_twd_ping` | cena jednostkowa w 10 000 TWD/ping |

```
### Zadanie 4 — wiek, odległość i sklepy

Podziel obserwacje na trzy strefy odległości od metra: **do 500 m**, **powyżej 500 do 1500 m**, **powyżej 1500 m**. Dla każdej strefy oblicz liczbę obserwacji, medianę ceny TWD/m², medianę wieku i średnią liczbę sklepów.

Następnie sprawdź, czy wśród budynków w wieku najwyżej 20 lat ranking median stref pozostaje taki sam. Dlaczego porównanie wszystkich budynków może różnić się od porównania budynków młodszych?
  
  ```{r nier-strefy-przyklad}
# Przykład tworzenia zmiennej grupującej
nier <- nier %>% mutate(
  strefa = cut(metro_m, c(-Inf, 500, 1500, Inf),
               labels = c("do 500 m", "500–1500 m", "ponad 1500 m")))

nier %>%
  group_by(strefa) %>%
  summarise(
    mediana_sklepow = median(sklepy, na.rm = TRUE)) %>%
  arrange(desc(mediana_sklepow))

# Budynki w wieku maksymalnie 20 lat

nier %>%
  filter(wiek_lat <= 20) %>%
  group_by(strefa) %>%
  summarise(
    mediana_sklepow = median(sklepy, na.rm = TRUE)
  ) %>%
  arrange(desc(mediana_sklepow))


```
