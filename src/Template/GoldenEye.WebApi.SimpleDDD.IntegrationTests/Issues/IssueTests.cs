using System.Net;
using System.Threading.Tasks;
using FluentAssertions;
using WebApi.SimpleDDD.IntegrationTests.Infrastructure;
using Xunit;

namespace WebApi.SimpleDDD.IntegrationTests.Issues
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
            var response = await _sut.Client.GetAsync("/api/Issues");

            response.EnsureSuccessStatusCode();

            response.StatusCode.Should().Be(HttpStatusCode.OK);
        }
    }
}