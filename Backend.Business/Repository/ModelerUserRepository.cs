using System.Linq;
using Backend.Business.Context;
using Backend.Business.Entities;
using Backend.Core.Repository;
using Shared.Core.Utils;

namespace Backend.Business.Repository
{
    public class ModelerUserRepository : ReadonlyRepositoryBase<ModelerUserEntity>, IModelerUserRepository
    {
        public ModelerUserRepository(ITHBContext context)
            : base(context, context.ModelerUsers)
        {
        }

        public bool Authorize(string username, string password)
        {
            var encodedPassword = StringEncoder.Encrypt(password);

            return ((ITHBContext)Context).ModelerUsers
                    .Any(
                        el =>
                            el.UserName == username
                            && el.Password == encodedPassword
                            && el.IsActive && !el.IsDeleted && el.IsValid);
        }


        public ModelerUserEntity Find(string username, string password)
        {
            var encodedPassword = StringEncoder.Encrypt(password);

            var user = ((ITHBContext)Context).ModelerUsers.OrderByDescending(el => el.ModificationDate)
                    .FirstOrDefault(
                        el =>
                            el.UserName == username
                            && el.Password == encodedPassword
                            && el.IsActive && !el.IsDeleted && el.IsValid);

            return user;
        }

        public int FindId(string username)
        {
            return ((ITHBContext) Context).ModelerUsers
                .Where(
                    el =>
                        el.UserName == username
                        && el.IsActive && !el.IsDeleted && el.IsValid)
                .OrderByDescending(el => el.ModificationDate)
                .Select(el => el.Id)
                .FirstOrDefault();
        }
    }
}