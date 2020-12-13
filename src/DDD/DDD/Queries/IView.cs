using GoldenEye.Core.Objects.General;

namespace GoldenEye.DDD.Queries
{
    public interface IView<TKey>: IHaveId<TKey>
    {
        new TKey Id { get; set; }
    }
}
