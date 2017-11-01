using System.Collections.Generic;
using GoldenEye.Backend.Identity.Clients.Tests;
using IdentityServer4.Models;
using IdentityServer4.Test;
using Microsoft.Extensions.DependencyInjection;

namespace GoldenEye.Backend.Identity
{
    public static class Registration
    {
        public static void AddIdentityServerWithDefaults(this IServiceCollection services)
        {
            services.AddIdentityServer()
                .AddInMemoryClients(TestClients.Get())
                .AddInMemoryIdentityResources(TestResources.GetIdentityResources())
                .AddInMemoryApiResources(TestResources.GetApiResources())
                .AddTestUsers(TestUsers.Get())
                .AddDeveloperSigningCredential();
        }
    }
}