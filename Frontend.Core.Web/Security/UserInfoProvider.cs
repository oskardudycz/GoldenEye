using System.Web;
using GoldenEye.Shared.Core.Security;

namespace GoldenEye.Frontend.Core.Web.Security
{
    public class UserInfoProvider : IUserInfoProvider
    {
        public string GetCurrentUserName()
        {
            return HttpContext.Current.User.Identity.Name;
        }
    }
}