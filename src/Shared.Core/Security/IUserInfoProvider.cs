using System;
namespace GoldenEye.Shared.Core.Security
{
    public interface IUserInfoProvider
    {
        string GetCurrentUserName();
        TId GetCurrentUserId<TId>() where TId : IConvertible;
    }
}