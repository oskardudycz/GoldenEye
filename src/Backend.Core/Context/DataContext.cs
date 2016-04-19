using GoldenEye.Backend.Core.Context.SaveChangesHandler.Base;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using GoldenEye.Backend.Core.Context.SaveChangesHandlers;

namespace GoldenEye.Backend.Core.Context
{
    public abstract class DataContext<T> : DbContext, IDataContext where T : DbContext
    {
        readonly IEnumerable<ISaveChangesHandler> _saveHandlers;

        protected DataContext()
        {
            SetInitializer();
        }

        protected virtual void SetInitializer()
        {
            Database.SetInitializer(new DropCreateDatabaseIfModelChanges<T>());
        }

        protected DataContext(string name) : base(name)
        {
        
        }

        protected DataContext(IConnectionProvider connectionProvider)
            : base(connectionProvider.Open(), false)
        {
        }

        public new void Dispose()
        {
            base.Dispose();
            GC.SuppressFinalize(this);
        }

        public DbContextTransaction BeginTransaction()
        {
            return Database.BeginTransaction();
        }
        
        public override int SaveChanges()
        {
            SaveChangesHandlerProvider.Instance.RunAll(this);
            return base.SaveChanges();
        }
    }
}