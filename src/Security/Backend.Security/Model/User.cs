using GoldenEye.Backend.Core.Entity;
using GoldenEye.Shared.Core.Objects.General;
using Microsoft.AspNet.Identity.EntityFramework;

namespace GoldenEye.Backend.Security.Model
{
    public class User : IdentityUser<int, UserLogin, UserRole, UserClaim>, IEntity, IUser<int>
    {
        public int ExternalUserId { get; set; }

        public string FirstName { get; set; }

        public string LastName { get; set; }

        object IHasObjectId.Id
        {
            get { return Id; }
            set { Id = (int)value; }
        }
    }
}