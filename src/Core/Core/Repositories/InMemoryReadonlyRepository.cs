using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Core.Exceptions;
using GoldenEye.Core.Objects.General;

namespace GoldenEye.Core.Repositories
{
    public class InMemoryReadonlyRepository<TEntity>: IReadonlyRepository<TEntity> where TEntity : class, IHaveId
    {
        protected readonly IList<TEntity> Context;

        public InMemoryReadonlyRepository()
        {
            Context = new List<TEntity>();
        }

        public virtual TEntity FindById(object id)
        {
            return Context.SingleOrDefault(r => r.Id == id);
        }

        public virtual Task<TEntity> FindByIdAsync(object id, CancellationToken cancellationToken = default)
        {
            return Task.FromResult(FindById(id));
        }

        public virtual TEntity GetById(object id)
        {
            return FindById(id) ?? throw NotFoundException.For<TEntity>(id);
        }

        public virtual Task<TEntity> GetByIdAsync(object id, CancellationToken cancellationToken = default)
        {
            return Task.FromResult(GetById(id));
        }

        public virtual IQueryable<TEntity> Query()
        {
            return Context.AsQueryable();
        }

        public IReadOnlyCollection<TEntity> Query(string query, params object[] queryParams)
        {
            throw new NotImplementedException(
                $"Custom query is not supported for {typeof(InMemoryReadonlyRepository<>).Name}");
        }

        public Task<IReadOnlyCollection<TEntity>> QueryAsync(string query,
            CancellationToken cancellationToken = default, params object[] queryParams)
        {
            throw new NotImplementedException(
                $"Custom query is not supported for {typeof(InMemoryReadonlyRepository<>).Name}");
        }
    }
}
