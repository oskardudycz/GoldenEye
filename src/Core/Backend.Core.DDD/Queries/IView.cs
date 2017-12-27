using GoldenEye.Shared.Core.Objects.General;

namespace GoldenEye.Backend.Core.DDD.Queries
{
    public interface IView<TKey> : IHasId<TKey>
    {
        new TKey Id { get; set; }
    }
}