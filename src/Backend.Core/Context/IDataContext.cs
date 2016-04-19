using System;
using System.Collections.Generic;
using System.Data.Entity.Infrastructure;
using GoldenEye.Backend.Core.Entity;

namespace GoldenEye.Backend.Core.Context
{
    public interface IDataContext : IDisposable
    {
        DbEntityEntry<T> Entry<T>(T entity) where T : class;

        int SaveChanges();

        IEnumerable<IEntity> GetAddedEntities();
        IEnumerable<IEntity> GetUpdatedEntities();
    }
}
