using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using Contracts.Issues;
using Contracts.Issues.Commands;
using Contracts.Issues.Queries;
using Contracts.Issues.Views;
using FluentAssertions;
using Newtonsoft.Json;
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

        [Fact]
        public async Task IssueCRUTests()
        {
            var initGet = await GetIssues();
            var data = new CreateIssue(IssueType.Task, "IntegrationTest", "IntegrationTestDescription");
            var post =new StringContent(JsonConvert.SerializeObject(data), Encoding.UTF8, "application/json");

            var responsePost = await _sut.Client.PostAsync("/api/Issues", post);

            responsePost.EnsureSuccessStatusCode();

            responsePost.StatusCode.Should().Be(HttpStatusCode.OK);

            var afterPost = await GetIssues();
            Assert.Equal(initGet.Count+1, afterPost.Count);


        }
        private async Task<IReadOnlyList<IssueView>>  GetIssues()
        {
            var response = await _sut.Client.GetAsync("/api/Issues");
            response.EnsureSuccessStatusCode();
            var stringGet = await response.Content.ReadAsStringAsync();
            var getResult = JsonConvert.DeserializeObject<IReadOnlyList<IssueView>>(stringGet);
            return getResult;
        }
    }
}