namespace GoldenEye.Shared.Core
{
    public interface IHasObjectId
    {
        object Id { get; set; }
    }

    public interface IHasId : IHasObjectId
    {
        int Id { get; set; }
    }
}
