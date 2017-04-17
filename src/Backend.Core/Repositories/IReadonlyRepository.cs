using System;
using System.Linq;
using GoldenEye.Backend.Core.Entity;
using System.Threading.Tasks;

namespace GoldenEye.Backend.Core.Repositories
{
    public interface IReadonlyRepository<TEntity> : IDisposable where TEntity : class, IEntity
    {
        TEntity GetById(object id);
        Task<TEntity> GetByIdAsync(object id);
        IQueryable<TEntity> GetAll();
    }
}