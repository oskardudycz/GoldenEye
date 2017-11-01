using System.Collections.Generic;
using IdentityServer4.Models;
using IdentityServer4.Test;
using Microsoft.Extensions.DependencyInjection;

namespace GoldenEye.Backend.Identity
{
    public static class Registration
    {
        public static void AddDefaultDevelopmentIdentityConfiguration(this IServiceCollection services)
        {
            services.AddIdentityServer()
                .AddInMemoryClients(new List<Client>())
                .AddInMemoryIdentityResources(new List<IdentityResource>())
                .AddInMemoryApiResources(new List<ApiResource>())
                .AddTestUsers(new List<TestUser>())
                .AddDeveloperSigningCredential();
        }
    }
}