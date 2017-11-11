using System;
using System.Linq;
using System.Threading.Tasks;
using GoldenEye.Backend.Core.Context;
using GoldenEye.Shared.Core.Objects.General;

namespace GoldenEye.Backend.Core.Repositories
{
    public class ReadonlyRepository<TEntity> : IReadonlyRepository<TEntity> where TEntity : class, IHasId
    {
        protected readonly IDataContext Context;

        protected readonly IQueryable<TEntity> Queryable;

        protected bool Disposed;

        public ReadonlyRepository(IDataContext context)
        {
            Context = context ?? throw new ArgumentException(nameof(context));
            Queryable = context.GetQueryable<TEntity>();
        }

        public virtual IQueryable<TEntity> Includes(IQueryable<TEntity> queryable)
        {
            return queryable;
        }

        public virtual TEntity GetById(object id)
        {
            return Queryable.SingleOrDefault(r => r.Id == id);
        }

        public virtual Task<TEntity> GetByIdAsync(object id)
        {
            return Task.Run(() => GetById(id));
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
            //if (disposing)
            //{
            //    Context.Dispose();
            //}
            //Disposed = true;
        }

        public virtual void Dispose()
        {
            Dispose(true);
        }
    }
}