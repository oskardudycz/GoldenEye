using Microsoft.Extensions.DependencyInjection;

namespace GoldenEye.Frontend.Identity
{
    public static class Registration
    {
        public static void AddIdentityClientWithDefaults(this IServiceCollection services)
        {
            services.AddAuthentication(options =>
            {
                options.DefaultScheme = "cookie";
                options.DefaultChallengeScheme = "oidc";
            })
            .AddCookie("cookie")
            .AddOpenIdConnect("oidc", options =>
            {
                options.Authority = "https://localhost:443/";
                options.ClientId = "openIdConnectClient";
                options.SignInScheme = "cookie";
            });
        }
    }
}