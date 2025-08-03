import 'dart:convert';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'additional_Info_Items.dart';
import 'hourly_forecast_item.dart';
import 'package:http/http.dart' as http;
import 'secret_api.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  TextEditingController _cityController = TextEditingController(text: 'Pune');
  late Future<Map<String, dynamic>> weather;

  Future<Map<String, dynamic>> getCurrentWeather(String cityName) async {
    try {
      final res = await http.get(Uri.parse(
        'http://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey',
      ));
      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw 'City not found or API error';
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather(_cityController.text);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text('Weather App',style: TextStyle(fontWeight: FontWeight.bold),)),
       actions: [
         IconButton(onPressed: (){
           setState(() {

           });
         }, icon: Icon(Icons.refresh))
       ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context,snapshot) {
          print(snapshot);
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator.adaptive());
          }else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data available'));
          }

          final data = snapshot.data!;

          final currentWeatherData = data['list'][0];
          final currentTemp = currentWeatherData['main']['temp'];
          final currentSky = currentWeatherData['weather'][0]['main'];
          final currentHumidity = currentWeatherData['main']['humidity'];
          final currentWindspeed= currentWeatherData['wind']['speed'];
          final currentPressure = currentWeatherData['main']['pressure'];

          final currentTempCelsius = (currentTemp - 273.15).toStringAsFixed(1);

          return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        hintText: 'Enter city name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        weather = getCurrentWeather(_cityController.text);
                      });
                    },
                    child: Text('Search'),
                  ),
                ],
              ),
              SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)
                  ),
                  child: ClipRRect(
                     borderRadius: BorderRadius.circular(16) ,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10,sigmaY: 10,),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [

                        Text("$currentTempCelsius °C",
                          style: TextStyle(fontSize: 32,
                              fontWeight: FontWeight.bold),
                        ),

                      SizedBox(height: 10,),

                            Icon(currentSky == 'Clouds'|| currentSky == 'Rain'
                                ?Icons.cloud
                                :Icons.sunny,
                              size: 64,),

                            SizedBox(height: 10,),

                            Text(currentSky,style: TextStyle(fontSize: 24),)
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20,),

              Text("Weather Forecast",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 10,),

              SizedBox(
                height: 150,

                child: ListView.builder(
                    itemCount:6,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context,index) {
                      final hourlyForecast = data ['list'][index+1];
                      final hourlytemp = double.parse(hourlyForecast['main']['temp'].toString());
                      final hourlyTempCelsius = (hourlytemp - 273.15).toStringAsFixed(1);
                      final time = DateTime.parse(hourlyForecast['dt_txt']);
                      return HourlyForecastItem(

                          time: DateFormat.Hm().format(time),

                        icon: hourlyForecast['weather'][0]['main'] == 'Clouds'
                            ||
                            hourlyForecast['weather'][0]['main'] == 'Rain'
                            ? Icons.cloud
                            : Icons.sunny,

                        temp: '$hourlyTempCelsius °C',
                      );

                    }),
              ),

              SizedBox(height: 20,),

          Text("Additional Information",
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold),
          ),
              SizedBox(height: 10,),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AdditionalInfoItems(
                    icon: Icons.water_drop,
                    label: 'Humidity',
                    value: currentHumidity.toString(),
                  ),
                  AdditionalInfoItems(
                    icon: Icons.air,
                    label: 'Wind Speed',
                    value: currentWindspeed.toString(),
                  ),
                  AdditionalInfoItems(
                    icon: Icons.beach_access,
                    label: 'Pressure',
                    value: currentPressure.toString(),
                  ),
                ],

              )

            ],
          ),
        );
        },
      ),
    );
  }
  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

}



