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

        public IQueryable<ModelerUserEntity> GetActive()
        {
            return ((ITHBContext)Context).ModelerUsers.Where(el => !el.IdArch.HasValue &&el.IsActive && !el.IsDeleted && el.IsValid);
        }

        public bool Authorize(string username, string password)
        {
            var encodedPassword = StringEncoder.Encrypt(password);

            return GetActive()
                    .Any(
                        el =>
                            el.UserName == username
                            && el.Password == encodedPassword);
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
            return GetActive()
                .Where(el =>el.UserName == username)
                .OrderByDescending(el => el.ModificationDate)
                .Select(el => el.Id)
                .FirstOrDefault();
        }
    }
}