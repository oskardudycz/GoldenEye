using System;
using System.Linq;
using Shared.Core;

namespace Backend.Core.Repository
{
    public interface IReadonlyRepository<out TEntity> :IDisposable where TEntity : class, IHasId
    {
        TEntity GetById(int id);
        IQueryable<TEntity> GetAll();
    }
}