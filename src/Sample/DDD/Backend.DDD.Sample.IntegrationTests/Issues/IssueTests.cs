using System.Net;
using System.Threading.Tasks;
using Backend.DDD.Sample.IntegrationTests.Infrastructure;
using FluentAssertions;
using Xunit;

namespace Backend.DDD.Sample.IntegrationTests.Issues
{
    public class IssueTests
    {
        private readonly TestContext _sut;

        public IssueTests()
        {
            _sut = new TestContext();
        }

        [Fact]
        public async Task IssueFlowTests()
        {
            var response = await _sut.Client.GetAsync("/issues");

            response.EnsureSuccessStatusCode();

            response.StatusCode.Should().Be(HttpStatusCode.OK);
        }
    }
}