using System.Linq;
using GoldenEye.Shared.Core.DTOs;
using GoldenEye.Shared.Core.Services;

namespace GoldenEye.Backend.Business.Services
{
    public interface IUserRestService : IReadonlyRestService<UserDTO>
    {
    }
}
