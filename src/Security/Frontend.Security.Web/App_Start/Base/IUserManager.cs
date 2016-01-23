using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNet.Identity;

namespace GoldenEye.Frontend.Security.Web.Base
{
    public interface IUserManager<TUser> : IUserManager<TUser, int> where TUser : class, IUser<int>, new()
    {
        
    }

    public interface IUserManager<TUser, TKey> where TUser : class, IUser<TKey>, new() where TKey : IEquatable<TKey>
    {
        /// <summary>
        /// Finds existing username with password, if not exists checks if external authorization service 
        /// allows to authorize. If yes, creates new user.
        /// </summary>
        /// <param name="userName"></param>
        /// <param name="password"></param>
        /// <returns></returns>
        Task<TUser> FindAsync(string userName, string password);

        void Dispose();
        Task<ClaimsIdentity> CreateIdentityAsync(TUser user, string authenticationType);
        Task<IdentityResult> CreateAsync(TUser user);
        Task<IdentityResult> UpdateAsync(TUser user);
        Task<IdentityResult> DeleteAsync(TUser user);
        Task<TUser> FindByIdAsync(TKey userId);
        Task<TUser> FindByNameAsync(string userName);
        Task<IdentityResult> CreateAsync(TUser user, string password);
        Task<bool> CheckPasswordAsync(TUser user, string password);
        Task<bool> HasPasswordAsync(TKey userId);
        Task<IdentityResult> AddPasswordAsync(TKey userId, string password);
        Task<IdentityResult> ChangePasswordAsync(TKey userId, string currentPassword, string newPassword);
        Task<IdentityResult> RemovePasswordAsync(TKey userId);
        Task<string> GetSecurityStampAsync(TKey userId);
        Task<IdentityResult> UpdateSecurityStampAsync(TKey userId);
        Task<string> GeneratePasswordResetTokenAsync(TKey userId);
        Task<IdentityResult> ResetPasswordAsync(TKey userId, string token, string newPassword);
        Task<TUser> FindAsync(UserLoginInfo login);
        Task<IdentityResult> RemoveLoginAsync(TKey userId, UserLoginInfo login);
        Task<IdentityResult> AddLoginAsync(TKey userId, UserLoginInfo login);
        Task<IList<UserLoginInfo>> GetLoginsAsync(TKey userId);
        Task<IdentityResult> AddClaimAsync(TKey userId, Claim claim);
        Task<IdentityResult> RemoveClaimAsync(TKey userId, Claim claim);
        Task<IList<Claim>> GetClaimsAsync(TKey userId);
        Task<IdentityResult> AddToRoleAsync(TKey userId, string role);
        Task<IdentityResult> AddToRolesAsync(TKey userId, params string[] roles);
        Task<IdentityResult> RemoveFromRolesAsync(TKey userId, params string[] roles);
        Task<IdentityResult> RemoveFromRoleAsync(TKey userId, string role);
        Task<IList<string>> GetRolesAsync(TKey userId);
        Task<bool> IsInRoleAsync(TKey userId, string role);
        Task<string> GetEmailAsync(TKey userId);
        Task<IdentityResult> SetEmailAsync(TKey userId, string email);
        Task<TUser> FindByEmailAsync(string email);
        Task<string> GenerateEmailConfirmationTokenAsync(TKey userId);
        Task<IdentityResult> ConfirmEmailAsync(TKey userId, string token);
        Task<bool> IsEmailConfirmedAsync(TKey userId);
        Task<string> GetPhoneNumberAsync(TKey userId);
        Task<IdentityResult> SetPhoneNumberAsync(TKey userId, string phoneNumber);
        Task<IdentityResult> ChangePhoneNumberAsync(TKey userId, string phoneNumber, string token);
        Task<bool> IsPhoneNumberConfirmedAsync(TKey userId);
        Task<string> GenerateChangePhoneNumberTokenAsync(TKey userId, string phoneNumber);
        Task<bool> VerifyChangePhoneNumberTokenAsync(TKey userId, string token, string phoneNumber);
        Task<bool> VerifyUserTokenAsync(TKey userId, string purpose, string token);
        Task<string> GenerateUserTokenAsync(string purpose, TKey userId);
        void RegisterTwoFactorProvider(string twoFactorProvider, IUserTokenProvider<TUser,TKey> provider);
        Task<IList<string>> GetValidTwoFactorProvidersAsync(TKey userId);
        Task<bool> VerifyTwoFactorTokenAsync(TKey userId, string twoFactorProvider, string token);
        Task<string> GenerateTwoFactorTokenAsync(TKey userId, string twoFactorProvider);
        Task<IdentityResult> NotifyTwoFactorTokenAsync(TKey userId, string twoFactorProvider, string token);
        Task<bool> GetTwoFactorEnabledAsync(TKey userId);
        Task<IdentityResult> SetTwoFactorEnabledAsync(TKey userId, bool enabled);
        Task SendEmailAsync(TKey userId, string subject, string body);
        Task SendSmsAsync(TKey userId, string message);
        Task<bool> IsLockedOutAsync(TKey userId);
        Task<IdentityResult> SetLockoutEnabledAsync(TKey userId, bool enabled);
        Task<bool> GetLockoutEnabledAsync(TKey userId);
        Task<DateTimeOffset> GetLockoutEndDateAsync(TKey userId);
        Task<IdentityResult> SetLockoutEndDateAsync(TKey userId, DateTimeOffset lockoutEnd);
        Task<IdentityResult> AccessFailedAsync(TKey userId);
        Task<IdentityResult> ResetAccessFailedCountAsync(TKey userId);
        Task<TKey> GetAccessFailedCountAsync(TKey userId);
        IPasswordHasher PasswordHasher { get; set; }
        IIdentityValidator<TUser> UserValidator { get; set; }
        IIdentityValidator<string> PasswordValidator { get; set; }
        IClaimsIdentityFactory<TUser, TKey> ClaimsIdentityFactory { get; set; }
        IIdentityMessageService EmailService { get; set; }
        IIdentityMessageService SmsService { get; set; }
        IUserTokenProvider<TUser, TKey> UserTokenProvider { get; set; }
        bool UserLockoutEnabledByDefault { get; set; }
        TKey MaxFailedAccessAttemptsBeforeLockout { get; set; }
        TimeSpan DefaultAccountLockoutTimeSpan { get; set; }
        bool SupportsUserTwoFactor { get; }
        bool SupportsUserPassword { get; }
        bool SupportsUserSecurityStamp { get; }
        bool SupportsUserRole { get; }
        bool SupportsUserLogin { get; }
        bool SupportsUserEmail { get; }
        bool SupportsUserPhoneNumber { get; }
        bool SupportsUserClaim { get; }
        bool SupportsUserLockout { get; }
        bool SupportsQueryableUsers { get; }
        IQueryable<TUser> Users { get; }
        IDictionary<string, IUserTokenProvider<TUser, TKey>> TwoFactorProviders { get; }
    }
}