using System;
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

        [Fact]
        public async Task CreateIssueWithNotValidData_ShouldReturnBadRequest()
        {
            var command = new UpdateIssue(
                Guid.Empty,
                IssueType.Task,
                null,
                null
            );

            var response = await _sut.Client.PutAsync($"/api/Issues/{command.Id}", command.ToJsonStringContent());

            response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        }

        [Fact]
        public async Task UpdateIssueWithNotValidData_ShouldReturnBadRequest()
        {
            var command = new CreateIssue(
                IssueType.Task,
                null,
                null
            );

            var response = await _sut.Client.PostAsync("/api/Issues", command.ToJsonStringContent());

            response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
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
            var response = await _sut.Client.PostAsync("/api/Issues", command.ToJsonStringContent());
            response.EnsureSuccessStatusCode();
            response.StatusCode.Should().Be(HttpStatusCode.OK);

            var issues = await GetIssues();

            issues.Count.Should().Be(previousCount + 1);

            return issues.Last();
        }

        private async Task<IssueView> UpdateIssue(UpdateIssue command)
        {
            var response = await _sut.Client.PutAsync($"/api/Issues/{command.Id}", command.ToJsonStringContent());
            response.EnsureSuccessStatusCode();
            response.StatusCode.Should().Be(HttpStatusCode.OK);

            var issues = await GetIssues();

            issues.Any(i => i.Id == command.Id).Should().BeTrue();

            var issue = issues.Single(i => i.Id == command.Id);

            issue.Title.Should().Be(command.Title);
            issue.Type.Should().Be(command.Type);

            return issue;
        }
    }
}