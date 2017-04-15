using System;
using System.Linq;
using GoldenEye.Backend.Core.Entity;

namespace GoldenEye.Backend.Core.Repositories
{
    public interface IReadonlyRepository<out TEntity> : IDisposable where TEntity : class, IEntity
    {
        TEntity GetById(object id);
        IQueryable<TEntity> GetAll();
    }
}