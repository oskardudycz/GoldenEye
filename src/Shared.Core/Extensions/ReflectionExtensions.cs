using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Web;
using GoldenEye.Shared.Core.Modules.Attributes;

namespace GoldenEye.Shared.Core.Extensions
{
    public static class ReflectionExtensions
    {
        public static IList<Assembly> GetProjectAssemblies()
        {
            var domainAssemblies = AppDomain.CurrentDomain.GetAssemblies();

            var projectAssemblies =
                domainAssemblies.Where(el => el.GetCustomAttribute<ProjectAssemblyAttribute>() != null).ToList();

            return projectAssemblies;
        }
    }
}