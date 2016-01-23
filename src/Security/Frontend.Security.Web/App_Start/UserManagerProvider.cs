using GoldenEye.Backend.Security.DataContext;
using GoldenEye.Backend.Security.Model;
using GoldenEye.Backend.Security.Stores;
using GoldenEye.Frontend.Security.Web.Base;
using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.Owin;
using Microsoft.Owin;

namespace GoldenEye.Frontend.Security.Web
{
    public class UserManagerProvider
    {
        public static IUserManager<TUser> Create<TUser>(IdentityFactoryOptions<IUserManager<TUser>> options, IOwinContext context) 
            where TUser : class, IUser<int>, new()
        {
            var manager = new UserManager(new UserStore(context.Get<IUserDataContext<User>>()));
            // Configure validation logic for usernames
            manager.UserValidator = new UserValidator<User, int>(manager)
            {
                AllowOnlyAlphanumericUserNames = false,
                RequireUniqueEmail = true
            };
            // Configure validation logic for passwords
            manager.PasswordValidator = new PasswordValidator
            {
                RequiredLength = 6,
                //RequireNonLetterOrDigit = true,
                RequireDigit = true,
                RequireLowercase = true,
                RequireUppercase = true,
            };
            var dataProtectionProvider = options.DataProtectionProvider;
            if (dataProtectionProvider != null)
            {
                manager.UserTokenProvider = new DataProtectorTokenProvider<User, int>(dataProtectionProvider.Create("ASP.NET Identity"));
            }
            return manager as IUserManager<TUser>;
        }
    }
}