using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Objects.General;

namespace GoldenEye.Events.Store
{
    public interface IEventProjectionStore
    {
        TProjection GetById<TProjection>(Guid id) where TProjection : class, IHaveGuidId;

        Task<TProjection> GetByIdAsync<TProjection>(Guid id, CancellationToken cancellationToken = default)
            where TProjection : class, IHaveGuidId;

        IQueryable<TProjection> Query<TProjection>();

        IQueryable<TProjection> CustomQuery<TProjection>(string query);
    }
}
