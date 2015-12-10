using System;
using System.Data.Entity;

namespace GoldenEye.Backend.Core.Context
{
    public abstract class DataContext<T> : DbContext, IDataContext where T : DbContext
    {
        protected DataContext()
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

    }
}