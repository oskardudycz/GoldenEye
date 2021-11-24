using GoldenEye.Objects.General;

namespace GoldenEye.Queries;

public interface IView<TKey>: IHaveId<TKey>
{
    new TKey Id { get; set; }
}