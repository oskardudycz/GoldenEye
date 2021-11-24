using System.Net.Http;
using System.Threading.Tasks;

namespace GoldenEye.Testing;

public static class ResponseExtensions
{
    public static async Task<T> GetResultFromJSON<T>(this HttpResponseMessage response)
    {
        var result = await response.Content.ReadAsStringAsync();

        return result.FromJson<T>();
    }
}