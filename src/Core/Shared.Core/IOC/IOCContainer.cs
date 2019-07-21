using System.Collections.Generic;

namespace GoldenEye.Shared.Core.IOC
{
    public abstract class IOCContainer: IIOCContainer
    {
        public static IIOCContainer Instance { get; private set; }

        public static void Initialize(IIOCContainer instance)
        {
            Instance = instance;
        }

        public abstract T Get<T>();

        public abstract IEnumerable<T> GetAll<T>();
    }
}
