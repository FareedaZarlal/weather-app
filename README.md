# 🌦️ Weather App

A Flutter-based weather application that provides real-time weather information and daily forecasts for different cities. The app includes city search, favorite locations, temperature unit conversion, and offline weather caching for a better user experience.

## 📱 Features

- **Current Weather:** View current temperature and weather conditions.
- **Weather Forecast:** Check upcoming days' weather forecasts.
- **City Search:** Search for weather information by city name.
- **Favorites:** Save and access your favorite cities.
- **Temperature Units:** Switch between Celsius and Fahrenheit.
- **Offline Caching:** View the last successfully saved weather forecast without an internet connection.
- **Error Handling:** Handles invalid city names, network failures, and empty search results.
- **Local Storage:** Saves favorite cities and cached weather data locally.

## 🛠️ Technologies Used

- Flutter
- Dart
- REST API
- JSON
- Shared Preferences
- Material UI

## 📂 Project Structure

```text
lib/
├── core/
│   └── theme.dart
│
├── models/
│   ├── location.dart
│   └── weather_snapshot.dart
│
├── services/
│   ├── storage_service.dart
│   └── weather_service.dart
│
├── state/
│   └── weather_controller.dart
│
├── screens/
│   ├── weather_screen.
│   ├── home_shell.dart
│   ├── search_screen.dart
│   └── favorites_screen.dart
│
├── widgets/
│   ├── weather_glyph.dart
│   └── common.dart
│
├── utils/
│   └── formatters.dart
│
└── app.dart
└── main.dart
```

*Note: This is the main structure; your actual folders and files may vary.*

## 🚀 Getting Started

Follow these steps to run the project locally.

### 1. Clone the Repository

```bash
git clone https://github.com/FareedaZarlal/weather-app.git
```

### 2. Navigate to the Project Folder

```bash
cd weather-app
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Run the Application

Connect an Android emulator or physical device and run:

```bash
flutter run
```

## 🌐 Weather API

The application uses a weather API to retrieve current weather information and forecast data.

An active internet connection is required to fetch new weather information. Previously cached forecasts can still be viewed offline.

## 📡 Offline Functionality

The application uses local storage to cache successfully fetched weather data.

When the internet connection is unavailable:
- Previously cached weather information can still be displayed.
- Favorite cities remain saved.
- Cities without previously cached forecasts display an appropriate message.

## 🧪 Testing

The following scenarios can be tested:

- Search for a valid city.
- Search for an invalid city.
- Add and remove favorite cities.
- Switch between Celsius and Fahrenheit.
- Restart the application and verify saved favorites.
- Enable airplane mode and check cached weather.
- Test cities that have no cached forecast.
- Check error messages when the API is unavailable.

## 🎯 Learning Outcomes

Through this project, I gained practical experience in:

- Flutter application development.
- REST API integration.
- JSON data fetching and parsing.
- State management.
- Local data persistence.
- Offline caching.
- Error handling.
- Building responsive user interfaces.

## 👩‍💻 Developer

**Fareeda Zarlal**
**Mobile App development Intern at stack and scale**
**Computer Software Engineering Student**

GitHub: [@FareedaZarlal](https://github.com/FareedaZarlal)

---

⭐ If you find this project interesting, feel free to explore the repository!
