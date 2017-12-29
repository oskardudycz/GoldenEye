using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Backend.Core.Context;
using GoldenEye.Shared.Core.Objects.General;

namespace GoldenEye.Backend.Core.Repositories
{
    public class CRUDRepository<TEntity> : ReadonlyRepository<TEntity>, IRepository<TEntity> where TEntity : class, IHasId
    {
        public CRUDRepository(IDataContext context) : base(context)
        {
        }

        public virtual TEntity Add(TEntity entity, bool shouldSaveChanges = true)
        {
            var result = Context.Add(entity);

            if (shouldSaveChanges)
                SaveChanges();

            return result;
        }

        public async virtual Task<TEntity> AddAsync(TEntity entity, bool shouldSaveChanges = true, CancellationToken cancellationToken = default(CancellationToken))
        {
            var result = await Context.AddAsync(entity, cancellationToken);

            if (shouldSaveChanges)
                await SaveChangesAsync(cancellationToken);

            return result;
        }

        public virtual IQueryable<TEntity> AddAll(IEnumerable<TEntity> entities, bool shouldSaveChanges = true)
        {
            var result = Context.AddRange(entities.ToArray());

            SaveChanges();

            return result.AsQueryable();
        }

        public virtual TEntity Update(TEntity entity, bool shouldSaveChanges = true)
        {
            var result = Context.Update(entity);

            if (shouldSaveChanges)
                SaveChanges();

            return result;
        }

        public async virtual Task<TEntity> UpdateAsync(TEntity entity, bool shouldSaveChanges = true, CancellationToken cancellationToken = default(CancellationToken))
        {
            var result = await Context.UpdateAsync(entity, cancellationToken: cancellationToken);

            if (shouldSaveChanges)
                await SaveChangesAsync(cancellationToken);

            return result;
        }

        public virtual int SaveChanges()
        {
            return Context.SaveChanges();
        }

        public virtual Task<int> SaveChangesAsync(CancellationToken cancellationToken = default(CancellationToken))
        {
            return Context.SaveChangesAsync(cancellationToken);
        }

        public virtual TEntity Delete(TEntity entity, bool shouldSaveChanges = true)
        {
            var result = Context.Remove(entity);

            if (shouldSaveChanges)
                SaveChanges();

            return result;
        }

        public async virtual Task<TEntity> DeleteAsync(TEntity entity, bool shouldSaveChanges = true, CancellationToken cancellationToken = default(CancellationToken))
        {
            var result = await Context.RemoveAsync(entity);

            if (shouldSaveChanges)
                await SaveChangesAsync();

            return result;
        }

        public virtual bool Delete(int id, bool shouldSaveChanges = true)
        {
            return Delete(GetById(id), shouldSaveChanges) != null;
        }

        public async virtual Task<bool> DeleteAsync(int id, bool shouldSaveChanges = true, CancellationToken cancellationToken = default(CancellationToken))
        {
            return (await DeleteAsync(await GetByIdAsync(id, cancellationToken), shouldSaveChanges, cancellationToken)) != null;
        }
    }
}