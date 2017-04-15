using System;
using System.Collections.Generic;
using System.Linq;
using GoldenEye.Backend.Core.Context.SaveChangesHandlers;
using GoldenEye.Backend.Core.Entity;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;

namespace GoldenEye.Backend.Core.Context
{
    public abstract class DataContext<T> : DbContext, IDataContext, IProvidesAuditInfo where T : DbContext
    {
        protected DataContext(DbContextOptions<T> options) : base(options)
        {
        }

        public new void Dispose()
        {
            base.Dispose();
            GC.SuppressFinalize(this);
        }

        public IDbContextTransaction BeginTransaction()
        {
            return Database.BeginTransaction();
        }

        public override int SaveChanges()
        {
            SaveChangesProcessor.Instance.RunAll(this);
            return base.SaveChanges();
        }
        public IEnumerable<IEntityEntry> Changes
        {
            get
            {
                return ChangeTracker.Entries()
                    .Select(e=> new EntityEntry((EntityEntryState)(int)e.State, (IEntity)e.Entity));
            }
        }

        public IQueryable<TEntity> GetQueryable<TEntity>() where TEntity : class
        {
            return Set<TEntity>();
        }

        TEntity IDataContext.Add<TEntity>(TEntity entity)
        {
            var entry = base.Update(entity);

            return entry.Entity;
        }

        IEnumerable<TEntity> IDataContext.AddRange<TEntity>(params TEntity[] entities)
        {
            base.AddRange(entities);

            return entities;
        }

        TEntity IDataContext.Update<TEntity>(TEntity entity)
        {
            var entry = base.Add(entity);

            return entry.Entity;
        }

        TEntity IDataContext.Remove<TEntity>(TEntity entity)
        {
            var entry = base.Remove(entity);

            return entry.Entity;
        }
    }
}