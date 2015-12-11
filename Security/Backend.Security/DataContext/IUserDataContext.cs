using System.Data.Entity;
using GoldenEye.Backend.Core.Context;
using GoldenEye.Backend.Security.Model;

namespace GoldenEye.Backend.Security.DataContext
{
    public interface IUserDataContext : IDataContext
    {
        IDbSet<User> Users { get; set; }
    }
}