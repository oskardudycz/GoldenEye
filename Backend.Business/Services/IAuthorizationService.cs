namespace Backend.Business.Services
{
    public interface IAuthorizationService
    {
        bool Authorize(string email, string password);
    }
}