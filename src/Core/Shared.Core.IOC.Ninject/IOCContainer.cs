using Ninject;
using System;
using System.Collections.Generic;
using System.Linq;
namespace GoldenEye.Shared.Core.IOC.Ninject
{
    public class IOCContainer : IOC.IOCContainer
    {
        private static IKernel _kernel;

        public IOCContainer(IKernel kernel)
        {
            _kernel = kernel;
        }

        public override T Get<T>()
        {
            try
            {
                return _kernel.Get<T>();
            }
            catch (ActivationException)
            {
                return default(T);
            }
        }

        public override IEnumerable<T> GetAll<T>()
        {
            try
            {
                return _kernel.GetAll<T>();
            }
            catch (ActivationException)
            {
                return new List<T>();
            }
        }
    }
}
