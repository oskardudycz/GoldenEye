using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using GoldenEye.Backend.Core.Context;
using GoldenEye.Backend.Core.Context.SaveChangesHandlers;
using GoldenEye.Backend.Core.Entity;
using GoldenEye.Backend.Security.Model;
using Microsoft.AspNet.Identity.EntityFramework;

namespace GoldenEye.Backend.Security.DataContext.Base
{
    public abstract class UserDataContextBase<T> : IdentityDbContext<T, Role, int, UserLogin, UserRole, UserClaim>, IUserDataContext<T> where T : IdentityUser<int, UserLogin, UserRole, UserClaim>
    {
        protected UserDataContextBase()
            : base("DBConnectionString")
        {
            SetInitializer();
        }

        protected UserDataContextBase(string connectionString)
            : base(connectionString)
        {
            SetInitializer();
        }

        protected UserDataContextBase(IConnectionProvider connectionProvider)
            : base(connectionProvider.Open(), false)
        {
            SetInitializer();
        }

        protected virtual void SetInitializer()
        {
        }

        public override int SaveChanges()
        {
            SaveChangesProcessor.Instance.RunAll(this);
            return base.SaveChanges();
        }

        public IEnumerable<IEntity> GetAddedEntities()
        {
            return ChangeTracker.Entries()
                .Where(e => e.State == EntityState.Added)
                .Select(e => e.Entity).OfType<IEntity>();
        }

        public IEnumerable<IEntity> GetUpdatedEntities()
        {
            return ChangeTracker.Entries()
                .Where(e => e.State == EntityState.Modified)
                .Select(e => e.Entity).OfType<IEntity>();
        }
    }
}