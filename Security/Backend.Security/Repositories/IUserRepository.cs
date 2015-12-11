using GoldenEye.Backend.Core.Repository;
using GoldenEye.Backend.Security.Model;

namespace GoldenEye.Backend.Security.Repositories
{
    public interface IUserRepository : IReadonlyRepository<User>
    {
    }
}
