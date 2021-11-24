namespace GoldenEye.Security;

public class UserInfoProvider: IUserInfoProvider
{
    public static IUserInfoProvider Instance = new UserInfoProvider();

    private IUserInfo _userInfo;

    public IUserInfo UserInfo
    {
        set { _userInfo = value; }
    }

    public int? GetCurrenUserId()
    {
        var userInfo = _userInfo;

        return userInfo != null ? userInfo.GetCurrentUserId<int>() : (int?)null;
    }
}