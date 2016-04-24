using System.Reflection;

namespace GoldenEye.Shared.Core.Utils.Assemblies
{
    public static class AssembliesProvider
    {
        public static Assembly[] GetAll()
        {
            //AppDomain.CurrentDomain.GetAssemblies()
            return new Assembly[] { };
        }
    }
}
