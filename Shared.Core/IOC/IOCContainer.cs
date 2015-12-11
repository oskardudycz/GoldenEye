using Ninject;

namespace GoldenEye.Shared.Core.IOC
{
    public static class IOCContainer
    {
        private static IKernel _kernel;

        public static void Initialize(IKernel kernel)
        {
            _kernel = kernel;
        }

        public static T Get<T>()
        {
            return _kernel.Get<T>();
        }
    }
}