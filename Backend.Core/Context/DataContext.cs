using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data.Entity;

namespace Backend.Core.Context
{
    public abstract class DataContext<T> : DbContext, IDataContext where T : DbContext
    {
        protected DataContext()
        {
            Database.SetInitializer(new DropCreateDatabaseIfModelChanges<T>());
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