using System;
using System.Reflection;

namespace GoldenEye.Shared.Core.Utils.Assemblies
{
    public static class AssembliesProvider
    {
        public static Assembly[] GetAll()
        {
            return AppDomain.CurrentDomain.GetAssemblies();
        }
    }
}
