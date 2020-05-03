using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using GoldenEye.Backend.Core.DDD.Commands;
using GoldenEye.Backend.Core.DDD.Queries;
using GoldenEye.WebApi.Template.SimpleDDD.Contracts.Issues.Commands;
using GoldenEye.WebApi.Template.SimpleDDD.Contracts.Issues.Queries;
using GoldenEye.WebApi.Template.SimpleDDD.Contracts.Issues.Views;
using Microsoft.AspNetCore.Mvc;

namespace GoldenEye.WebApi.Template.SimpleDDD.Controllers
{
    [Route("api/[controller]")]
    public class IssuesController: Controller
    {
        private readonly ICommandBus commandBus;
        private readonly IQueryBus queryBus;

        public IssuesController(IQueryBus queryBus,
            ICommandBus commandBus)
        {
            this.queryBus = queryBus ?? throw new ArgumentException(nameof(queryBus));
            this.commandBus = commandBus ?? throw new ArgumentException(nameof(commandBus));
        }

        // GET api/issues
        [HttpGet]
        public Task<IReadOnlyList<IssueView>> Get(GetIssues query)
        {
            return queryBus.SendAsync<GetIssues, IReadOnlyList<IssueView>>(query);
        }

        // GET api/issues
        [HttpGet("{id}")]
        public async Task<IssueView> Get([FromRoute] Guid id)
        {
            return await queryBus.SendAsync<GetIssue, IssueView>(new GetIssue(id));
        }

        // POST api/issues
        [HttpPost]
        public async Task<IActionResult> Post([FromBody] CreateIssue command)
        {
            await commandBus.SendAsync(command);

            return Ok();
        }

        // PUT api/issues
        [HttpPut("{id}")]
        public async Task<IActionResult> Put([FromBody] UpdateIssue command)
        {
            await commandBus.SendAsync(command);

            return Ok();
        }

        // PUT api/issues
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete([FromRoute] Guid id)
        {
            await commandBus.SendAsync(new DeleteIssue(id));

            return Ok();
        }
    }
}
