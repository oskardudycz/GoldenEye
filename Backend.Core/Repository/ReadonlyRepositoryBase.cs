using System.Linq;
using Backend.Core.Context;
using Shared.Core;

namespace Backend.Core.Repository
{
    public abstract class ReadonlyRepositoryBase<TEntity> : IReadonlyRepository<TEntity> where TEntity : class, IHasId
    {
        protected readonly IDataContext Context;

        protected readonly IQueryable<TEntity> Queryable;

        protected bool Disposed;

        protected ReadonlyRepositoryBase(IDataContext context, IQueryable<TEntity> queryable)
        {
            Context = context;
            Queryable = queryable;
        }

        public TEntity GetById(int id)
        {
            return Queryable.SingleOrDefault(r => r.Id == id);

        }

        public IQueryable<TEntity> GetAll()
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

        public void Dispose()
        {
            Dispose(true);
        }
    }
}