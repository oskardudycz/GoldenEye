using System.Linq;
using FluentAssertions;
using GoldenEye.Shared.Core.Modules;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace Shared.Core.Tests.Modules
{
    public class Registration
    {
        public class CustomModuleImplementingIModule : IModule
        {
            public void Configure(IServiceCollection services)
            {
            }

            public void Use()
            {
            }
        }

        public class CustomModuleDerivedFromModule : Module
        {
        }

        public class CustomModuleDerivingFromOtherCustomModule : CustomModuleDerivedFromModule
        {
        }

        private ServiceCollection services = new ServiceCollection();

        public Registration()
        {
            services.AddAllModules();
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

        [Fact]
        public void GivenCustomModuleImplementingIModule_WhenAddAllModulesCalled_ThenModuleIsRegistered()
        {
            using (var sp = services.BuildServiceProvider())
            {
                sp.GetService<CustomModuleImplementingIModule>().Should().NotBeNull();
            }
        }

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
    }
}