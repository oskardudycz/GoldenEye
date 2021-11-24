using System;
using System.Net.Http;
using Backend.DDD.WebApi.Sample;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.TestHost;

namespace Backend.DDD.Sample.IntegrationTests.Infrastructure;

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