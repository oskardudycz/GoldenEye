using GoldenEye.Backend.Core.Context.SaveChangesHandler.Base;
using System;
using System.Collections.Generic;
using System.Data.Entity;

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

        protected DataContext(IConnectionProvider connectionProvider, IEnumerable<ISaveChangesHandler> saveHandlers)
            : base(connectionProvider.Open(), false)
        {
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
            if (_saveHandlers == null) 
                return;

            foreach (var handler in _saveHandlers)
            {
                handler.Handle(this);
            }
        }

        public override int SaveChanges()
        {
            RunHandlers();
            return base.SaveChanges();
        }
    }
}