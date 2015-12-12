using Ninject.Modules;

namespace GoldenEye.Shared.Core.Modules
{
    public interface IModule : INinjectModule
    {
        void Initalize();
    }
}
