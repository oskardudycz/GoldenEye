using GoldenEye.Backend.Core.Context.SaveChangesHandler.Base;
using GoldenEye.Backend.Core.Entity;
using GoldenEye.Shared.Core.IOC;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;

namespace GoldenEye.Backend.Core.Context
{
    public abstract class DataContext<T> : DbContext, IDataContext where T : DbContext
    {
        IEnumerable<ISaveChangesHandler> _saveHandlers;

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

        protected DataContext(IConnectionProvider connectionProvider, IEnumerable<ISaveChangesHandler> saveHandlers)
            : base(connectionProvider.Open(), false)
        {
            Database.SetInitializer(new DropCreateDatabaseIfModelChanges<T>());
            _saveHandlers = saveHandlers;
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
        private void RunHandlers()
        {
            if (_saveHandlers != null)
            {
                foreach (var handler in _saveHandlers)
                {
                    handler.Handle(this);
                }
            }
        }
        public override int SaveChanges()
        {
            RunHandlers();
            return base.SaveChanges();
        }
    }
}