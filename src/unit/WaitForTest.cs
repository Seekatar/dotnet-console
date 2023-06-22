using System.Diagnostics;
using System.Threading.Tasks;
using Xunit;
using Shouldly;

namespace unit
{
    public class WaitForTest
    {
        [Theory]
        [InlineData(".05")]
        [InlineData(".1")]
        public async Task TestIt(string minutes)
        {
            WaitFor waitFor = new(new string[] { minutes });

            var sw = Stopwatch.StartNew();
            await waitFor.WaitForIt();
            ((double)sw.ElapsedMilliseconds).ShouldBeGreaterThan(waitFor.WaitingFor.TotalMilliseconds - 100);
            ((double)sw.ElapsedMilliseconds).ShouldBeLessThan(waitFor.WaitingFor.TotalMilliseconds + 100);
        }
    }
}