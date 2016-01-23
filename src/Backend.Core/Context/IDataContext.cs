using System;
using System.Data.Entity.Infrastructure;

namespace GoldenEye.Backend.Core.Context
{
    public interface IDataContext : IDisposable
    {
        DbEntityEntry<T> Entry<T>(T entity) where T : class;
        int SaveChanges();
    }
}
