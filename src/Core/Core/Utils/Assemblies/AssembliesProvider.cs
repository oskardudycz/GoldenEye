using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using Microsoft.Extensions.DependencyModel;

namespace GoldenEye.Utils.Assemblies;

public static class AssembliesProvider
{
    public static IEnumerable<Assembly> GetAll(string assemblyPrefix = null)
    {
        var dependencies = DependencyContext.Default.RuntimeLibraries;

        var list = new List<Assembly>();
        foreach (var library in dependencies)
            if (IsCandidateLibrary(library, assemblyPrefix))
                list.Add(Assembly.Load(new AssemblyName(library.Name)));
        return list;
    }

    private static bool IsCandidateLibrary(Library library, string assemblyPrefix)
    {
        return string.IsNullOrEmpty(assemblyPrefix)
               || library.Name.ToLower().StartsWith(assemblyPrefix.ToLower())
               || library.Dependencies.Any(d => d.Name.ToLower().StartsWith(assemblyPrefix.ToLower()));
    }
}