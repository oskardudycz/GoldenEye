using System.IO;

namespace GoldenEye.Extensions.Streams;

public static class StreamExtensions
{
    public static byte[] ReadFully(this Stream input)
    {
        var buffer = new byte[16 * 1024];

        input.Seek(0, SeekOrigin.Begin);

        using (var ms = new MemoryStream())
        {
            int read;
            while ((read = input.Read(buffer, 0, buffer.Length)) > 0) ms.Write(buffer, 0, read);

            return ms.ToArray();
        }
    }
}