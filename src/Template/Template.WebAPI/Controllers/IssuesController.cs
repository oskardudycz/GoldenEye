using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Backend.Contracts.Issues.Commands;
using Backend.Contracts.Issues.Queries;
using Backend.Contracts.Issues.Views;
using GoldenEye.Backend.Core.DDD.Commands;
using GoldenEye.Backend.Core.DDD.Queries;
using Microsoft.AspNetCore.Mvc;

namespace GoldenEye.WebAPI.Controllers
{
    [Route("api/[controller]")]
    [Microsoft.AspNetCore.Cors.EnableCors("CorsPolicy")]
    public class IssuesController : Controller
    {
        private readonly IQueryBus queryBus;
        private readonly ICommandBus commandBus;

        public IssuesController(IQueryBus queryBus,
            ICommandBus commandBus)
        {
            this.queryBus = queryBus ?? throw new ArgumentException(nameof(queryBus));
            this.commandBus = commandBus ?? throw new ArgumentException(nameof(commandBus));
        }

        // GET api/Issues
        [HttpGet]
        public Task<IReadOnlyList<Issue>> Get(GetIssues query)
        {
            return queryBus.Send<GetIssues, IReadOnlyList<Issue>>(query);
        }

        // GET api/incidents
        [HttpGet("{id}")]
        public Task<Issue> Get(Guid id)
        {
            return queryBus.Send<GetIssue, Issue>(new GetIssue(id));
        }

        // POST api/incidents
        [HttpPost]
        public async Task<IActionResult> Post([FromBody]CreateIssue command)
        {
            await commandBus.Send(command);

            return Ok();
        }
    }
}