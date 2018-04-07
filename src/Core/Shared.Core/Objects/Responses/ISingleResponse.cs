﻿namespace GoldenEye.Shared.Core.Objects.Responses
{
    public interface ISingleResponse : IResponse
    {
        object Item { get; }
    }

    public interface ISingleResponse<T> : ISingleResponse
    {
        new T Item { get; }
    }
}