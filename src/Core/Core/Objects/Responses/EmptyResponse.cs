namespace GoldenEye.Objects.Responses;

public class EmptyResponse: IEmptyResponse
{
    public static EmptyResponse Create()
    {
        return new EmptyResponse();
    }
}