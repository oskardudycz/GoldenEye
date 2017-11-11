namespace GoldenEye.Shared.Core.Objects.Responses
{
    public interface ISingleResponse : IResponse
    {
        object Item { get; set; }
    }

    public interface ISingleResponse<T> : ISingleResponse
    {
        new T Item { get; set; }
    }
}