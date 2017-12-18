using GoldenEye.Backend.Core.WebApi.Registration;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;

namespace Backend.Identity.Sample
{
    public class Program
    {
        public static void Main(string[] args)
        {
            BuildWebHost(args).Run();
        }

        public static IWebHost BuildWebHost(string[] args) =>
            WebHost.CreateDefaultBuilder(args)
                .UseKestrelWithHttps()
                .UseStartup<Startup>()
                .Build();
    }
}