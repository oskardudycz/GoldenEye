using System.Collections.Generic;

namespace GoldenEye.Core.IOC
{
    public abstract class IOCContainer: IIOCContainer
    {
        public static IIOCContainer Instance { get; private set; }

        public abstract T Get<T>();

        public abstract IEnumerable<T> GetAll<T>();

        public static void Initialize(IIOCContainer instance)
        {
            Instance = instance;
        }
    }
}
