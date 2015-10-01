using System.Data.Entity;
using System.Linq;
using Backend.Core.Context;
using Shared.Core;

namespace Backend.Core.Repository
{
    public abstract class BaseRepository<TEntity> : IRepository<TEntity> where TEntity : class, IHasId
    {

        protected readonly IDbSet<TEntity> DbSet;

        protected readonly IDataContext Context;

        protected bool Disposed;


        protected BaseRepository(IDataContext context, IDbSet<TEntity> dbSet)
        {
            Context = context;
            DbSet = dbSet;

        }

        public TEntity GetById(int id)
        {
            var dbQueryable = DbSet.AsQueryable();

            return dbQueryable.FirstOrDefault(r => r.Id == id);

        }

        public IQueryable<TEntity> GetAll()
        {
            return DbSet.AsQueryable();
        }

        /*
        public IQueryable<TEntity> GetAllPaged(int page = 1, int numberOfItemsOnPage = 20)
        {
            return DbSet.Page(page, numberOfItemsOnPage).AsQueryable();
        }
        */
        public TEntity Add(TEntity entity)
        {
            return DbSet.Add(entity);
        }

        public IQueryable<TEntity> AddAll(IQueryable<TEntity> entities)
        {
            return entities.Select(entity => DbSet.Add(entity)).AsQueryable();
        }

        public TEntity Update(TEntity entity)
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

        protected virtual void Dispose(bool disposing)
        {
            if (!Disposed)
            {
                if (disposing)
                {
                    Context.Dispose();
                }
            }
            Disposed = true;
        }

        public void Dispose()
        {
            Dispose(true);
        }
    }
}