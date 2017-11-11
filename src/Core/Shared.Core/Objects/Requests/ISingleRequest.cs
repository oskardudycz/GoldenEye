namespace GoldenEye.Shared.Core.Objects.Requests
{
    public interface ISingleRequest : IRequest
    {
        object Item { get; set; }
    }

    public interface ISingleRequest<T> : ISingleRequest
    {
        new T Item { get; set; }
    }
}