namespace GoldenEye.Core.Objects.Responses
{
    public class EmptyResponse: ResponseBase, IEmptyResponse
    {
        public static EmptyResponse Create()
        {
            return new EmptyResponse();
        }
    }
}
