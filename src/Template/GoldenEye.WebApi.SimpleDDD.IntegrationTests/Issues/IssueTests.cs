using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Threading.Tasks;
using Contracts.Issues;
using Contracts.Issues.Commands;
using Contracts.Issues.Views;
using FluentAssertions;
using GoldenEye.Shared.Core.Extensions.Serialization;
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
        public async Task IssueCRUDTest()
        {
            //Read
            var initCount = (await GetIssues()).Count;

            //Create
            var createCommand = new CreateIssue(
                IssueType.Task,
                "Check Create Task",
                "Task should be created after running command"
            );

            var createdIssue = await CreateIssue(createCommand, initCount);

            //Update
            var updateCommand = new UpdateIssue(
                createdIssue.Id,
                IssueType.Task,
                "Check Update Task",
                "Task should be update after running command"
            );

            await UpdateIssue(updateCommand);
        }

        private async Task<IReadOnlyList<IssueView>> GetIssues()
        {
            var response = await _sut.Client.GetAsync("/api/Issues");
            response.EnsureSuccessStatusCode();

            var stringGet = await response.Content.ReadAsStringAsync();
            return stringGet.FromJson<IReadOnlyList<IssueView>>();
        }

        private async Task<IssueView> CreateIssue(CreateIssue command, int previousCount)
        {
            var responsePost = await _sut.Client.PostAsync("/api/Issues", command.ToJsonStringContent());
            responsePost.EnsureSuccessStatusCode();
            responsePost.StatusCode.Should().Be(HttpStatusCode.OK);

            var afterPost = await GetIssues();

            afterPost.Count.Should().Be(previousCount + 1);

            return afterPost.Last();
        }

        private async Task<IssueView> UpdateIssue(UpdateIssue command)
        {
            var responsePost = await _sut.Client.PutAsync($"/api/Issues/{command.Id}", command.ToJsonStringContent());
            responsePost.EnsureSuccessStatusCode();
            responsePost.StatusCode.Should().Be(HttpStatusCode.OK);

            var afterPut = await GetIssues();

            afterPut.Any(i => i.Id == command.Id).Should().BeTrue();

            var issue = afterPut.Single(i => i.Id == command.Id);

            issue.Title.Should().Be(command.Title);
            issue.Type.Should().Be(command.Type);

            return issue;
        }
    }
}