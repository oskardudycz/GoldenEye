using System;
using System.Linq;
using GoldenEye.Shared.Core;

namespace GoldenEye.Backend.Core.Repository
{
    public interface IReadonlyRepository<out TEntity> : IDisposable where TEntity : class, IHasObjectId
    {
        TEntity GetById(object id);
        IQueryable<TEntity> GetAll();
    }
}