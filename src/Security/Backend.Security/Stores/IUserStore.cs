using System;
using GoldenEye.Backend.Security.Model;
using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.EntityFramework;

namespace GoldenEye.Backend.Security.Stores
{
    public interface IUserStore<TUser> : IUserLoginStore<TUser, int>, IUserClaimStore<TUser, int>, IUserRoleStore<TUser, int>, IUserPasswordStore<TUser, int>, IUserSecurityStampStore<TUser, int>, IQueryableUserStore<TUser, int>, IUserEmailStore<TUser, int>, IUserPhoneNumberStore<TUser, int>, IUserTwoFactorStore<TUser, int>, IUserLockoutStore<TUser, int>, IDisposable
        where TUser : IdentityUser<int, UserLogin, UserRole, UserClaim>
    {
    }
}
