using System;
using AutoMapper;
using Microsoft.Extensions.DependencyInjection;

namespace GoldenEye.Shared.Core.Mappings
{
    public static class Registration
    {
        public static void AddAutoMapperForAllDependencies(
            this IServiceCollection services
        )
        {
            services.AddAutoMapper(AppDomain.CurrentDomain.GetAssemblies());
        }
    }
}