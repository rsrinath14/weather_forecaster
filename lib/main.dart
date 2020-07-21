import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(WeatherApp());

class WeatherApp extends StatefulWidget {
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  int temperature;
  int woeid = 2487956;
  String location = 'San Francisco';
  String weather = 'clear';
  String abbreviation = '';
  String errormessage = '';

  String searchApiUrl =
      "https://www.metaweather.com/api/location/search/?query=";
  String locationApiUrl = "https://www.metaweather.com/api/location/";

  @override
  void initState() {
    super.initState();
    fetchLocation();
  }

  void fetchSearch(String input) async {
    try {
      var searchResult = await http.get(searchApiUrl + input);
      var result = json.decode(searchResult.body)[0];

      setState(() {
        location = result["title"];
        woeid = result["woeid"];
        errormessage = '';
      });
    } catch (error) {
      setState(() {
        errormessage = "Sorry,Information about this city is not available";
      });
    }
  }

  void fetchLocation() async {
    var locationResult = await http.get(locationApiUrl + woeid.toString());
    var result = json.decode(locationResult.body);
    var consolidatedWeather = result["consolidated_weather"];
    var data = consolidatedWeather[0];

    setState(() {
      temperature = data["the_temp"].round();
      weather = data["weather_state_name"].replaceAll(' ', '').toLowerCase();
      abbreviation = data["weather_state_abbr"];
    });
  }

  void onTextFieldSubmitted(String input) async {
    await fetchSearch(input);
    await fetchLocation();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/$weather.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: temperature == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Scaffold(
                backgroundColor: Colors.transparent,
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Center(
                          child: Image.network(
                              "https://www.metaweather.com/static/img/weather/png/" +
                                  abbreviation +
                                  ".png",
                              width: 100),
                        ),
                        Center(
                            child: Text(temperature.toString() + '°C',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 70,
                                ))),
                        Center(
                          child: Text(
                            location.toString(),
                            style: TextStyle(color: Colors.white, fontSize: 45),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Container(
                          width: 300,
                          child: TextField(
                            onSubmitted: (String input) {
                              onTextFieldSubmitted(input);
                            },
                            style: TextStyle(color: Colors.white, fontSize: 28),
                            decoration: InputDecoration(
                              hintText: "Search another location...",
                              hintStyle:
                                  TextStyle(color: Colors.white, fontSize: 20),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          errormessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
