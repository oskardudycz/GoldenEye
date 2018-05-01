using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Contracts.Issues.Commands;
using Contracts.Issues.Queries;
using Contracts.Issues.Views;
using GoldenEye.Backend.Core.DDD.Commands;
using GoldenEye.Backend.Core.DDD.Queries;
using Microsoft.AspNetCore.Mvc;

namespace GoldenEye.WebApi.SimpleDDD.Controllers
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

        // GET api/issues
        [HttpGet]
        public Task<IReadOnlyList<IssueView>> Get(GetIssues query)
        {
            return queryBus.Send<GetIssues, IReadOnlyList<IssueView>>(query);
        }

        // GET api/issues
        [HttpGet("{id}")]
        public Task<IssueView> Get(Guid id)
        {
            return queryBus.Send<GetIssue, IssueView>(new GetIssue(id));
        }

        // POST api/issues
        [HttpPost]
        public async Task<IActionResult> Post([FromBody]CreateIssue command)
        {
            await commandBus.Send(command);

            return Ok();
        }
    }
}