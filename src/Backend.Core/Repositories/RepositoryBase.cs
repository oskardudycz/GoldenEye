using System.Collections.Generic;
using System.Linq;
using GoldenEye.Backend.Core.Context;
using GoldenEye.Backend.Core.Entity;

namespace GoldenEye.Backend.Core.Repositories
{
    public abstract class RepositoryBase<TEntity> : ReadonlyRepositoryBase<TEntity>, IRepository<TEntity> where TEntity : class, IEntity
    {
        protected RepositoryBase(IDataContext context) : base(context)
        {
        }

        public virtual TEntity Add(TEntity entity)
        {
            return Add(entity, true);
        }

        private TEntity Add(TEntity entity, bool shouldSaveChanges)
        {
            var result = Context.Add(entity);

            if (shouldSaveChanges)
                SaveChanges();

            return result;
        }

        public virtual IQueryable<TEntity> AddAll(IEnumerable<TEntity> entities)
        {
            var result = Context.AddRange(entities.ToArray());
            
            SaveChanges();

            return result.AsQueryable();
        }

        public virtual TEntity Update(TEntity entity)
        {
            return Update(entity, true);
        }

        public virtual TEntity Update(TEntity entity, bool shouldSaveChanges)
        {
            var result = Context.Update(entity);
            SaveChanges();
            return result;
        }

        public virtual int SaveChanges()
        {
            return Context.SaveChanges();
        }

        public virtual TEntity Delete(TEntity entity)
        {
            return Context.Remove(entity);
        }

        public virtual bool Delete(int id)
        {
            return Context.Remove(GetById(id)) != null;
        }
    }
}