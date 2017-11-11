namespace GoldenEye.Shared.Core.Objects.Requests
{
    public class EmptyRequest : RequestBase, IEmptyRequest
    {
        public static EmptyRequest Create()
        {
            return new EmptyRequest();
        }
    }
}