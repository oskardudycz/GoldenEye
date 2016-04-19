using System;
namespace GoldenEye.Shared.Core.Security
{
    public interface IUserInfo
    {
        string UserName { get; }
        TId GetCurrentUserId<TId>() where TId : IConvertible;
    }
}