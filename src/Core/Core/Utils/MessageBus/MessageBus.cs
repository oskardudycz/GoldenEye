using System.Collections.Generic;
using System.Linq;

namespace GoldenEye.Utils.MessageBus;

public class MessageBus: IMessageBus
{
    private readonly Dictionary<object, List<object>> _subscribers = new Dictionary<object, List<object>>();

    public void Subscribe<TMessage>(IMessageHandler<TMessage> handler)
        where TMessage : class, IMessage, new()
    {
        if (_subscribers.ContainsKey(typeof(TMessage)))
        {
            var handlers = _subscribers[typeof(TMessage)];
            handlers.Add(handler);
        }
        else
        {
            var handlers = new List<object> {handler};
            _subscribers[typeof(TMessage)] = handlers;
        }
    }

    public void Unsubscribe<TMessage>(IMessageHandler<TMessage> handler)
        where TMessage : class, IMessage, new()
    {
        if (!_subscribers.ContainsKey(typeof(TMessage)))
            return;

        var handlers = _subscribers[typeof(TMessage)];
        var handlerToRemove = new List<int>();
        for (var i = 0; i < handlers.Count; i++)
            if (handlers[i].GetType() == handler.GetType())
                handlerToRemove.Add(i);
        handlerToRemove.ForEach(handlers.RemoveAt);

        if (handlers.Count == 0) _subscribers.Remove(typeof(TMessage));
    }

    public void Publish<TMessage>(TMessage message)
        where TMessage : class, IMessage, new()
    {
        if (!_subscribers.ContainsKey(typeof(TMessage)))
            return;

        var msg = message.GetType();
        var handlers = _subscribers[msg];
        foreach (var handler in handlers)
            ((IMessageHandler<TMessage>)handler)
                .HandleMessage(message);
    }

    public IList<object> GetHandlers()
    {
        var handlers = new List<object>();
        foreach (var obj in _subscribers.Values) handlers.AddRange(obj.Select(x => x));
        return handlers;
    }
}