using GoldenEye.Backend.Core.WebApi.Options;
using GoldenEye.Backend.Core.WebApi.Registration;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;

namespace Frontend.Identity.Sample
{
    public class Program
    {
        public static void Main(string[] args)
        {
            BuildWebHost(args).Run();
        }

        public static IWebHost BuildWebHost(string[] args) =>
            WebHost.CreateDefaultBuilder(args)
                .UseKestrelWithHttps(HttpsServerOptions.Create(port: 4430))
                .UseStartup<Startup>()
                .Build();
    }
}