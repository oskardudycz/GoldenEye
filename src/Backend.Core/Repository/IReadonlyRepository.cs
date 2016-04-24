using System;
using System.Linq;
using GoldenEye.Backend.Core.Entity;

namespace GoldenEye.Backend.Core.Repository
{
    public interface IReadonlyRepository<out TEntity> : IDisposable where TEntity : class, IEntity
    {
        TEntity GetById(object id, bool withNoTracking = true);
        IQueryable<TEntity> GetAll(bool withNoTracking = true);
    }
}