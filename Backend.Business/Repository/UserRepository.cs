using System;
using System.Linq;
using GoldenEye.Backend.Business.Context;
using GoldenEye.Backend.Business.Entities;
using GoldenEye.Backend.Core.Repository;

namespace GoldenEye.Backend.Business.Repository
{
    public class UserRepository : ReadonlyRepositoryBase<ModelerUserEntity>, IModelerUserRepository
    {
        public UserRepository(ISampleContext context)
            : base(context, context.ModelerUsers)
        {
        }

        public IQueryable<ModelerUserEntity> GetActive()
        {
            return ((ISampleContext)Context).ModelerUsers.Where(el => !el.IdArch.HasValue &&el.IsActive && !el.IsDeleted && el.IsValid);
        }

        public bool Authorize(string username, string password)
        {
           throw new NotImplementedException();
        }


        public ModelerUserEntity Find(string username, string password)
        {
            throw new NotImplementedException();
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