using GoldenEye.Shared.Core.Modules;
using Ninject.Modules;

namespace GoldenEye.Shared.Core.IOC.Ninject.Modules
{
    public abstract class ModuleBase : NinjectModule, IModule, INinjectModule
    {
        public virtual void Initalize()
        {
        }
    }
}
