using System.Runtime.CompilerServices;
using static System.Console;

[assembly: InternalsVisibleTo("unit")]

WriteLine($"Hello, World! at {DateTime.Now}");

WaitFor waitFor = new (args);

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

    public WaitFor(string[] args)
    {
        WaitingFor = args.Length > 0 ? TimeSpan.FromMinutes(Double.Parse(args[0])) : TimeSpan.FromMinutes(1);
    }

    internal async Task WaitForIt()
    {
        await Task.Delay(WaitingFor);
    }
}
