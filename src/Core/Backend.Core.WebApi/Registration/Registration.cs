using System.Net;
using System.Security.Cryptography.X509Certificates;
using GoldenEye.Backend.Core.WebApi.Exceptions;
using GoldenEye.Backend.Core.WebApi.Options;
using Microsoft.AspNetCore.Antiforgery;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.DependencyInjection;

namespace GoldenEye.Backend.Core.WebApi.Registration
{
    public static class Registration
    {
        public static IWebHostBuilder UseKestrelWithHttps(this IWebHostBuilder hostBuilder, HttpsServerOptions httpsOptions = null)
        {
            if (httpsOptions == null)
                httpsOptions = HttpsServerOptions.Create();

            hostBuilder
                .UseKestrel(
                    options =>
                    {
                        httpsOptions.Apply(options);

                        var certificate = new X509Certificate2(
                            httpsOptions.CertificateOptions.Path,
                            httpsOptions.CertificateOptions.Password);
                        options.AddServerHeader = false;
                        options.Listen(IPAddress.Loopback, httpsOptions.Port, listenOptions =>
                        {
                            listenOptions.UseHttps(certificate);
                        });
                    }
                )
                .UseUrls($"https://*:{httpsOptions.Port}");

            return hostBuilder;
        }

        public static IMvcBuilder AddMvcWithHttps(this IServiceCollection services, HttpsMvcOptions httpsOptions = null)
        {
            if (httpsOptions == null)
                httpsOptions = HttpsMvcOptions.Create();

            services.AddAntiforgery(
                options =>
                {
                    options.UseHttps();
                }
            );

            return services.AddMvc(
               options =>
               {
                   httpsOptions.Apply(options);
                   options.UseHttps();
               }
           );
        }

        public static MvcOptions UseHttps(this MvcOptions options, int port = 443)
        {
            options.SslPort = port;
            options.Filters.Add(new RequireHttpsAttribute());

            return options;
        }

        public static AntiforgeryOptions UseHttps(this AntiforgeryOptions options)
        {
            options.Cookie.Name = "_af";
            options.Cookie.HttpOnly = true;
            options.Cookie.SecurePolicy = CookieSecurePolicy.Always;
            options.HeaderName = "X-XSRF-TOKEN";

            return options;
        }

        public static IApplicationBuilder UseExceptionHandlingMiddleware(this IApplicationBuilder app)
        {
            app.UseMiddleware(typeof(ExceptionHandlingMiddleware));
            return app;
        }
    }
}