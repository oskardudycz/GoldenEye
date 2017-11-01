using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using GoldenEye.Backend.Core.WebApi;
using GoldenEye.Backend.Core.WebApi.Options;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

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