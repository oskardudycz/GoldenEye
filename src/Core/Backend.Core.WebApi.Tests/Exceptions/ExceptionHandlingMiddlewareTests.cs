using System.Net;
using System.Reflection;
using System.Threading.Tasks;
using FluentAssertions;
using FluentValidation;
using GoldenEye.Backend.Core.WebApi.Registration;
using GoldenEye.Shared.Core.Exceptions;
using GoldenEye.Shared.Core.Extensions.Basic;
using GoldenEye.Shared.Core.Extensions.Serialization;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace Backend.Core.WebApi.Tests.Exceptions
{
    public class CreateUser
    {
        public string UserName { get; }

        public CreateUser(string userName)
        {
            UserName = userName;
        }
    }

    [Route("api/Users")]
    public class UsersController : Controller
    {
        [HttpPost]
        public IActionResult Post([FromBody]CreateUser command)
        {
            if (command.UserName.IsNullOrEmpty())
                throw new ValidationException("UserName is required");

            return Ok();
        }
    }

    public class ExceptionHandlingMiddlewareTests
    {
        public class Startup
        {
            public Startup(IHostingEnvironment env)
            {
                var builder = new ConfigurationBuilder()
                    .SetBasePath(env.ContentRootPath)
                    .AddEnvironmentVariables();
                Configuration = builder.Build();
            }

            public IConfigurationRoot Configuration { get; }

            // This method gets called by the runtime. Use this method to add services to the container.
            public void ConfigureServices(IServiceCollection services)
            {
                var assembly = typeof(UsersController).GetTypeInfo().Assembly;
                services.AddMvc()
                    .AddApplicationPart(assembly);
            }

            public void Configure(IApplicationBuilder app, IHostingEnvironment env)
            {
                //Use ExceptionHandlingMiddleware needs to be registered before UseMvc
                app.UseExceptionHandlingMiddleware();

                app.UseMvc();
            }
        }

        [Fact]
        public async Task GivenAppWithExceptionHandlingMiddleware_WhenExceptionWasThrown_ThenReturnsResultWithProperStatusCodeAndErrorInfo()
        {
            //Given
            var server = new TestServer(new WebHostBuilder()
                .UseStartup<Startup>());

            var client = server.CreateClient();

            var invalidCommand = new CreateUser(null);

            //When
            var response = await client.PostAsync("/api/Users", invalidCommand.ToJsonStringContent());

            //Then
            response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
            var resultJson = await response.Content.ReadAsStringAsync();

            var result = resultJson.FromJson<HttpExceptionWrapper>();
            result.StatusCode.Should().Be((int)HttpStatusCode.BadRequest);
            result.Error.Should().Be("UserName is required");
        }
    }
}