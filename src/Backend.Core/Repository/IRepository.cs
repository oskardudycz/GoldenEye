using System.Collections.Generic;
using System.Linq;
using GoldenEye.Backend.Core.Entity;

namespace GoldenEye.Backend.Core.Repository
{
    public interface IRepository<TEntity> : IReadonlyRepository<TEntity> where TEntity : class, IEntity
    {
        TEntity Add(TEntity entity);
        IQueryable<TEntity> AddAll(IEnumerable<TEntity> entities);
        TEntity Update(TEntity entity);
        int SaveChanges();
        TEntity Delete(TEntity entity);
        bool Delete(int id);
    }
}