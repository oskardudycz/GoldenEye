using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Shared.Core.Services;

namespace GoldenEye.Backend.Core.EntityFramework.Migrations
{
    public class EntityFrameworkMigrationsRunner: IEntityFrameworkMigrationsRunner
    {
        private readonly IEnumerable<IEntityFrameworkDbContextMigrationRunner> dbContextMigrationsRunners;

        public EntityFrameworkMigrationsRunner(IEnumerable<IEntityFrameworkDbContextMigrationRunner> dbContextMigrationsRunners)
        {
            this.dbContextMigrationsRunners = dbContextMigrationsRunners;
        }

        public Task RunAll(CancellationToken cancellationToken = default)
        {
            return Task.WhenAll(dbContextMigrationsRunners.Select(r => r.Run(cancellationToken)));
        }
    }
}
