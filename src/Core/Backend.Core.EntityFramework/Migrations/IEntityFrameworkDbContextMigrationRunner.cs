using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;

namespace GoldenEye.Backend.Core.EntityFramework.Migrations
{
    public interface IEntityFrameworkDbContextMigrationRunner
    {
        Task Run(CancellationToken cancellationToken = default);
    }
    public interface IEntityFrameworkDbContextMigrationRunner<TDbContext> : IEntityFrameworkDbContextMigrationRunner
        where TDbContext : DbContext
    {

    }
}
