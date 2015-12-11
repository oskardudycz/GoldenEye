using Ninject.Modules;

namespace GoldenEye.Shared.Core.Modules
{
    public abstract class ModuleBase : NinjectModule, IModule
    {
        public virtual void Initalize()
        {
        }
    }
}