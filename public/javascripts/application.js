var camInteration = 0;

function goCam() {
  camInteration += 1;
  
  goWeather();
  
  if (camInteration == 3) {
    loadCam(Date.now());
    goSolar();
    camInteration = 0;
  }
};

function loadCam(cache_bust) {
  image = 'https://dal.objectstorage.open.softlayer.com/v1/AUTH_09efdd634bf5483ebdf24ff6a166db27/weather-cam/weather.jpg?cachebust=' + cache_bust
  $('img.cam-pre-loader').attr('src', image).load(function() {
    $('html').css('background-image', 'url(' + image + ')');
  });  
}

function setCam() {
  goSolar();
  goWeather();
  setInterval(goCam, 10*1000);
}

function goWeather() {
  station = 'KWASEATT457'
  weather_data = jQuery.getJSON('http://stationdata.wunderground.com/cgi-bin/stationlookup?station=' + station + '&units=english&v=2.0&format=json', function(data) {
    wind = data["stations"][station]["wind_speed"]
    gust = data["stations"][station]["wind_gust_speed"]
    wind_dir = data["stations"][station]["wind_dir_degrees"]
    temp = data["stations"][station]["temperature"]
    rain = data["stations"][station]["precip_today"]
    pressure = data["stations"][station]["pressure"]
    
    weather_string = wind + " mph " + translateWind(wind_dir) + " (" + gust + " mph gusts) / " + temp + "&deg; / " + rain + "\" rain"
    if (typeof pressure != 'undefined') {
      weather_string += ' / ' + pressure + '" pres.'
    }
    
    jQuery("div.weather").html(weather_string)
    jQuery("div.weather").effect( "highlight", {color:"#00aed1"}, 300 );
  });
}

function goSolar() {
  jQuery.ajax({
    url : '/solar',
    data: {},
    type: 'GET',
    success: function(data){
      $('div.solar').html(data);
    }
  });
}

function translateWind(wind_dir) {
  wind_dir_language = new Array("N", "NNE", "NE", "ENE","E", "ESE", "SE", "SSE","S", "SSW", "SW", "WSW","W", "WNW", "NW", "NNW");
  calc = wind_dir_language[Math.floor(((parseInt(wind_dir) + 11.25) / 22.5))];
  if (typeof calc === 'undefined') {
    calc = ''
  }
  return calc
}

causeRepaintsOn = $("h1, h2, h3, p");

$(window).resize(function() {
  causeRepaintsOn.css("z-index", 1);
});