using System.Data.Entity;
using System.Linq;
using GoldenEye.Backend.Core.Context;
using GoldenEye.Shared.Core;

namespace GoldenEye.Backend.Core.Repository
{
    public abstract class ReadonlyRepositoryBase<TEntity> : IReadonlyRepository<TEntity> where TEntity : class, IHasObjectId
    {
        protected readonly IDataContext Context;

        protected readonly IQueryable<TEntity> Queryable;

        protected bool Disposed;

        protected ReadonlyRepositoryBase(IDataContext context, IQueryable<TEntity> queryable)
        {
            Context = context;
            Queryable = queryable;
        }

        public virtual TEntity GetById(object id, bool withNoTracking = true)
        {
            return (withNoTracking ? Queryable.AsNoTracking() : Queryable).SingleOrDefault(r => r.Id == id);

        }

        public virtual IQueryable<TEntity> GetAll(bool withNoTracking = true)
        {
            return withNoTracking ? Queryable.AsNoTracking() : Queryable;
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