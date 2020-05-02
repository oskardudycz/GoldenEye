using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Backend.Core.Context;
using GoldenEye.Backend.Core.Exceptions;
using GoldenEye.Shared.Core.Objects.General;

namespace GoldenEye.Backend.Core.Repositories
{
    public class ReadonlyRepository<TEntity>: IReadonlyRepository<TEntity> where TEntity : class, IHaveId
    {
        protected readonly IDataContext Context;

        protected readonly IQueryable<TEntity> Queryable;

        public ReadonlyRepository(IDataContext context)
        {
            Context = context ?? throw new ArgumentException(nameof(context));
            Queryable = context.GetQueryable<TEntity>();
        }

        public virtual TEntity FindById(object id)
        {
            return Queryable.SingleOrDefault(r => r.Id == id);
        }

        public virtual Task<TEntity> FindByIdAsync(object id, CancellationToken cancellationToken = default)
        {
            return Task.Run(() => FindById(id));
        }

        public virtual TEntity GetById(object id)
        {
            return FindById(id) ?? throw NotFoundException.For<TEntity>(id);
        }

        public virtual Task<TEntity> GetByIdAsync(object id, CancellationToken cancellationToken = default)
        {
            return Task.Run(() => GetById(id));
        }

        public virtual IQueryable<TEntity> Query()
        {
            return Queryable;
        }

        public IQueryable<TEntity> Query(string query)
        {
            return Context.CustomQuery<TEntity>(query);
        }
    }
}
