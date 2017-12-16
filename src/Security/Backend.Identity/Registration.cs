using System;
using System.Linq;
using GoldenEye.Backend.Core.EntityFramework.Registration;
using GoldenEye.Backend.Identity.Clients.Tests;
using GoldenEye.Backend.Identity.Storage;
using IdentityServer4.EntityFramework.DbContexts;
using IdentityServer4.EntityFramework.Mappers;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
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

        public static void AddIdentityServerWithEFPersistedStorage<TApplicationDbContext, TIdentityUser, TIdentityRole>(
            this IServiceCollection services,
            Action<DbContextOptionsBuilder> dbContextOptions)
            where TIdentityUser : class
            where TIdentityRole : class
            where TApplicationDbContext : DbContext
        {
            services.AddDbContext<TApplicationDbContext>(dbContextOptions);

            services.AddEFDataContext<TApplicationDbContext>((sp, builder) => dbContextOptions(builder));

            services.AddIdentity<TIdentityUser, TIdentityRole>()
                .AddEntityFrameworkStores<TApplicationDbContext>();

            services.AddIdentityServer()
                .AddOperationalStore(options =>
                    options.ConfigureDbContext = dbContextOptions)
                .AddConfigurationStore(options =>
                    options.ConfigureDbContext = dbContextOptions)
                .AddAspNetIdentity<TIdentityUser>()
                .AddDeveloperSigningCredential();
        }

        public static void AddIdentityServerWithEFPersistedStorage(this IServiceCollection services,
            Action<DbContextOptionsBuilder> dbContextOptions)
        {
            services.AddIdentityServerWithEFPersistedStorage<ApplicationDbContext, IdentityUser, IdentityRole>(dbContextOptions);
        }

        public static void UseSampleIdentityData(this IApplicationBuilder app)
        {
            using (var scope = app.ApplicationServices.GetService<IServiceScopeFactory>().CreateScope())
            {
                scope.ServiceProvider.GetRequiredService<PersistedGrantDbContext>().Database.Migrate();
                scope.ServiceProvider.GetRequiredService<ConfigurationDbContext>().Database.Migrate();
                scope.ServiceProvider.GetRequiredService<ApplicationDbContext>().Database.Migrate();

                var context = scope.ServiceProvider.GetRequiredService<ConfigurationDbContext>();

                if (!context.Clients.Any())
                {
                    foreach (var client in TestClients.Get())
                    {
                        context.Clients.Add(client.ToEntity());
                    }
                    context.SaveChanges();
                }

                if (!context.IdentityResources.Any())
                {
                    foreach (var resource in TestResources.GetIdentityResources())
                    {
                        context.IdentityResources.Add(resource.ToEntity());
                    }
                    context.SaveChanges();
                }

                if (!context.ApiResources.Any())
                {
                    foreach (var resource in TestResources.GetApiResources())
                    {
                        context.ApiResources.Add(resource.ToEntity());
                    }
                    context.SaveChanges();
                }

                var userManager = scope.ServiceProvider.GetRequiredService<UserManager<IdentityUser>>();
                if (!userManager.Users.Any())
                {
                    foreach (var testUser in TestUsers.Get())
                    {
                        var identityUser = new IdentityUser(testUser.Username)
                        {
                            Id = testUser.SubjectId
                        };

                        userManager.CreateAsync(identityUser, testUser.Password).Wait();
                        userManager.AddClaimsAsync(identityUser, testUser.Claims.ToList()).Wait();
                    }
                }
            }
        }
    }
}