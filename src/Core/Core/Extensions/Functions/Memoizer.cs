using System;
using System.Collections.Concurrent;
using Microsoft.Extensions.Caching.Memory;

namespace GoldenEye.Extensions.Functions;

public static class Memoizer
{
    /// <summary>
    /// Memoizes provided function. Function should provide deterministic results.
    /// For the same input it should return the same result.
    /// Memoized function for the specific input will be called once, further calls will use cache.
    /// </summary>
    /// <param name="func">function to be memoized</param>
    /// <typeparam name="TInput">Type of the function input value</typeparam>
    /// <typeparam name="TResult">Type of the function result</typeparam>
    /// <returns></returns>
    public static Func<TInput, TResult> Memoize<TInput, TResult>(this Func<TInput, TResult> func, MemoizeOptions options = null)
    {
        return (options?.Type == MemoizeType.MemoryCache) ? MemoizeWithMemoryCache(func, options) : MemoizeWithDictionary(func, options);
    }

    /// <summary>
    /// Memoizes provided function. Function should provide deterministic results.
    /// For the same input it should return the same result.
    /// Memoized function for the specific input will be called once, further calls will use cache.
    /// </summary>
    /// <param name="func">function to be memoized</param>
    /// <param name="options">memoize options</param>
    /// <typeparam name="TInput">Type of the function input value</typeparam>
    /// <typeparam name="TResult">Type of the function result</typeparam>
    /// <returns></returns>
    public static Func<TInput, TResult> MemoizeWithDictionary<TInput, TResult>(this Func<TInput, TResult> func, MemoizeOptions options = null)
    {
        // create cache ("memo")
        var memo = new ConcurrentDictionary<TInput, TResult>();

        // wrap provided function with cache handling
        // get a value from cache if it exists
        // if not, call factory method
        // ConcurrentDictionary will handle that internally
        return input => memo.GetOrAdd(input, func);
    }

    public static Func<TInput, TResult> MemoizeWithMemoryCache<TInput, TResult>(this Func<TInput, TResult> func, MemoizeOptions options = null)
    {
        var memCacheOptions = new MemoryCacheOptions();
        options?.MemoryCacheOptions?.Invoke(memCacheOptions);

        // create cache ("memo")
        var memo = new MemoryCache(memCacheOptions);

        // wrap provided function with cache handling
        // get a value from cache if it exists
        // if not, call factory method
        // MemCache will handle that internally
        return input => memo.GetOrCreate(input, entry =>
        {
            options?.CacheEntryOptions?.Invoke(entry);
            return func(input);
        });
    }

}

public enum MemoizeType
{
    ConcurrentDictionary,
    MemoryCache
}

public class MemoizeOptions
{
    public MemoizeType Type { get; }
    public Action<ICacheEntry> CacheEntryOptions { get; }
    public Action<MemoryCacheOptions> MemoryCacheOptions { get; }

    private MemoizeOptions(MemoizeType type, Action<ICacheEntry> cacheEntryOptions = null, Action<MemoryCacheOptions> memoryCacheOptions = null)
    {
        Type = type;
        CacheEntryOptions = cacheEntryOptions;
        MemoryCacheOptions = memoryCacheOptions;
    }

    public static MemoizeOptions ConcurrentDictionary()
    {
        return new MemoizeOptions(MemoizeType.ConcurrentDictionary);
    }

    public static MemoizeOptions MemoryCache(Action<ICacheEntry> cacheEntryOptions = null, Action<MemoryCacheOptions> memoryCacheOptions = null)
    {
        return new MemoizeOptions(MemoizeType.MemoryCache, cacheEntryOptions, memoryCacheOptions);
    }
}