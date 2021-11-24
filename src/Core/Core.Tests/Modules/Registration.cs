using System.Linq;
using FluentAssertions;
using GoldenEye.Modules;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace GoldenEye.Tests.Modules;

public class Registration
{
    public Registration()
    {
        services.AddAllApplicationModules();
    }

    public class CustomModuleImplementingIModule: IModule
    {
        public void Configure(IServiceCollection services)
        {
        }

        public void Use()
        {
        }
    }

    public class CustomModuleDerivedFromModule: Module
    {
    }

    public class CustomModuleDerivingFromOtherCustomModule: CustomModuleDerivedFromModule
    {
    }

    private readonly ServiceCollection services = new ServiceCollection();

    [Fact]
    public void GivenCustomModuleDerivedFromModule_WhenAddAllModulesCalled_ThenModuleIsRegistered()
    {
        using (var sp = services.BuildServiceProvider())
        {
            sp.GetService<CustomModuleDerivedFromModule>().Should().NotBeNull();
        }
    }

    [Fact]
    public void GivenCustomModuleDerivingFromOtherCustomModule_WhenAddAllModulesCalled_ThenModuleIsRegistered()
    {
        using (var sp = services.BuildServiceProvider())
        {
            sp.GetService<CustomModuleDerivingFromOtherCustomModule>().Should().NotBeNull();
        }
    }

    [Fact]
    public void GivenCustomModuleImplementingIModule_WhenAddAllModulesCalled_ThenModuleIsRegistered()
    {
        using (var sp = services.BuildServiceProvider())
        {
            sp.GetService<CustomModuleImplementingIModule>().Should().NotBeNull();
        }
    }

    [Fact]
    public void GivenMultipleCustomModules_WhenAddAllModulesCalled_ThenAllModulesAreRegisteredAsIModule()
    {
        using (var sp = services.BuildServiceProvider())
        {
            var modules = sp.GetServices<IModule>().ToList();

            modules.Should().Contain(x => x is CustomModuleImplementingIModule);
            modules.Should().Contain(x => x is CustomModuleDerivedFromModule);
            modules.Should().Contain(x => x is CustomModuleDerivingFromOtherCustomModule);
        }
    }
}