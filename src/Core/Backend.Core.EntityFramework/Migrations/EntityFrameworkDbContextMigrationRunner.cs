using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;

namespace GoldenEye.Backend.Core.EntityFramework.Migrations
{
    public class EntityFrameworkDbContextMigrationRunner<TDbContext> : IEntityFrameworkDbContextMigrationRunner<TDbContext>
        where TDbContext: DbContext
    {
        private readonly TDbContext dbContext;

        public EntityFrameworkDbContextMigrationRunner(TDbContext dbContext)
        {
            this.dbContext = dbContext;
        }

        public Task Run(CancellationToken cancellationToken = default)
        {
            return dbContext.Database.MigrateAsync(cancellationToken);
        }
    }
}
