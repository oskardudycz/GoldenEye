namespace GoldenEye.Backend.Security.DataContext
{
    public class UserDataContextProvider
    {
        public static IUserDataContext Create()
        {
            return new UserDataContext();
        }
    }
}