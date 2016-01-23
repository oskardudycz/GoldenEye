using System.Data.Entity;
using GoldenEye.Backend.Core.Context;

namespace GoldenEye.Backend.Security.DataContext
{
    public interface IUserDataContext<T> : IDataContext where T : class
    {
        IDbSet<T> Users { get; set; }
    }
}