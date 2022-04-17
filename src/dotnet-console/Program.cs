Console.WriteLine($"Hello, World! at {DateTime.Now}");

Console.WriteLine("Waiting for a day!");

await Task.Delay(TimeSpan.FromDays(1));
