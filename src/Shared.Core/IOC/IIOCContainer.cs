using System.Collections.Generic;

namespace GoldenEye.Shared.Core.IOC
{
    public interface IIOCContainer
    {
        T Get<T>();
        IEnumerable<T> GetAll<T>();
    }
}