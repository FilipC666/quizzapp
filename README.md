# QuizApp - aplikacja quizowa napisana we Flutterze. Pozwala na rozwiązywanie quizów z różnych kategorii, a pytania są pobierane na bieżąco z darmowego API (Open Trivia Database).

## Co znajdziesz w aplikacji? (4 ekrany)

1. **Ekran Główny:** Lista kategorii (np. Nauka, Geografia, Historia) w formie kolorowych kafelków. Zaimplementowałem tutaj opcję **Pull-to-Refresh** – wystarczy pociągnąć ekran w dół, żeby ręcznie odświeżyć kategorie z API.
2. **Ekran Quizu:** Tutaj odpowiadasz na pytania. Jest ładny pasek postępu, który pokazuje, na którym pytaniu akurat jesteś, a po zakończeniu wyskakuje okienko z Twoim końcowym wynikiem.
3. **Ustawienia:** Możesz tutaj zmienić poziom trudności pytań (Easy, Medium, Hard) oraz włączyć/wyłączyć **Dark Mode** (tryb ciemny).
4. **Statystyki:** Ekran zrobiony za pomocą paczki `fl_chart`. Pokazuje ładny, czytelny wykres kołowy (ile pytań ogółem zaznaczyłeś dobrze, a ile źle) oraz całą historię Twoich wcześniejszych gier.

---

##  Funkcje techniczne pod maską

* **Działanie bez internetu (Offline):** Nawet jak odłączysz WiFi, aplikacja uruchomi się normalnie! Kategorie zapisują się w pamięci telefonu dzięki lokalnej bazie **Hive**.
* **Zarządzanie stanem:** Użyłem pakietu `Provider`, żeby aplikacja płynnie reagowała np. na zmianę motywu w ustawieniach.
* **Obsługa błędów:** Jeśli API nie odpowie albo padnie internet, aplikacja nie wywali błędu do pulpitu – użytkownik dostanie jasny komunikat na ekranie, a gra przejdzie w tryb offline.

---

##  Podpięte usługi Firebase

Zgodnie z wymaganiami, w projekcie działają dwie usługi od Google:
1. **Firebase Crashlytics:** Pilnuje stabilności aplikacji i wysyła raporty, jeśli w kodzie pojawiłby się jakiś krytyczny błąd.
2. **Firebase Analytics:** Zbiera podstawowe statystyki. Skonfigurowałem dokładnie 3 eventy (zdarzenia):
    * `quiz_started` – kiedy gracz odpala dany quiz.
    * `quiz_completed` – kiedy kończy odpowiadać i zapisuje wynik.
    * `category_refreshed` – kiedy ręcznie odświeża listę kategorii na ekranie głównym.

---

##  Jak to uruchomić?

1. Pobierz paczki komendą w terminalu:
```bash
   flutter pub get