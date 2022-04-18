using System.Runtime.CompilerServices;

[assembly: InternalsVisibleTo("unit")]

Console.WriteLine($"Hello, World! at {DateTime.Now}");

WaitFor waitFor = new (args);

Console.WriteLine($"Waiting for {waitFor.WaitingFor.TotalMinutes} minutes!");

await waitFor.WaitForIt();

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
