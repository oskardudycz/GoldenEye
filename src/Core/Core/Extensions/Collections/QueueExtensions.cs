using System.Collections.Generic;
using System.Linq;

namespace GoldenEye.Extensions.Collections;

public static class QueueExtensions
{
    public static void EnqueueRange<T>(this Queue<T> queue, IEnumerable<T> enumerable)
    {
        enumerable.ForEach(queue.Enqueue);
    }
}