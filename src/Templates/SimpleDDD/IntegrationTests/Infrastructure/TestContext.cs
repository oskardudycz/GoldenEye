using System;
using System.Net.Http;
using GoldenEye.WebApi.Template.SimpleDDD;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.TestHost;

namespace WebApi.SimpleDDD.IntegrationTests.Infrastructure
{
    public class TestContext: IDisposable
    {
        private TestServer _server;

        public TestContext()
        {
            SetUpClient();
        }

        public HttpClient Client { get; private set; }

        public void Dispose()
        {
            _server?.Dispose();
            Client?.Dispose();
        }

        private void SetUpClient()
        {
            _server = new TestServer(new WebHostBuilder()
                .UseStartup<Startup>());

            Client = _server.CreateClient();
        }
    }
}
