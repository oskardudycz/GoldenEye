using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Threading.Tasks;
using FluentAssertions;
using GoldenEye.Shared.Core.Extensions.Serialization;
using GoldenEye.WebApi.Template.SimpleDDD.Contracts.Issues;
using GoldenEye.WebApi.Template.SimpleDDD.Contracts.Issues.Commands;
using GoldenEye.WebApi.Template.SimpleDDD.Contracts.Issues.Views;
using WebApi.SimpleDDD.IntegrationTests.Infrastructure;
using Xunit;

namespace WebApi.SimpleDDD.IntegrationTests.Issues
{
    public class IssueTests
    {
        public IssueTests()
        {
            _sut = new TestContext();
        }

        private readonly TestContext _sut;

        private async Task<IReadOnlyList<IssueView>> GetIssues()
        {
            var response = await _sut.Client.GetAsync("/api/Issues");
            response.EnsureSuccessStatusCode();

            var json = await response.Content.ReadAsStringAsync();
            return json.FromJson<IReadOnlyList<IssueView>>();
        }

        private async Task<IssueView> GetIssue(Guid id)
        {
            var response = await _sut.Client.GetAsync($"/api/Issues/{id}");

            response.EnsureSuccessStatusCode();
            response.StatusCode.Should().Be(HttpStatusCode.OK);

            var json = await response.Content.ReadAsStringAsync();
            return json.FromJson<IssueView>();
        }

        private async Task<IssueView> CreateIssue(CreateIssue command, int previousCount)
        {
            var response = await _sut.Client.PostAsync("/api/Issues", command.ToJsonStringContent());
            response.EnsureSuccessStatusCode();
            response.StatusCode.Should().Be(HttpStatusCode.OK);

            var issues = await GetIssues();

            issues.Count.Should().Be(previousCount + 1);

            var issue = issues.Last();

            issue.Id.Should().NotBeEmpty();
            issue.Type.Should().Be(command.Type);
            issue.Title.Should().Be(command.Title);
            issue.Description.Should().Be(command.Description);

            return issue;
        }

        private async Task<IssueView> UpdateIssue(UpdateIssue command)
        {
            var response = await _sut.Client.PutAsync($"/api/Issues/{command.Id}", command.ToJsonStringContent());
            response.EnsureSuccessStatusCode();
            response.StatusCode.Should().Be(HttpStatusCode.OK);

            var issue = await GetIssue(command.Id);

            issue.Should().NotBeNull();
            issue.Id.Should().Be(command.Id);
            issue.Type.Should().Be(command.Type);
            issue.Title.Should().Be(command.Title);
            issue.Description.Should().Be(command.Description);

            return issue;
        }

        private async Task DeleteIssue(Guid id)
        {
            var response = await _sut.Client.DeleteAsync($"/api/Issues/{id}");

            response.EnsureSuccessStatusCode();
            response.StatusCode.Should().Be(HttpStatusCode.OK);

            var issues = await GetIssues();

            issues.Any(i => i.Id == id).Should().BeFalse();
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
        public async Task DeleteIssueWithNotValidData_ShouldReturnBadRequest()
        {
            var id = Guid.Empty;

            var response = await _sut.Client.DeleteAsync($"/api/Issues/{id}");

            response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        }

        [Fact]
        public async Task GetIssueWithNotValidData_ShouldReturnBadRequest()
        {
            var id = Guid.Empty;

            var response = await _sut.Client.GetAsync($"/api/Issues/{id}");

            response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
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

            //Delete
            await DeleteIssue(createdIssue.Id);
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
    }
}
