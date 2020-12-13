using System.Collections.Generic;

namespace GoldenEye.Core.IOC
{
    public interface IIOCContainer
    {
        T Get<T>();

        IEnumerable<T> GetAll<T>();
    }
}
