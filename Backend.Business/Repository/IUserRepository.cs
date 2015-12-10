using System.Linq;
using GoldenEye.Backend.Business.Entities;
using GoldenEye.Backend.Core.Repository;

namespace GoldenEye.Backend.Business.Repository
{
    public interface IUserRepository : IReadonlyRepository<UserEntity>
    {
    }
}
