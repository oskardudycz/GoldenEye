namespace GoldenEye.Core.Security
{
    public interface IUserInfoProvider
    {
        IUserInfo UserInfo { set; }

        int? GetCurrenUserId();
    }
}
