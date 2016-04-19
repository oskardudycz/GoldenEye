using GoldenEye.Backend.Core.Context;
using GoldenEye.Backend.Security.DataContext.Base;
using GoldenEye.Backend.Security.Model;

namespace GoldenEye.Backend.Security.DataContext
{
    public class UserDataContext : UserDataContextBase<User>
    {
        public UserDataContext()
        {

        }

        protected UserDataContext(string connectionString)
            : base(connectionString)
        {

        }

        public UserDataContext(IConnectionProvider connectionProvider)
            : base(connectionProvider)
        {

        }
    }
}
