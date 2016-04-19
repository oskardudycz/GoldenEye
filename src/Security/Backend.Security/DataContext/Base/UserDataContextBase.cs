using GoldenEye.Backend.Core.Context;
using GoldenEye.Backend.Core.Context.SaveChangesHandlers;
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
            SaveChangesHandlerProvider.Instance.RunAll(this);
            return base.SaveChanges();
        }
    }
}