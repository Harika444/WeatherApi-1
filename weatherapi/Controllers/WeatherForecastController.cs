using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace weatherapi.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class WeatherForecastController : ControllerBase
    {
        private static readonly string[] Summaries = new[]
        {
            "cold", "humid", "sunny", "rainy"
        };

        private readonly ILogger<WeatherForecastController> _logger;

        public WeatherForecastController(ILogger<WeatherForecastController> logger)
        {
            _logger = logger;
        }

        [HttpGet]
        public IEnumerable<WeatherForecast> Get()
        {
            var user = Environment.GetEnvironmentVariable("SQL_USERNAME");
            var password = Environment.GetEnvironmentVariable("SQL_PASSWORD");
            var db_url = Environment.GetEnvironmentVariable("SQL_DB_URL");
            var topic = Environment.GetEnvironmentVariable("TOPIC");
            var rng = new Random();
            return Enumerable.Range(1, 5).Select(index => new WeatherForecast
            {
                Date = DateTime.Now.AddDays(index),
                TemperatureC = rng.Next(-20, 55),                
                Summary = Summaries[rng.Next(Summaries.Length)],
                User = user,
                Password = password,
                DB_Url = db_url,
                Topic = topic
                
            })
            .ToArray();
        }
    }
}
