using Microsoft.Extensions.DependencyModel;
using System;
using System.Collections.Generic;
using System.Reflection;
using System.Linq;

namespace GoldenEye.Shared.Core.Utils.Assemblies
{
    public static class AssembliesProvider
    {
        public static IEnumerable<Assembly> GetAll(string assemblyName = null)
        {
            var dependencies = DependencyContext.Default.RuntimeLibraries;

            var list = new List<Assembly>();
            foreach (var library in dependencies)
            {
                if (IsCandidateLibrary(library, assemblyName)) list.Add(Assembly.Load(new AssemblyName(library.Name)));
            }
            return list;
        }

        private static bool IsCandidateLibrary(Library library, string assemblyName)
        {
            return string.IsNullOrEmpty(assemblyName)
                || library.Name.ToLower().StartsWith(assemblyName.ToLower())
                || library.Dependencies.Any(d => d.Name.ToLower().StartsWith(assemblyName.ToLower()));
        }
    }
}
