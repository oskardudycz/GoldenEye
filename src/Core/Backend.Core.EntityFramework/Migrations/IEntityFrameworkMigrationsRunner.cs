using System.Threading;
using System.Threading.Tasks;

namespace GoldenEye.Backend.Core.EntityFramework.Migrations
{
    public interface IEntityFrameworkMigrationsRunner
    {
        Task RunAll(CancellationToken cancellationToken = default);
    }
}