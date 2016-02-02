using System.Web;
using GoldenEye.Shared.Core.Security;
using Microsoft.AspNet.Identity;

namespace GoldenEye.Frontend.Core.Web.Security
{
    public class UserInfoProvider : IUserInfoProvider
    {
        public string GetCurrentUserName()
        {
            return HttpContext.Current.User.Identity.Name;    
        }
        public TId GetCurrentUserId<TId>()
            where TId : System.IConvertible
        {
            return HttpContext.Current.User.Identity.GetUserId<TId>();
        }
    }
}