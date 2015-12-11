using System.Data.Entity;
using System.Linq;
using GoldenEye.Backend.Core.Context;
using GoldenEye.Shared.Core;

namespace GoldenEye.Backend.Core.Repository
{
    public abstract class RepositoryBase<TEntity> : ReadonlyRepositoryBase<TEntity> where TEntity : class, IHasObjectId
    {
        protected readonly IDbSet<TEntity> DbSet;
        
        protected RepositoryBase(IDataContext context, IDbSet<TEntity> dbSet) : base(context, dbSet.AsNoTracking())
        {
            DbSet = dbSet;
        }

        public virtual TEntity Add(TEntity entity)
        {
            return DbSet.Add(entity);
        }

        public IQueryable<TEntity> AddAll(IQueryable<TEntity> entities)
        {
            return entities.Select(entity => DbSet.Add(entity)).AsQueryable();
        }

        public virtual TEntity Update(TEntity entity)
        {
            var oldEntity = Context.Entry(entity);
            if (oldEntity.State != EntityState.Detached)
                return oldEntity.Entity;
            oldEntity.State = EntityState.Modified;
            SaveChanges();
            return DbSet.Attach(entity);
        }

        public int SaveChanges()
        {
            return Context.SaveChanges();
        }

        public TEntity Delete(TEntity entity)
        {
            return DbSet.Remove(entity);
        }

        public bool Delete(int id)
        {
            return DbSet.Remove(GetById(id)) != null;
        }
    }
}