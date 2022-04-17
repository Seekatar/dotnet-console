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
        [InlineData(".5")]
        //[InlineData("1")]
        public async Task TestIt(string? arg0)
        {
            WaitFor waitFor = new(new string[] { arg0 });

            var sw = Stopwatch.StartNew();
            await waitFor.WaitForIt();
            ((double)sw.ElapsedMilliseconds).ShouldBeGreaterThan(waitFor.WaitingFor.TotalMilliseconds);
            ((double)sw.ElapsedMilliseconds).ShouldBeLessThan(waitFor.WaitingFor.TotalMilliseconds + 20);
        }
    }
}