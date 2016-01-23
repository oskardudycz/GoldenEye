using System.Data.Entity;
using GoldenEye.Backend.Core.Context;
using GoldenEye.Backend.Security.Model;

namespace GoldenEye.Backend.Security.DataContext
{
    public interface IUserDataContext : IUserDataContext<User>
    {
    }

    public interface IUserDataContext<T> : IDataContext where T : class
    {
        IDbSet<T> Users { get; set; }
    }
}