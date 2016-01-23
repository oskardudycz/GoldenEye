using System;
using System.Collections.Generic;

namespace GoldenEye.Backend.Security.Model
{
    public interface IUser<out TKey> : Microsoft.AspNet.Identity.IUser<TKey>
    {
        int ExternalUserId { get; set; }
        string FirstName { get; set; }
        string LastName { get; set; }
        string Email { get; set; }
        bool EmailConfirmed { get; set; }
        string PasswordHash { get; set; }
        string SecurityStamp { get; set; }
        string PhoneNumber { get; set; }
        bool PhoneNumberConfirmed { get; set; }
        bool TwoFactorEnabled { get; set; }
        DateTime? LockoutEndDateUtc { get; set; }
        bool LockoutEnabled { get; set; }
        int AccessFailedCount { get; set; }
        ICollection<UserRole> Roles { get; }
        ICollection<UserClaim> Claims { get; }
        ICollection<UserLogin> Logins { get; }
    }
}