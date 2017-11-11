using System;
using System.Linq;
using System.Threading.Tasks;
using GoldenEye.Shared.Core.Objects.General;

namespace GoldenEye.Backend.Core.Repositories
{
    public interface IReadonlyRepository<TEntity> : IDisposable where TEntity : class, IHasId
    {
        TEntity GetById(object id);

        Task<TEntity> GetByIdAsync(object id);

        IQueryable<TEntity> GetAll();
    }
}