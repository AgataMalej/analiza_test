R/cbos_porownania.R
#OSOBA C: zadania 7-8 (CBOS 2017: porównania grup i oczekiwania)
#krypt uruchamia się od początku: pakiety -> odczyt danych -> zadania.
#Pakiety (jeśli brakuje): install.packages(c("dplyr", "tidyr", "haven"))
library(dplyr)
library(tidyr)
library(haven)
#--- Odczyt danych (tak samo jak w instrukcji) --------------------------------
  adres_cbos <- paste0("https://raw.githubusercontent.com/kflisikowsky/sad/",
                       "main/data/CBOS_201733_331_SPSS.sav")
plik_cbos <- tempfile(fileext = ".sav")
download.file(adres_cbos, plik_cbos, mode = "wb", quiet = TRUE)
cbos_raw <- read_sav(plik_cbos)
unlink(plik_cbos)
cbos <- cbos_raw %>% transmute(
  plec = as_factor(plec),
  miejscowosc = as_factor(klm6),
  kierunek = as_factor(q24),
  prognoza = as_factor(q25),
  wyksztalcenie = as_factor(q15)
)
#stopifnot(nrow(cbos_raw) == 925, ncol(cbos_raw) == 189)
#Etykiety z treści zadań
etyk_wies <- "wieś"
etyk_duze <- "miasto 500 000 i więcej"
stopifnot(
  "Brak etykiety 'wieś' - sprawdź levels(cbos$miejscowosc)" =
    etyk_wies %in% levels(cbos$miejscowosc),
  "Brak etykiety 'miasto 500 000 i więcej' - sprawdź levels(cbos$miejscowosc)" =
    etyk_duze %in% levels(cbos$miejscowosc),
  "Brak etykiety 'W złym' - sprawdź levels(cbos$kierunek)" =
    "W złym" %in% levels(cbos$kierunek)
)
#=============================================================================
#  ZADANIE 7 - wieś i duże miasta
#=============================================================================
  cat("
===== ZADANIE 7 =====
")
wies_miasto <- cbos %>%
  filter(miejscowosc %in% c(etyk_wies, etyk_duze), !is.na(kierunek)) %>%
  mutate(miejscowosc = droplevels(miejscowosc))
#Liczebności grup (mianowniki procentów)
liczebnosc <- wies_miasto %>% count(miejscowosc, name = "n_grupy")
cat("Liczba respondentów z ważną odpowiedzią o kierunek w obu grupach:
")
print(liczebnosc)
#Procenty w obrębie grupy (nie w całej tabeli)
tab7 <- wies_miasto %>%
  count(miejscowosc, kierunek) %>%
  group_by(miejscowosc) %>%
  mutate(procent = round(100 * n / sum(n), 1)) %>%
  ungroup()
cat("
Odpowiedzi na pytanie o kierunek, procent w obrębie grupy:
")
print(tab7)
zly <- function(grupa) {
  x <- tab7 %>% filter(miejscowosc == grupa, kierunek == "W złym")
  if (nrow(x) == 0) 0 else x$procent
}
n_grupy <- function(grupa) {
  liczebnosc %>% filter(miejscowosc == grupa) %>% pull(n_grupy)
}
zly_wies <- zly(etyk_wies)
zly_duze <- zly(etyk_duze)
n_wies <- n_grupy(etyk_wies)
n_duze <- n_grupy(etyk_duze)
cat(sprintf(
  paste0("
Udział odpowiedzi 'W złym': wieś %.1f%% (n = %d), miasto 500 tys. ",
         "i więcej %.1f%% (n = %d). Udziały %s takie same (różnica %.1f p.p.). ",
         "Mała liczebność jednej z grup oznacza, że różnicę trzeba ",
         "interpretować ostrożnie.
"),
  zly_wies, n_wies, zly_duze, n_duze,
  ifelse(zly_wies == zly_duze, "są", "nie są"),
  abs(zly_wies - zly_duze)))
#=============================================================================
#  ZADANIE 8 - ocena teraźniejszości a oczekiwania
#=============================================================================
  cat("
===== ZADANIE 8 =====
")
n_prog <- sum(!is.na(cbos$prognoza))
tab_prog <- cbos %>%
  filter(!is.na(prognoza)) %>%
  count(prognoza, sort = TRUE) %>%
  mutate(procent = round(100 * n / sum(n), 1))
cat("Prognoza na kolejny rok, cała próba (mianownik =", n_prog, "):
")
print(tab_prog)
#Tylko osoby oceniające sytuację jako 'W złym'
zly_prog <- cbos %>%
  filter(kierunek == "W złym", !is.na(prognoza)) %>%
  count(prognoza, sort = TRUE)
n_zly <- sum(zly_prog$n)
zly_prog <- zly_prog %>% mutate(procent = round(100 * n / n_zly, 1))
cat("
Prognoza wśród osób oceniających kierunek jako 'W złym' (mianownik =",
    n_zly, "):
")
print(zly_prog)
najcz <- zly_prog %>% slice_head(n = 1)
cat(sprintf(
  paste0("
Najczęstsza odpowiedź w tej grupie: '%s' (%d osób, %.1f%% z %d).
",
         "Wnioski przyczynowe: NIE, to tabela liczności (zestawienie dwóch ",
         "odpowiedzi tych samych osób, w jednym momencie). Nie pokazuje, że ",
         "ocena teraźniejszości powoduje oczekiwania; mogą na obie wpływać ",
         "inne czynniki, np. poglądy polityczne.
"),
  as.character(najcz$prognoza), najcz$n, najcz$procent, n_zly))
#=============================================================================
#  Gotowe wnioski do wnioski.md
#=============================================================================
  cat("
===== WNIOSKI (do wklejenia do wnioski.md) =====
")
cat(sprintf(
  paste0("- Odpowiedź 'W złym' wybrało %.1f%% mieszkańców wsi (n = %d) i %.1f%% ",
         "mieszkańców miast 500 tys. i więcej (n = %d); procenty w obrębie ",
         "grupy, dane z 2017 r., bez ważenia.
"),
  zly_wies, n_wies, zly_duze, n_duze))
cat(sprintf(
  paste0("- Wśród osób oceniających kierunek jako 'W złym' (n = %d) najczęstsza ",
         "prognoza na kolejny rok to '%s' (%.1f%%). To zestawienie opisowe, ",
         "nie dowód przyczynowości.
"),
  n_zly, as.character(najcz$prognoza), najcz$procent))