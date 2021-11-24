using System.Collections.Generic;
using System.Linq;
using GoldenEye.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection;

namespace GoldenEye.Dapper.Mappings;

public static class Registration
{
    public static IServiceCollection AddAllDapperMappings(this IServiceCollection services,
        ServiceLifetime serviceLifetime = ServiceLifetime.Transient)
    {
        services.Scan(scan => scan
            .FromApplicationDependencies()
            .AddClasses(classes => classes.Where(t => !t.IsGenericType).AssignableTo(typeof(IDapperMapping<>)))
            .AsImplementedInterfaces()
            .WithLifetime(serviceLifetime));

        services.Add<IReadOnlyCollection<IDapperMapping>>(sp => sp.GetServices<IDapperMapping>().ToList());

        return services;
    }
}