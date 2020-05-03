using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Backend.DDD.Sample.Contracts.Issues.Commands;
using Backend.DDD.Sample.Contracts.Issues.Queries;
using Backend.DDD.Sample.Contracts.Issues.Views;
using GoldenEye.Backend.Core.DDD.Commands;
using GoldenEye.Backend.Core.DDD.Queries;
using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Mvc;

namespace Backend.DDD.WebApi.Sample.Controllers
{
    [Route("api/[controller]")]
    [EnableCors("CorsPolicy")]
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

        // GET api/incidents
        [HttpGet]
        public Task<IReadOnlyList<IssueView>> Get(GetIssues query)
        {
            return queryBus.SendAsync<GetIssues, IReadOnlyList<IssueView>>(query);
        }

        // GET api/incidents
        [HttpGet("{id}")]
        public Task<IssueView> Get(Guid id)
        {
            return queryBus.SendAsync<GetIssue, IssueView>(new GetIssue(id));
        }

        // POST api/incidents
        [HttpPost]
        public async Task<IActionResult> Post([FromBody] CreateIssue command)
        {
            await commandBus.SendAsync(command);

            return Ok();
        }
    }
}
