
# OpenWeather

A Simple weather app made using OpenWeatherMap API for current weather conditions. Users can search weather conditions by city name or by tapping the location button to use their current location for fetching weather.

This app is made as a part of my [iOS Developer Portfolio](https://viktormauzer.github.io).



## Installation

Clone this repository and run in Xcode.
    
## API key

To run this project, you will need to generate your own API Key from [openweathermap.org](https://openweathermap.org) (it's completely free to try and generate your own key). 

Once successfully generating your API Key from openweathermap.org, to make the app work, you will need to create a new swift file with a struct like this:

```
struct APISecret {
    static let key = "[YOUR_API_KEY]"
}
```

Change the [YOUR_API_KEY] with your actual key.
## Screenshots

![App Screenshot](https://viktormauzer.github.io/img/open-weather/clear.png)
![App Screenshot](https://viktormauzer.github.io/img/open-weather/clouds.png)
