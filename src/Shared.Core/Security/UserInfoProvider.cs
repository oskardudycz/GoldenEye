﻿namespace GoldenEye.Shared.Core.Security
{
    public class UserInfoProvider
    {
        public static UserInfoProvider Instance = new UserInfoProvider();

        private IUserInfo _userInfo;

        public IUserInfo UserInfo
        {
            set { _userInfo = value; }
        }

        public int? GetCurrenUserId()
        {
            var userInfo = _userInfo;

            return userInfo != null ? userInfo.GetCurrentUserId<int>() : (int?) null;
        }
    }
}