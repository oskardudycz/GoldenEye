using System.Linq;
using GoldenEye.Backend.Core.Context;
using GoldenEye.Backend.Core.Entity;

namespace GoldenEye.Backend.Core.Repositories
{
    public abstract class ReadonlyRepositoryBase<TEntity> : IReadonlyRepository<TEntity> where TEntity : class, IEntity
    {
        protected readonly IDataContext Context;

        protected readonly IQueryable<TEntity> Queryable;

        protected bool Disposed;

        protected ReadonlyRepositoryBase(IDataContext context)
        {
            Context = context;
            Queryable = context.GetQueryable<TEntity>();
        }

        public virtual IQueryable<TEntity> Includes(IQueryable<TEntity> queryable)
        {
            return queryable;
        }

        public virtual TEntity GetById(object id)
        {
            return Queryable.SingleOrDefault(r => r.Id == (int)id);

        }

        public virtual IQueryable<TEntity> GetAll()
        {
            return Queryable;
        }

        protected virtual void Dispose(bool disposing)
        {
            if (Disposed)
            {
                return;
            }
            if (disposing)
            {
                Context.Dispose();
            }
            Disposed = true;
        }

        public virtual void Dispose()
        {
            Dispose(true);
        }
    }
}