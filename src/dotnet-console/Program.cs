using System.Runtime.CompilerServices;
using Microsoft.Extensions.Configuration;
using static System.Console;

[assembly: InternalsVisibleTo("unit")]

Environment.SetEnvironmentVariable("NETCORE_ENVIRONMENT", "Development");
Environment.SetEnvironmentVariable("DOTNET_ENVIRONMENT", "Development");
var configuration = new ConfigurationBuilder()
    .AddJsonFile("appsettings.json", optional: true, reloadOnChange: true)
    .AddJsonFile($"appsettings.{Environment.GetEnvironmentVariable("DOTNET_ENVIRONMENT")}.json", optional: true)
    .AddEnvironmentVariables()
    .Build();

var time = float.TryParse(configuration["Time"], out var timeValue) ? timeValue : 1.0f;

WriteLine($"Hello, World! at {DateTime.Now}. Will wait for {time} minutes.");

WaitFor waitFor = new (time);

WriteLine($"Waiting for {waitFor.WaitingFor.TotalMinutes} minutes!");

// create a timer to log a message every 3 seconds to show the app is still running.
var timer = new System.Timers.Timer(TimeSpan.FromSeconds(3).TotalMilliseconds);
timer.Elapsed += (sender, e) => WriteLine($"Still waiting at {DateTime.Now}");
timer.Start();

await waitFor.WaitForIt();

WriteLine("All done!");

// stupid little class added for testing.
internal class WaitFor
{
    public TimeSpan WaitingFor { get; init; }

    public WaitFor(double time)
    {
        WaitingFor = TimeSpan.FromMinutes(time);
    }

    internal async Task WaitForIt()
    {
        await Task.Delay(WaitingFor);
    }
}
