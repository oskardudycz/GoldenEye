using System;
using System.Security.Claims;
using System.Threading.Tasks;
using GoldenEye.Backend.Core.Entity;
using GoldenEye.Shared.Core;
using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.EntityFramework;

namespace GoldenEye.Backend.Security.Model
{
    public class User : IdentityUser, IEntity
    {
        public int ExternalUserId { get; set; }

        public string FirstName { get; set; }

        public string LastName { get; set; }

        public async Task<ClaimsIdentity> GenerateUserIdentityAsync(UserManager<User> manager, string authenticationType)
        {
            // Note the authenticationType must match the one defined in CookieAuthenticationOptions.AuthenticationType
            var userIdentity = await manager.CreateIdentityAsync(this, authenticationType);
            // Add custom user claims here
            return userIdentity;
        }

        object IHasObjectId.Id
        {
            get { return Id; }
            set { Id = value as string; }
        }

        int IHasId.Id
        {
            get { throw new NotImplementedException(); }
            set { throw new NotImplementedException(); }
        }
    }
}