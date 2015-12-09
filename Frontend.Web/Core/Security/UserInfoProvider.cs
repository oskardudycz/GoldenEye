using System.Web;
using Shared.Core.Security;

namespace Frontend.Web.Core.Security
{
    public class UserInfoProvider : IUserInfoProvider
    {
        public string GetCurrentUserName()
        {
            return HttpContext.Current.User.Identity.Name;
        }
    }
}