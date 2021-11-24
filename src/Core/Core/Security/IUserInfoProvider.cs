namespace GoldenEye.Security;

public interface IUserInfoProvider
{
    IUserInfo UserInfo { set; }

    int? GetCurrenUserId();
}