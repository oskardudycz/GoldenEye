using System;

namespace GoldenEye.Security;

public interface IUserInfo
{
    string UserName { get; }

    TId GetCurrentUserId<TId>() where TId : IConvertible;
}