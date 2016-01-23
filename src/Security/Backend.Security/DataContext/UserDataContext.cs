using GoldenEye.Backend.Core.Context;
using GoldenEye.Backend.Security.DataContext.Base;
using GoldenEye.Backend.Security.Model;

namespace GoldenEye.Backend.Security.DataContext
{
    public class UserDataContext : UserDataContextBase<User>, IUserDataContext<User>
    {
        public UserDataContext()
        {

        }

        public UserDataContext(IConnectionProvider connectionProvider)
            : base(connectionProvider)
        {

        }
    }
}
